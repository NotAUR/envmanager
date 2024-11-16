#!/bin/bash

# set -euo pipefail
# set -x
# setopt DEBUG_BEFORE_CMD
# setopt DEBUG_AFTER_CMD

s_mktemp() {
  mktemp --tmpdir="${ENVMANAGER_LOGS_DIR}" "$@"
}

s_set_variables() {
  # If _ENVMANAGER_SESSION_LOGS_FOLDER is not set, set it to $ENVMANAGER_LOGS_DIR/logs
  if [ -z "${_ENVMANAGER_SESSION_LOGS_FOLDER}" ]; then
    export _ENVMANAGER_SESSION_LOGS_FOLDER
    _ENVMANAGER_SESSION_LOGS_FOLDER="$(s_mktemp -d)"
  fi
}

# Return the path to the logs file. Relies on the environment variable and the date it was created
s_log_file() {
  s_set_variables

  if [ -z "${_S_LOG_FILE_NAME}" ]; then
    # Include date and time
    export _S_LOG_FILE_NAME
    _S_LOG_FILE_NAME="${_ENVMANAGER_SESSION_LOGS_FOLDER}/$(date +"%Y-%m-%d_%H-%M-%S").log"
  fi

  printf '%s' "$_S_LOG_FILE_NAME"
}

# Core `print` shell script function
s_printf() {
  local prefix
  prefix="[$(date +"%Y-%m-%d %H:%M:%S")] $0:${funcstack[1]}: ${funcstack[1]}"

  # If no arguments are passed, print a trace
  if (( $# > 0 )); then
    # Print log prefix information
    printf "%s | " "${prefix}"

    # Print the actual log message
    printf "$@"
  else
    # Print the line number where the function was called
    printf "Local 'print' function was called from line \"%s\" with not enough arguments! Exiting...\n" "${funcstack[2]}"
    exit 1
  fi
}

# Core `print` shell script function
s_print() {
  s_set_variables

  local tmp_line_file
  tmp_line_file="$(s_log_file)"

  s_printf "$@" >> "$tmp_line_file"

  # Print to stdout if DEBUG environment variable is set to 'y'
  if [[ "$DEBUG" == "y" ]]; then
    cat "$tmp_line_file"
  fi
}

s_print_error() {
  local line_tmp_file
  line_tmp_file="$(s_mktemp)"

  # Use `sprint` to print to `stderr` message
  s_printf "$@" > "${line_tmp_file}"

  # Print to `stderr`
  cat "${line_tmp_file}" 1>&2
}

s_split_string() {
  local string="$1"
  local delimiter="$2"

  printf '%s' "$string" | tr "$delimiter" '\n'
}

s_environment_cache_previous_value() {
  local key="$1"
  local value="$2"

  # Store the current variable value in a `${var_name}_previous` file in the cache.
  # If this file no longer exists, put it into another file called "$(printf '%s' | sha512sum | sed --regexp-extended 's/[\ \-]+$//')_previous"
  local out_file
  out_file="${ENVMANAGER_CACHE_DIR}/${key}_previous"
  
  # If the file is a directory, do nothing
  if [ -d "${out_file}" ]; then
    s_print_error "Error: %s is a directory\n" "${out_file}"
    return
  fi

  if [ -f "${out_file}" ]; then
    # If the file exists, calculate another file name based on the variable contents
    out_file="$(printf '%s=%s' "${key}" "${value}" | sha512sum | sed --regexp-extended 's/[\ \-]+$//')"
    out_file="${ENVMANAGER_CACHE_DIR}/${out_file}_previous"
  fi

  # If the file does not exists, store the current value in it
  # If the file exists, there is no need to store it. Specially because the name
  # depends on the value of the variable. If the value has changed, the SHA-512
  # hash will be different, and we will be matching a different file
  if [ ! -f "${out_file}" ]; then
    printf '%s=%s' "${key}" "${value}" > "${out_file}"
  fi
}

envmanager_clean() {
  # Put all the available variable values and run the given command
  local init_variable_values="${ENVMANAGER_CACHE_DIR}/initial_environment_variables"

  # Clean up the file
  printf '' > "${init_variable_values}"

  find "${ENVMANAGER_CACHE_DIR}" -type f -name "*_previous" -exec printf '%s\n' $(cat {}) >> "${init_variable_values}" \; || exit 1
  
  local environment_variable_assignments=()

  while IFS= read -r line; do
    environment_variable_assignments+=("$line")
  done < "${init_variable_values}"

  "${environment_variable_assignments[@]}" "$@"
}

# Function to safely add to a PATH-like environment variable without eval
s_environment() {
  local var_name="$1"
  local new_path="$2"
  local mode="${3:-append}" # Default to append if no mode is provided
   # If less than two arguments, print error and return
  if [ "$#" -lt 2 ]; then
    s_print_error "Error: s_environment() requires at least two arguments\n"
    exit 1
  fi

  # Use indirect expansion to get the value of the variable
  local current_value

  # Check for Zsh and use the appropriate indirect expansion
  if [ -n "$ZSH_VERSION" ]; then
    # shellcheck disable=SC2296
    current_value="${(P)var_name}"
  else
    current_value="${!var_name}"
  fi


  # Check if the new_path is already present in the current_value
  if [[ ":${current_value}:" != *":${new_path}:"* ]]; then
    if [ -z "${current_value}" ]; then
      # If the variable is empty, just set it to the new path
      current_value="${new_path}"
    else
      s_environment_cache_previous_value "${var_name}" "${current_value}"

      # Append or prepend the new path based on the mode
      if [ "$mode" = "prepend" ]; then
        current_value="${new_path}:${current_value}"
      else
        current_value="${current_value}:${new_path}"
      fi
    fi
  fi

  # Export the variable with the new value
  export "${var_name}"="${current_value}"

  local envmanager_variable_history_file="$ENVMANAGER_CACHE_DIR"/"${var_name}_history"
  printf '%s\n' "${current_value}" >> "${envmanager_variable_history_file}"
}

s_append() {
  s_environment "$@" append
}

s_prepend() {
  s_environment "$@" prepend
}

# Function to check if a file or directory needs to be updated based on a given number of hours
s_is_updated() {
  local file_path="$1"
  local min_hours_interval="$2"
  local cache_file="${file_path}.last_update"

  # Get the current time in seconds since epoch
  local current_time
  current_time="$(date +%s)"

  s_print "Checking when %s was last updated...\n" "$file_path"

  # If cache file is a directory, exit with error
  if [[ -d "$cache_file" ]]; then
    s_print "Error: %s is a directory\n" "$cache_file"
    exit 1
  fi

  # Check if cache file exists and has non-empty content
  if [[ -f "$cache_file" && -n "$(grep -v '^[[:space:]]*$' "${cache_file}")" ]]; then
    # Get the last update time from the cache file
    local last_update_time
    last_update_time="$(cat "$cache_file")"

    # Calculate the difference in hours between now and the last update
    local time_diff=$(( (current_time - last_update_time) / 3600 ))

    # If the number of hours since last update is less than the specified interval, return false
    if (( time_diff < min_hours_interval )); then
      s_print "Skipping update of %s (last update was %d hours ago)\n" "$file_path" "$time_diff"
      return 1  # False, no update needed
    fi
  fi

  # If we reach here, it means the file or directory should be updated
  return 0
}

