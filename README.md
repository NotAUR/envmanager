# envmanager

`envmanager` is a shell script-based utility that simplifies managing and tracking environment variables in Bash and Zsh. It allows recursive initialization of scripts and safely appends or prepends values to path-like variables while maintaining a history of changes.

This repository includes a `PKGBUILD` for easy installation on Arch Linux.

---

## Features

- **Recursive Initialization**: Source all scripts in `init.d` or `*.init.d` directories.
- **Safe Variable Updates**: Append or prepend values to environment variables without overwriting.
- **Change History**: Track all modifications to environment variables.
- **Shell Compatibility**: Fully functional in both Bash and Zsh.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/envmanager.git
   cd envmanager
   ```

2. Build and install the package:
   ```bash
   makepkg -i
   ```

---

## Usage

### 1. Initialize `envmanager`

Use the `envmanager_init` function to source all scripts in `init.d` or `*.init.d` directories.

#### Example
```bash
envmanager_init "/path/to/dir1" "/path/to/dir2"
```

This will recursively search `/path/to/dir1` and `/path/to/dir2` for `init.d` or `*.init.d` directories and source all `.sh` files.

---

### 2. Modify Environment Variables

Use `s_environment` to append or prepend values to path-like environment variables.

#### Syntax
```bash
s_environment ENVIRONMENT_VARIABLE_NAME "new_value" "mode"
```

- `ENVIRONMENT_VARIABLE_NAME`: The name of the variable to modify.
- `new_value`: The value to add.
- `mode`: Either `append` (default) or `prepend`.

Alternatively, use the helper functions `s_append` and `s_prepend`.

#### Append Example
```bash
s_append PATH "/usr/local/bin"
```

#### Prepend Example
```bash
s_prepend PATH "/custom/bin"
```

---

### 3. Inspect Change History

Modifications to environment variables are recorded in `~/.cache/envmanager`.

#### Example Workflow
```bash
$ s_append PATH "/usr/local/bin"
$ s_append PATH "/opt/bin"
$ cat ~/.cache/envmanager/PATH_history
/usr/local/bin
/usr/local/bin:/opt/bin
```

Inspect the previous state of a variable:
```bash
$ cat ~/.cache/envmanager/3bd270f_previous
PATH=/usr/local/bin
```

---

## Debugging

Enable verbose logging with:
```bash
export S_VERBOSE=y
```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

Effortlessly manage your shell environment with `envmanager`! 🚀
