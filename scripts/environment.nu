use std "path add"
# Create a function to initialize the environment.
# - (strings css_to_nushell ($"($NU_PATH)/configs/css_themes.css" | open))

export-env {
	$env.Nu_Path = ('~/AppData/Roaming/nushell' | path expand)
	$env.Nu_ConfigPath = ('~\AppData\Roaming\nushell\configs' | path expand)
	$env.OMP_DirPath = ([$env.Nu_ConfigPath, 'oh-my-posh'] | path join)
	# This section is dedicated to initializing oh-my-posh.
	# This is the location to the oh-my-posh main config file.
	$env.OMP_ConfigPath = ([$env.OMP_DirPath,  'omp-config.nu'] | path join)
	# The location on the disk where the theme is located.
	$env.OMP_LocalTheme = ([$env.OMP_DirPath, 'custom-theme.omp.json'] | path join)
	$env.CompletionsPath = ([$env.Nu_Path, 'completions'] | path join)
	$env.REPO_DIR = ('~\repos' | path expand)
	$env.Cloned_Repos = ([$env.REPO_DIR, 'cloned'] | path join)
	$env.Plans_Dir = ([$env.REPO_DIR, 'plans'] | path join)
	$env.Notes_Dir = ('~\.vaults\notes' | path expand)
	$env.OMP_THEME = ($env.OMP_LocalTheme)
	$env.NU_COMPLETION_DIR = ($env.CompletionsPath)
	$env.CARGO_BIN = ('~\.cargo\bin' | path expand)
	$env.NU_CONFIG = ($env.Nu_ConfigPath)
	$env.Z_OXIDE_PATH = ([$env.NU_CONFIG, ".zoxide.nu"] | path join)
	$env.DatabasePath = ([$env.NU_Path, "data", "env.db"] | path join)
	$env.Database = (stor import -f $env.DatabasePath)

	load-env (($"($env.Nu_Path)/data/env.json" | open).Env | into record)

	$env.Personal_Repos = ([$env.REPO_DIR, $env.GitHubUserName] | path join)
}

#	Initializes environment variables.
#	
# Initializes:
# - Path variables
# - Oh-my-posh
# - Z Oxide
# - Completions
export def --env main [
	--verbose (-v)	#	Outputs extra information about what's happening.
	] -> none {
	if $verbose {
		paths -v
		omp -v
		z_oxide -v
		completions -v
	} else {
		paths
		omp
		z_oxide
		completions
	}
}

export def cd [path?: string] -> none {
	if $path == null {
		^zi "."
	}
	else {
		^zi $path
	}
}

# Initialize Oh-my-posh
# Initialize ZOxide
# Initialize Completions
# Initialize Themes

def omp [
	--verbose (-v) # Prints out extra information to the console.
	] -> none {
  if ($env.OMP_DirPath | path exists) == false {
		if $verbose {
			print "Oh-my-posh directory not found."
			print $"Creating directory...\nPath: ($env.OMP_DirPath)"
		}
		mkdir $env.OMP_DirPath
	}

	# Download a theme from a remote if a local theme file does not exist.
	if ($env.OMP_LocalTheme | path exists) == false {
		if $verbose {
			print $"Fetching remote theme...\nUrl: ($env.OMP_RemoteTheme)"
			print $"Saving file to:\nPath: ($env.OMP_LocalTheme)"
		}
		http get -r $env.OMP_RemoteTheme | save $env.OMP_LocalTheme --force
	}

	# Initialize OMP with the custom theme config.
	if ($env.OMP_ConfigPath | path exists) == false {
		if $verbose {
			print $"Initializing oh-my-posh...\nUsing Theme: ($env.OMP_LocalTheme)
Saving file...\nPath: ($env.OMP_ConfigPath)"
		}
		oh-my-posh init nu --config $env.OMP_LocalTheme --print | save $env.OMP_ConfigPath --force
	}
}

def z_oxide [
	--verbose (-v) # Prints out extra information to the console.
] -> none {
  if ($env.Z_OXIDE_PATH | path exists) == false {
		if $verbose {
			print $"Initializing zoxide...\nUsing file: ($env.Z_OXIDE_PATH)"
		}
    zoxide init nushell | save -f $env.Z_OXIDE_PATH
  }
}

def completions [
	--verbose (-v)	# Prints out extra information to the console.
	] -> none {
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
		let f_name = ($url | regex '(([a-z]+-[a-z]*)\.nu)' | first).match
		#	Create the file's output path
		let op = [$env.CompletionsPath, $f_name] | path join
		if ($op | path exists) == false {
			if $verbose {
				print $"Generating ($f_name)"
				print $"Destination: \"($op)\""
			}
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

export def --env paths [
	--verbose (-v)	# Prints extra information to the console.
] {
	let paths = [
		('~/.cargo/bin' | path expand)
		('~/.bin/go/bin' | path expand)
		('~/.bin/zig' | path expand)
		r#'C:\Program Files\Microsoft VS Code Insiders'# 
		('~/.bin/sqlite' | path expand)
	]
	let total = $paths | length
	mut cnt = 0
	mut added = 0
	for $path in $paths {
		if ($env.PATH | find $path | length) == 0 {
			if $verbose {
				print $'Adding "($path)" to $env.Path...'
			}
			path add $path
			$added = $added + 1
		}
		$cnt = $cnt + 1
	}
	if $verbose {
		print $"Added ($added)/($cnt) new paths"
	}
}