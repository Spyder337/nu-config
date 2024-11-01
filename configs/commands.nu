use ../modules/ *

#################
#   Nu Config   #
#################
def nu_plugins [] {
  let plugins = (glob ~/.cargo/bin/nu_plugin_*.*)
  return $plugins
}

def add_plugins [] {
  let plugins = nu_plugins
  $plugins | each {|plugin_name|
    plugin add $plugin_name
  }
}

#####################
#   Git Commands    #
#####################

# Fetches a .gitignore file from the official gitignore repo.
# Requires an ignore file name that matches one in their repo.
def fetch_git_ignore [ignore_file: string] {
  let url = $"($env.GitIgnore_Repo_Base_URL)($ignore_file).gitignore"
  http get $url | save ".gitignore"
}

###################
#   File System   #
###################

# List the rs and toml files in a rust crate directory.
# Uses the path relative to the current $env.PWD
def lf-rust [] -> list<any> {
  let files = (glob **/src/**/*.{rs, toml})
  $files | each { |path|
    let link = $"($path | path relative-to ($env.PWD))"
    $"($path)" | ansi link --text $link
  }
}

#######################################
#               Summary               #
#######################################

# Lists the git repos in the '~/repos' directory.
# Ignores some preset directories.
#   - '**/.git'
#   - '**/.obsidian'
#   - '**/plans/**'
def repos-list [ include_paths: bool = false] -> table {
  let ignored_dirs = ["**/.git", "**/.obsidian", "**/*.md", "**/plans/**"]
  let res  = glob ~/repos/*/* --exclude $ignored_dirs | each {|p|
    let parent = $"(($p | path dirname) | path basename)"
    mut r_type = $""
    let r_name = $"($p | path basename)"
    match $parent {
      "Spyder337" => {$r_type = "Working"},
      "cloned" => {$r_type = "Cloned Builds"},
      _ => {}
    }
    let row = {"Repo Type":$"($r_type)", "Repo Name":($p | ansi link --text $"($r_name)")}
    $row
  }
  let t = ($res | table)
  return $t
}

#######################
#   Welcome Message   #
#######################

# Generates a welcome message when nushell starts up.
def welcome_msg [] {
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  let t = time full
  print $"Welcome (ansi -e $w_c)($env.Git_User_Name)(ansi reset)!
Today is (ansi -e $w_c)($t.DayOfWeek)(ansi reset) the (ansi -e $w_c)($t.Day)(ansi reset) of (ansi -e $w_c)($t.Month)(ansi reset).
The Date is (ansi -e $w_c)($t.Date)(ansi reset)"
}
