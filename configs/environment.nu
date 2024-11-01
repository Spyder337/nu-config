use std "path add"
path add ~/.cargo/bin
path add ~/.bin/go/bin
path add ~/.bin/zig
path add r#'C:\Program Files\Microsoft VS Code Insiders'#

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')s

#############################
#   Constant declarations   #
#############################
export const NU_PATH = ('~/AppData/Roaming/nushell' | path expand)
export const $CONFIG_PATH = ('~\AppData\Roaming\nushell\configs' | path expand)
export const $OMP_PATH = ([$CONFIG_PATH, 'oh-my-posh'] | path join)
# This section is dedicated to initializing oh-my-posh.
# This is the location to the oh-my-posh main config file.
export const $OMP_CONFIG = ([$OMP_PATH,  'omp-config.nu'] | path join)
# There is a default remote file to fetch.
export const $OMP_REMOTE_THEME = 'https://gist.githubusercontent.com/Spyder337/57192e3b740060d852a326e086780bf7/raw/7cc721390892cc9a2db7e529fb5da7929409be43/custom-theme.omp.json'
# The location on the disk where the theme is located.
export const $OMP_LOCAL_THEME = ([$OMP_PATH, 'custom-theme.omp.json'] | path join)
export const $COMPLETIONS_PATH = ([$NU_PATH, 'completions'] | path join)

#############################
#   Environment Variables   #
#############################
$env.Editor = ([$env.ProgramFiles, "Microsoft VS Code Insiders", "Code - Insiders.exe"] | path join)
$env.GitIgnore_Repo_Base_URL = 'https://raw.githubusercontent.com/github/gitignore/main/'
$env.Git_User_Name = 'Spyder337'
$env.REPO_DIR = ('~\repos' | path expand)
$env.Personal_Repos = ([$env.REPO_DIR, $env.Git_User_Name] | path join)
$env.Cloned_Repos = ([$env.REPO_DIR, 'cloned'] | path join)
$env.Plans_Dir = ([$env.REPO_DIR, 'plans'] | path join)
$env.Notes_Dir = ('~\.vaults\notes' | path expand)
$env.OMP_THEME = $OMP_LOCAL_THEME
$env.NU_COMPLETION_DIR = $COMPLETIONS_PATH
$env.CARGO_BIN = ('~\.cargo\bin' | path expand)
$env.NU_CONFIG = $CONFIG_PATH
$env.Z_OXIDE_PATH = ([$env.NU_CONFIG, ".zoxide.nu"] | path join)
$env.WinGet_Path = ()
$env.SteamApps = ([$env.'ProgramFiles(x86)', "Steam", "steamapps", "common"] | path join)
$env.Themes = (strings css_to_nushell ($"($env.NU_CONFIG)/css_themes.css" | open))

# Description:
#	Initializes an Oh My Posh theme and configuration if they are not found.
def init_omp [] {
	if ($OMP_PATH | path exists) == false {
		mkdir $OMP_PATH
	}

	# Download a theme from a remote if a local theme file does not exist.
	if ($OMP_LOCAL_THEME | path exists) == false {
			http get -r $OMP_REMOTE_THEME | save $OMP_LOCAL_THEME --force
	}

	# Initialize OMP with the custom theme config.
	if ($OMP_CONFIG | path exists) == false {
		oh-my-posh init nu --config $OMP_LOCAL_THEME --print | save $OMP_CONFIG --force
	}
}

#	Description:
#	Initializes the Z Oxide file if one is not found.
def init_z [] {
	# Check to see if zoxide has been initialized.
	# If not then initialize it.
	if ($env.Z_OXIDE_PATH | path exists) == false {
			zoxide init nushell | save -f $env.Z_OXIDE_PATH
	}
}

#Description:
#Initializes completion files.
#Completions:
#	- Git
#	- GH
#	- Cargo
#	- Bat
#	- RustUp
#	- VS Code
#	- SSH
#	- Curl
def init_completions [verbose: bool = false] {
	# Create the directory for completions to go if it does not exist.
	if ($COMPLETIONS_PATH | path exists) == false {
		mkdir $COMPLETIONS_PATH
	}
		
	let urls = [
		"https://raw.githubusercontent.com/nushell/nu_scripts/refs/heads/main/custom-completions/git/git-completions.nu",
		"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/gh/gh-completions.nu",
		"https://raw.githubusercontent.com/nushell/nu_scripts/refs/heads/main/custom-completions/cargo/cargo-completions.nu",
		"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/bat/bat-completions.nu",
		"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/rustup/rustup-completions.nu",
		#"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/vscode/vscode-completions.nu",
		"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/ssh/ssh-completions.nu",
		"https://github.com/nushell/nu_scripts/raw/refs/heads/main/custom-completions/curl/curl-completions.nu"
	]
	
	let config_txt = ($nu.config-path | open)

	#	When there is a missing completions file then the output path is returned
	#	from the each operator. This means that if all files already exist then
	#	paths is an empty list.
	let paths = $urls | each { |url|
		#	Get the file name from the url
		let f_name = ($url | regex '(([a-z]*-[a-z]*)\.nu)' | first).match
		#	Create the file's output path
		let op = [$COMPLETIONS_PATH, $f_name] | path join
		if ($op | path exists) == false {
			print $"Generating ($f_name)"
			print $"Destination: \"($op)\""
			#	Fetch the page and save it
			http get -r $url | save -f $op
			sleep 2sec

			#	If the config contains a reference to the path then don't add it.
			if ($config_txt | str contains $op) != true {
				return $"./completions/($f_name)"
			}
		} else {
			if $verbose == true {
				print $"Completion file already found for ($f_name)"
			}
		}
	}

	#	If there are no new paths then exit the function.
	let len = ($paths | length)
	if ($len == 0) == true {
		return
	}

	#	Generate a list of strings that source each new file.
	let sources = $paths | each {|p| $"source ($p)"}
	
	#	Save the new sources to the config.
	$sources | save --append ($nu.config-path)
}

init_omp
init_z
init_completions