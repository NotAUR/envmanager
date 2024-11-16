#!/bin/bash

export ENVMANAGER_PREFIX="/etc/envmanager"

# EnvManager global scripts directory
export ENVMANAGER_GLOBAL_CONFIG_DIR="${ENVMANAGER_PREFIX}/init.d"

# EnvManager utility scripts directory
export ENVMANAGER_SCRIPTS_DIR="/usr/share/envmanager/scripts"

# EnvManager `config.sh` destination (this file)
export ENVMANAGER_CONFIG_FILE="${ENVMANAGER_PREFIX}/config.sh"

# Userspace environment variables

# EnvManager user config directory
export ENVMANAGER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/envmanager"

# User scripts directory
export ENVMANAGER_INIT_DIRECTORY="${ENVMANAGER_CONFIG_DIR}/init.d"

# EnvManager user cache directory
export ENVMANAGER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/envmanager"

# EnvManager user temp directory
export ENVMANAGER_TEMP_DIR="${XDG_RUNTIME_DIR:-/var/run}/envmanager"

# EnvManager user logs directory
export ENVMANAGER_LOGS_DIR="${ENVMANAGER_CACHE_DIR}/logs"

