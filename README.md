# Nu Configs

## Installation

The configuration requires several tools:

- [fzf](https://github.com/junegunn/fzf)
- [z oxide](https://github.com/ajeetdsouza/zoxide)
- [carapace](https://github.com/carapace-sh/carapace-bin)
- [oh my posh](https://ohmyposh.dev/docs/)

## Nu files

### `env.nu`

Handles:

- Evironment variables
- Write files

Having `env.nu` run first assures that files are created so that `config.nu` can read them.

### `config.nu`

When in doubt the preferred location for placing things in config.
Handles:

- Definitions
- Aliases
- Append global namespace

### `configs/commands.nu`

Contains all of the custom commands for the shell.

### `configs/aliases.nu`

Contains all of the custom aliases for the shell.

## Plugins

0. `nu_plugin_compress`
1. `nu_plugin_emoji`
2. `nu_plugin_gstat`
3. `nu_plugin_highlight`
4. `nu_plugin_query`

## Completion Support

- git
- gh
- cargo
- rustup
- vscode
- ssh
- curl
- bat

## Todo:

- [x] Welcome message
  - [x] Day of week command
  - [x] Formatted dates
- [x] Set the current theme inn omp-config.nu based on how init is called.
  - [x] **Remote:** Predictable out path for a fetched theme.
    - [x] Use curl to request the theme file.
    - [x] Save the output to custom-theme.omp.json
  - [x] If there is already a local file use that one.
- [x] Basic completions
  - [x] Easy completion management.
- [x] Fetching `.gitignore` files.
- [x] Rust cargo shortcuts for adding crates
  - [x] Default
  - [x] Async
  - [x] Web
- [x] Repo Commands
  - [x] List all repos
- [x] Program Install
  - [x] Emacs
    - [x] Windows: Winget
    - [x] Linux: Clone & Build
  - [x] Python
    - [x] Fetch Version Info
    - [x] Download latest
    - [x] Download from list
- [/] Dwarf Fortress Ref
  - [/] Tips/Tricks
  - [ ] Rooom Qualities
    - [ ] Localize room tiers
  - [ ] Nobles List
  - [ ] Fortress Tiers
