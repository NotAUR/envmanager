# envmanager

`envmanager` is a shell script-based utility designed to simplify managing and tracking environment variables in Bash and Zsh. It offers functionality to initialize environment settings and safely append or prepend values to path-like variables while maintaining a complete history of changes for debugging and inspection.

---

## Features

- **Recursive Initialization**: Automatically source initialization scripts from specified directories.
- **Safe Environment Variable Updates**: Append or prepend values to environment variables without overwriting existing data.
- **Change History Tracking**: Keep a detailed record of all modifications made to environment variables.
- **Cross-Shell Compatibility**: Works seamlessly in both Bash and Zsh environments.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/envmanager.git
   cd envmanager
   ```

2. Make the script executable:
   ```bash
   chmod +x envmanager.sh
   ```

3. Add the script to your `PATH` for easy access:
   ```bash
   export PATH="$PATH:$(pwd)"
   ```

4. Source the script in your shell:
   ```bash
   source envmanager.sh
   ```

---

## Usage

### 1. Initialize `envmanager`
Use the `envmanager_init` function to find and source shell scripts in `init.d` or `*.init.d` directories.

#### Example
```bash
envmanager_init "/path/to/dir1" "/path/to/dir2"
```

This will recursively search `/path/to/dir1` and `/path/to/dir2` for `init.d` or `*.init.d` directories and source all `.sh` files in them.

---

### 2. Modify Environment Variables
Use `s_environment` to safely append or prepend values to path-like environment variables such as `PATH`, `LD_LIBRARY_PATH`, or `C_INCLUDE_PATH`.

#### Syntax
```bash
s_environment ENVIRONMENT_VARIABLE_NAME "new_value" "mode"
```

- `ENVIRONMENT_VARIABLE_NAME`: The name of the environment variable to modify.
- `new_value`: The value to add.
- `mode`: Either `append` (default) or `prepend`.

For convenience, use the helper functions `s_append` or `s_prepend`.

#### Examples

##### Append a Value
```bash
s_append PATH "/usr/local/bin"
```
This appends `/usr/local/bin` to the `PATH` variable.

##### Prepend a Value
```bash
s_prepend PATH "/custom/bin"
```
This prepends `/custom/bin` to the `PATH` variable.

---

### 3. Inspect Change History
Every modification to an environment variable is tracked in a history file located in `~/.cache/envmanager`.

#### Example Workflow
```bash
$ s_append PATH "/usr/local/bin"
$ s_append PATH "/opt/bin"
$ cat ~/.cache/envmanager/PATH_history
/usr/local/bin
/usr/local/bin:/opt/bin
```

You can inspect the previous state of a variable in a `_previous` file:
```bash
$ cat ~/.cache/envmanager/3bd270f_previous
PATH=/usr/local/bin
```

---

## Debugging

To enable verbose logging and debugging, set the `S_VERBOSE` environment variable:
```bash
export S_VERBOSE=y
```

This will log detailed information about the actions performed by `envmanager`.

---

## Folder Structure

`envmanager` creates and uses the following directories:

- `~/.cache/envmanager`: Stores history files and cached states for environment variables.
- `ENVMANAGER_TEMP_DIR`: Holds temporary files used for internal processing.
- `ENVMANAGER_LOGS_DIR`: Contains logs for debugging and inspection.

---

## Contributing

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push your branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

Simplify your shell environment management with `envmanager`! 🚀
