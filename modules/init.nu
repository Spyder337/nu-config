use std "path add"
use strings.nu
export const NU_PATH = ('~/AppData/Roaming/nushell' | path expand)
export const CONFIG_PATH = ('~\AppData\Roaming\nushell\configs' | path expand)
export const OMP_PATH = ([$CONFIG_PATH, 'oh-my-posh'] | path join)
# This section is dedicated to initializing oh-my-posh.
# This is the location to the oh-my-posh main config file.
export const OMP_CONFIG = ([$OMP_PATH,  'omp-config.nu'] | path join)
# There is a default remote file to fetch.
export const OMP_REMOTE_THEME = 'https://gist.githubusercontent.com/Spyder337/57192e3b740060d852a326e086780bf7/raw/7cc721390892cc9a2db7e529fb5da7929409be43/custom-theme.omp.json'
# The location on the disk where the theme is located.
export const OMP_LOCAL_THEME = ([$OMP_PATH, 'custom-theme.omp.json'] | path join)
export const COMPLETIONS_PATH = ([$NU_PATH, 'completions'] | path join)


export def main [] {
  path_init
  omp
  z_oxide
  completions
}

#	Returns a record containing themes.
export def themes [] -> record {
	return (strings css_to_nushell ($"($NU_PATH)/configs/css_themes.css" | open))
}

def omp [] {
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

def z_oxide [] {
  if ($env.Z_OXIDE_PATH | path exists) == false {
    zoxide init nushell | save -f $env.Z_OXIDE_PATH
  }
}

def completions [--verbose (-v) = false] {
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

def path_init [] {
  path add ~/.cargo/bin
  path add ~/.bin/go/bin
  path add ~/.bin/zig
  path add r#'C:\Program Files\Microsoft VS Code Insiders'#
}