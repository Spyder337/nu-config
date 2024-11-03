use std "path add"
# Create a function to initialize the environment.
# - (strings css_to_nushell ($"($NU_PATH)/configs/css_themes.css" | open))

export-env {
	load-env (($"($env.Nu_Path)/env.json" | open).Env | into record)
}

export def main [] {
	path_init
	omp
	z_oxide
	completions
}

# Create a function to load in environment variables from env.json.
export def load [] {

}
# Create a function to store the state of the environment.
export def store [] {

}
# 
# Initialize Oh-my-posh
# Initialize ZOxide
# Initialize Completions
# Initialize Themes
def omp [] {
  if ($env.OMP_DirPath | path exists) == false {
		mkdir $env.OMP_DirPath
	}

	# Download a theme from a remote if a local theme file does not exist.
	if ($env.OMP_LocalTheme | path exists) == false {
			http get -r $env.OMP_RemoteTheme | save $env.OMP_LocalTheme --force
	}

	# Initialize OMP with the custom theme config.
	if ($env.OMP_ConfigPath | path exists) == false {
		oh-my-posh init nu --config $env.OMP_LocalTheme --print | save $env.OMP_ConfigPath --force
	}
}

def z_oxide [] {
  if ($env.Z_OXIDE_PATH | path exists) == false {
    zoxide init nushell | save -f $env.Z_OXIDE_PATH
  }
}

def completions [--verbose (-v) = false] {
  	# Create the directory for completions to go if it does not exist.
	if ($env.CompletionsPath | path exists) == false {
		mkdir $env.CompletionsPath
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
		let op = [$env.CompletionsPath, $f_name] | path join
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