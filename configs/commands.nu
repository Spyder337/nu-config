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

###############################
#   Project Initialization    #
###############################
def default_crates [] {
  cargo add dirs_next
  cargo add serde --features derive
  cargo add serde_json
  cargo add lazy_static
}

def default_async_crates [] {
  default_crates
  cargo add tokio --features full
}

def default_web_crates [parsing: bool] {
  default_async_crates
  cargo add reqwest
  if $parsing {
    cargo add select
  }
}

def create_npm_project [ts_enabled: bool = true, es_lint_enabled: bool = true] {
  print "Initializing node project..."
  npm init

  if $ts_enabled {
    print "Installing @types/node..."
    npm -i --save-dev "@types/node"
    print "Installing TypeScript..."
    npm -i --save-dev "typescript"
    print "Initializing TypeScript..."
    tsc --init -t es2022 -m commonjs
    print "Fetching index.ts file..."
    # Add a curl command to download a index template file
    touch "index.ts"
  }

  if $es_lint_enabled {
    print "Installing ES Lint..."
    npm init "@eslint/config@latest"
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

###############################
#   Dependency Installation   #
###############################

# Description:
# Installs the newest emacs from source.
# Installs the following dependencies:
# - 'git'
# - 'gcc'
# - 'make'
# - 'textinfo'
# - 'autoconf'
# - 'pkg-config'
# - 'libcurses-dev'
#
# Currently only works on Linux machines.
def install_emacs [] {
  if (sys host).name == "Windows" {
    print "This function is unavailable on Windows."
    return
  } else if (sys host).name == "macOS" {
    print "This function is unavailable on OS/X."
    return
  }
  if (~/emacs | path exists) == false {
    mkdir ~/emacs
  }
  cd ~/emacs
  git clone --depth=1 git://git.sv.gnu.org/emacs.git
  let deps = ['git', 'gcc', 'make', 'textinfo', 'autoconf', 'pkg-config', 'libcurses-dev']

  deps | each {|dep|
    sudo apt install -t $dep
  }

  make configure="--prefix=/opt/emacs CFLAGS='-O0 -g3' --without-x --with-mailutils"

  sudo make install
}

# Description:
# Fetch the html document for the page.
def fetch_web_doc [url: string] -> any {
  try {
    let doc = http get $url
    return $doc
  } catch {
    return null
  }
}

# Description:
# Fetches the python source page.
def fetch_python_source [] -> any {
  let url = "https://www.python.org/downloads/source/"
  let doc = fetch_web_doc $url
  return $doc
}

# Description:
# Fetches the latest python version from https://www.python.org/downloads/source/.
def fetch_latest_python_version [dl_latest: bool = true] {
  let dss  = "#content > div > section > article > div > div:nth-child(1) > ul > li > ul > li > a"
  let doc = fetch_python_source

  if ($doc != null) == false {
    return "Could not fetch the version from the url."
  }

  let links = $doc | query web --query $dss --attribute href | flatten
  mut link = ""
  if ($dl_latest) == true {
    $link = ($links | where {|l| $l | str ends-with ".tgz"} | first)
  } else {
    let selection  = ($links | where {|l| $l | str ends-with ".tgz"} | take 40 | fzf)
    $link = ($selection | regex '\bhttps:[a-z\:\/\.0-9A-Z\-]*\b' | first).match
  }
  curl -L $link | save ('~/Downloads/python.tgz') --force
  #let dl_link = $doc | query web --query $dss --attribute href | flatten | first
  #print $dl_link
}

# Description
# Fetches the latest python version number from the source downloads page on
# the python website.
def fetch_latest_python_ver_num [] -> string {
  let vss = "#content > div > section > article > ul > li > a"
  let doc = fetch_python_source
  if ($doc != null) == false {
    return "Could not find the version number."
  }

  let version = $doc | query web --query $vss | flatten | first
  let v = ($version | regex '(\b(([0-9]+)(\.*))+){2,}' | first)."match"
  return $v
}

# Description:
# Checks if pyton is installed on the system.
def is_python_installed [] -> bool {
  try {
    if ((sys host).name == "Windows") == true {
      let out = (py -V)
      return true
    }
  } catch {
    return false
  }
}

# Description:
# Downloads and compiles the newest python version from https://devguide.python.org/versions/#supported-version
def install_python [] {
  if (is_python_installed) == true {
    print "Python is already installed."
    py -V
    return
  }
  if (sys host).name == "Windows" {
    mut v = fetch_latest_python_ver_num
    if ($v | str ends-with ".0") == true {
      $v = $v | str substring 0..-3
    }
    print $"Winget Version: ($v)"
    let p_name = $"Python.Python.($v)"
    print $"Winget Package Name: ($p_name)"
    winget install $p_name
    return
  } else {
    
  }

}

#################
#   Date/Time   #
#################

def full_date [] -> string {
  let d = ((date now) | date to-record)
  print $"Target Date: ($d.day)"
  $"(day_of_week $d.day)"
}

def day_of_week [ day: int ]  -> string {
  let c: table = (cal -t)
  print $"Target Date: ($day)"
  let row = $c | where {|r| $"($r.su)" == $"($day)" or $"($r.mo)" == $"($day)" or $"($r.tu)" == $"($day)" or $"($r.we)" == $"($day)" or $"($r.th)" == $"($day)" or $"($r.fr)" == $"($day)" or $"($r.sa)" == $"($day)"}
  print $row 
  return "N/A"
}

# Returns the Date in the Day-Month-Year format.
def dmy_date [] -> string {
  let d = ((date now) | date to-record)
  $"($d.day)-($d.month)-($d.year)"
}

# Returns the Date in the Month-Day-Year format.
def mdy_date [] -> string {
  let d = ((date now) | date to-record)
  $"($d.month)-($d.day)-($d.year)"
}

# Returns the current time.
def time_now [] -> string {
  let d = ((date now) | date to-record)
  $"($d.hour):($d.minute):($d.second)"
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
  print $"Today's Date  \(DD-MM-YYYY\): (ansi light_green)(dmy_date)(ansi reset)"
  let c = cal -t
  print $c
  #print $"Current Repos:"
  #repos-list
}
