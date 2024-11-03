def create_left_prompt [] {
		let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
				null => $env.PWD
				'' => '~'
				$relative_pwd => ([~ $relative_pwd] | path join)
		}

		let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
		let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
		let path_segment = $"($path_color)($dir)(ansi reset)"

		$path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
		# create a right prompt in magenta with green separators and am/pm underlined
		let time_segment = ([
				(ansi reset)
				(ansi magenta)
				(date now | format date '%x %X') # try to respect user's locale
		] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
				str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

		let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
				(ansi rb)
				($env.LAST_EXIT_CODE)
		] | str join)
		} else { "" }

		([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
		"PATH": {
				from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
				to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
		}
		"Path": {
				from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
				to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
		}
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
		($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
		($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
		($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
# use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)
const NU_PATH = ('~/AppData/Roaming/nushell' | path expand)
const CONFIG_PATH = ('~\AppData\Roaming\nushell\configs' | path expand)
const OMP_PATH = ([$CONFIG_PATH, 'oh-my-posh'] | path join)
# This section is dedicated to initializing oh-my-posh.
# This is the location to the oh-my-posh main config file.
const OMP_CONFIG = ([$OMP_PATH,  'omp-config.nu'] | path join)
# There is a default remote file to fetch.
const OMP_REMOTE_THEME = 'https://gist.githubusercontent.com/Spyder337/57192e3b740060d852a326e086780bf7/raw/7cc721390892cc9a2db7e529fb5da7929409be43/custom-theme.omp.json'
# The location on the disk where the theme is located.
const OMP_LOCAL_THEME = ([$OMP_PATH, 'custom-theme.omp.json'] | path join)
const COMPLETIONS_PATH = ([$NU_PATH, 'completions'] | path join)

$env.Editor = ([$env.ProgramFiles, "Microsoft VS Code Insiders", "Code - Insiders.exe"] | path join)
$env.GitIgnore_Repo_Base_URL = 'https://raw.githubusercontent.com/github/gitignore/main/'
$env.Git_User_Name = 'Spyder337'
$env.REPO_DIR = ('~\repos' | path expand)
$env.Personal_Repos = ([$env.REPO_DIR, $env.Git_User_Name] | path join)
$env.Cloned_Repos = ([$env.REPO_DIR, 'cloned'] | path join)
$env.Plans_Dir = ([$env.REPO_DIR, 'plans'] | path join)
$env.Notes_Dir = ('~\.vaults\notes' | path expand)
$env.OMP_THEME = ($OMP_LOCAL_THEME)
$env.NU_COMPLETION_DIR = ($COMPLETIONS_PATH)
$env.CARGO_BIN = ('~\.cargo\bin' | path expand)
$env.NU_CONFIG = ($CONFIG_PATH)
$env.Z_OXIDE_PATH = ([$env.NU_CONFIG, ".zoxide.nu"] | path join)
$env.WinGet_Path = ()
$env.SteamApps = ([$env.'ProgramFiles(x86)', "Steam", "steamapps", "common"] | path join)

use ./modules/ *
use ./modules/ strings
use ./modules/ init
init
$env.Themes = init themes