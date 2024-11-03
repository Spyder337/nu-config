
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
export def install_emacs [] {
  if (sys host).name == "Windows" {
    winget install GNU.Emacs
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

# Fetch the html document for the page.
export def fetch_web_doc [url: string] -> any {
  try {
    let doc = http get $url
    return $doc
  } catch {
    return null
  }
}

# Fetches the python source page.
export def fetch_python_source [] -> any {
  let url = "https://www.python.org/downloads/source/"
  let doc = fetch_web_doc $url
  return $doc
}

# Fetches the latest python version. 
#
# Source: from https://www.python.org/downloads/source/.
export def fetch_latest_python_version [dl_latest: bool = true] {
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

  http get $link | save ('~/Downloads/python.tgz') --force
  #let dl_link = $doc | query web --query $dss --attribute href | flatten | first
  #print $dl_link
}

# Fetches the latest python version number. 
# 
# This is from the source downloads page on the python website.
export def fetch_latest_python_ver_num [] -> string {
  let vss = "#content > div > section > article > ul > li > a"
  let doc = fetch_python_source
  if ($doc != null) == false {
    return "Could not find the version number."
  }

  let version = $doc | query web --query $vss | flatten | first
  let v = ($version | regex '(\b(([0-9]+)(\.*))+){2,}' | first)."match"
  return $v
}

# Checks if pyton is installed on the system.
export def is_python_installed [] -> bool {
  try {
    if ((sys host).name == "Windows") == true {
      let out = (py -V)
      return true
    }
  } catch {
    return false
  }
}

# Downloads and compiles the newest python version from https://devguide.python.org/versions/#supported-version
export def install_python [] {
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