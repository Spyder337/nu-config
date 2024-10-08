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
- [ ] Set the current theme inn omp-config.nu based on how init is called.
    - [ ] **Remote:** Predictable out path for a fetched theme.
        - [ ] Use curl to request the theme file.
        - [ ] Save the output to custom-theme.omp.json
    - [ ] If there is already a local file use that one.