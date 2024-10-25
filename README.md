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

## Plugins

0. `nu_plugin_compress`
1. `nu_plugin_emoji`
2. `nu_plugin_gstat`
3. `nu_plugin_highlight`

# Completion Support

- git
- gh
- cargo
- rustup
- vscode
- ssh
- curl
- bat

# Todo:

- [x] Welcome message
- [x] Set the current theme inn omp-config.nu based on how init is called.
  - [x] **Remote:** Predictable out path for a fetched theme.
    - [x] Use curl to request the theme file.
    - [x] Save the output to custom-theme.omp.json
  - [x] If there is already a local file use that one.
- [x] Basic completions
- [x] Fetching `.gitignore` files.
- [x] Rust cargo shortcuts for adding crates
  - [x] Default
  - [x] Async
  - [x] Web
- [x] Repo Commands
  - [x] List all repos
- [/] Program Install
  - [x] Emacs
  - [ ] Python
- [/] Dwarf Fortress Ref
  - [/] Tips/Tricks
  - [ ] Rooom Qualities
    - [ ] Localize room tiers
  - [ ] Nobles List
  - [ ] Fortress Tiers
