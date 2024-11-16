#!/bin/bash

# This refers to the initial script that will run all the init scripts
# and set up the environment

# Load envmanager environment variables
source "/etc/envmanager/config.sh"

source "$ENVMANAGER_SCRIPTS_DIR"/core.sh
source "$ENVMANAGER_SCRIPTS_DIR"/init.sh

# Export ENVMANAGER_DEFAULT_INIT_DIR_LIST here. The user can append to it, if needed
ENVMANAGER_DEFAULT_INIT_DIR_LIST=(
  "$ENVMANAGER_GLOBAL_CONFIG_DIR"
  "$ENVMANAGER_INIT_DIRECTORY"
)

# Run init scripts
envmanager_init "${ENVMANAGER_DEFAULT_INIT_DIR_LIST[@]}" 

