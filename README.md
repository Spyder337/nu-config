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

### `scripts/aliases.nu`

Contains all of the aliases for the shell. It was a module, however, module aliases are namespaced behind the module name. That's not very demure.

### `scripts/core`

Contains the main modules to interact with the environment, manipulate databases, etc.

Modules:

- Database: Environment database store interactions.
- Environment: Editing environment settings.
- Strings: Converts or formats data to strings.
- Time: Gets a time/datetime string.

### `scripts/qol`

Contains all the extra functionality for comfort.

Modules:

- Git: Git QoL commands.
- Node: Node QoL commands.
- Programs: Program installation.
- Rust: Rust QoL commands.

### 'scripts'

Contains all of the misc scripts.

- Soulash: Entity querying.
- Tasks: ToDo/Task management.
- Welcome: Shell welcome display.

## Plugins

- `nu_plugin_compress`
- `nu_plugin_emoji`
- `nu_plugin_gstat`
- `nu_plugin_highlight`
- `nu_plugin_query`
- `nu_plugin_regex`

## Completion Support

- bat
- cargo
- curl
- gh
- git
- rustup
- ssh
- vscode

## Todo:

- [x] Environment
  - [x] Welcome message
    - [x] Day of week command
    - [x] Formatted dates
  - [x] Set the current theme inn omp-config.nu based on how init is called.
    - [x] **Remote:** Predictable out path for a fetched theme.
      - [x] Use curl to request the theme file.
      - [x] Save the output to custom-theme.omp.json
    - [x] If there is already a local file use that one.
  - [ ] Task management
    - [x] Storage
    - [x] Creation
    - [x] Duration filters
    - [ ] Completed filters
    - [ ] Displays
      - [ ] Single task
      - [ ] Multiple tasks
- [x] Completions
- [x] Git
  - [x] Fetching `.gitignore` files.
  - [x] Repo Commands
    - [x] List all repos
- [x] Rust
  - [x] Crate Presets
    - [x] Default
    - [x] Async
    - [x] Web
- [x] Program Install
  - [ ] NeoVim
    - [ ] Windows: Winget
    - [ ] Linux: Clone & Build
  - [x] Emacs
    - [x] Windows: Winget
    - [x] Linux: Clone & Build
  - [x] Python
    - [x] Fetch Version Info
    - [x] Download latest
    - [x] Download from list
  - [ ] Rust
