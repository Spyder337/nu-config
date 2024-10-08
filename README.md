# Nu Configs
## `env.nu`
Handles:
- Evironment variables
- Write files

Having `env.nu` run first assures that files are created so that `config.nu` can read them.

## `config.nu`
When in doubt the preferred location for placing things in config.
Handles:
- Definitions
- Aliases
- Append global namespace

# Todo
- [x] Set the current theme inn omp-config.nu based on how init is called.
    - [x] **Remote:** Predictable out path for a fetched theme.
        - [x] Use curl to request the theme file.
        - [x] Save the output to custom-theme.omp.json
    - [x] If there is already a local file use that one.
- [x] Fetching `.gitignore` files.
- [x] Rust cargo shortcuts for adding crates
    - [x] Default
    - [x] Async
    - [x] Web