#!/bin/bash

# If $S_VERBOSE is set, enable all debug features of both Bash and ZSH
if [[ "${S_VERBOSE}" == "y" ]]; then
  set -x
  setopt DEBUG_BEFORE_CMD
  setopt DEBUG_AFTER_CMD
fi

# Set storage init system log file
export ENVMANAGER_INIT_SYSTEM_LOG_FILE="${ENVMANAGER_LOGS_DIR}"/init.d.log

# Function to write the current timestamp to a .last_update file
s_write() {
  local original_path="$1"
  local cache_file="${original_path}.last_update"

  # Get the current time in seconds since epoch
  local current_time
  current_time="$(date +%s)"

  printf "%s" "$current_time" > "$cache_file"
}

envmanager_make_user_directories() {
  # Create all the necessary folders in the user directory:
  user_directories=(
    "${ENVMANAGER_CONFIG_DIR}"
    "${ENVMANAGER_INIT_DIRECTORY}"
    "${ENVMANAGER_CACHE_DIR}"
    "${ENVMANAGER_TEMP_DIR}"
    "${ENVMANAGER_LOGS_DIR}"
  )

  for directory in "${user_directories[@]}"; do
    # If the variable is empty, log an error message
    if [[ -z "$directory" ]]; then
      s_print_error "Error: %s is empty\n" "$directory"
      continue
    fi
    s_print "Creating directory: %s\n" "$directory"
    install -d -m 0700 "$directory"
  done
}

envmanager_init() {
  s_print "Running init scripts...\n"

  # Create all the necessary folders in the user directory:
  envmanager_make_user_directories

  local search_directory_list=(
    "$@"
  )
  # SHA-512 hash of all directories
#  local directories_hash=$(find "${search_directory_list[@]}" -type f -exec sha512sum {} + | sha512sum | awk '{print $1}')
  local directories_hash=$(printf '%s\n' "${search_directory_list[@]}" | sha512sum | awk '{print $1}')
  local shell_script_files=()
  local init_directory_cached_list="$ENVMANAGER_CACHE_DIR"/"${directories_hash}"

  s_print "Init directory cached list: %s\n" "${init_directory_cached_list}"

  # Print SHA-512 hash of all directories
  s_print "Directories hash: %s\n" "${directories_hash}"

  if [[ ! -f "${init_directory_cached_list}" || "$(s_is_updated "${init_directory_cached_list}" 24)" || "${FORCE_UPDATE}" == "y" ]]; then
    # Print current directories
    s_print "Search directories: %s\n" "${search_directory_list[@]}"
    s_print "Cached list: %s\n" "${init_directory_cached_list}"
    s_print "Force update: %s\n" "${FORCE_UPDATE}"

    local find_arguments=(
      "${search_directory_list[@]}"
      '-type' 'd'
    )

    s_print "Finding all init.d directories...\n" "${find_arguments[@]}"

    # Check if the file exists
    if [ -d "${init_directory_cached_list}" ]; then
      s_print "\"${init_directory_cached_list}\" is a directory!\n"
      s_print "Backing up \"${init_directory_cached_list}\" to \"${init_directory_cached_list}.old\"\n"

      # Create temporary log file
      local rsync_temp_log_file
      rsync_temp_log_file="$(s_log_file)"

      local rsync_arguments=(
        -avz --progress
        -r "${init_directory_cached_list}" "${init_directory_cached_list}.old"
        # Log everything to init.d.log
        --log-file "${rsync_temp_log_file}"
      )

      # Backup the folder with `rsync`
      rsync "${rsync_arguments[@]}" || exit 1

      # Append the `rsync` command execution log to the init.d.log
      s_print '%s\n' "$(cat "${rsync_temp_log_file}")"
dd
      s_print '%s\n' "$(rm -rfv "${init_directory_cached_list}")"
    fi

    s_print "Finding directory list: %s\n" "${search_directory_list[@]}"
    
    # Find all init.d directories
    find "${search_directory_list[@]}" -type d \( \
      -name '*.init.d' \
      -or -name 'init.d' \
    \) > "${init_directory_cached_list}"

    s_write "${init_directory_cached_list}"
  fi

  local init_directories=()

  # Read all init.d directories
  while IFS= read -r line; do
    s_print "Found directory: %s\n" "$line"
    init_directories+=("$line")
  done < "${init_directory_cached_list}"

  # Find `.sh` files within `init.d` directories
  for directory in "${init_directories[@]}"; do
    local shell_script_file_list;
    shell_script_file_list="$ENVMANAGER_TEMP_DIR"/"$(printf "%s" "$directory" | sha512sum)"
    
    s_print "Finding all shell script files in %s...\n" "$directory"

    find "$directory" -type f -name '*.sh' > "${shell_script_file_list}"

    s_print "Found %s shell script files in %s\n" "${shell_script_file_list}"

    # Loop over shell script files and initialize them
    while IFS= read -r shell_script_file; do
      shell_script_files+=("$shell_script_file")
      s_print "Found %s\n" "$shell_script_file"
    done < "${shell_script_file_list}"
  done

  # Load all init.d scripts
  for file in "${shell_script_files[@]}"; do
    s_print 'Sourcing shell script file: %s\n' "$file"
    # shellcheck disable=SC1090
    source "$file"
  done
}

