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