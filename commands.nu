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

def fetch_git_ignore [ignore_file: string] {
    let url = $"($env.GitIgnore_Repo_Base_URL)($ignore_file).gitignore"
    http get $url | save ".gitignore"
}

def nu_plugins [] {
    let plugins = glob ~/.cargo/bin/nu_plugin_*.*
    return $plugins
}

def add_plugins [] {
    let plugins = nu_plugins
    $plugins | each {|plugin_name|
        plugin add $plugin_name
    }
}

def source_completions [] {
    source ./completions/git-completions.nu
    source ./completions/gh-completions.nu
    source ./completions/cargo-completions.nu
    source ./completions/bat-completions.nu
    source ./completions/rustup-completions.nu
    source ./completions/vscode-completions.nu
    source ./completions/ssh-completions.nu
    source ./completions/curl-completions.nu
}

def install_emacs [] {
    if (sys host).name == "Windows" {
        print "This function is unavailable on Windows."
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

def new_node_project [ts_enabled: bool = true, es_lint_enabled: bool = true] {
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

def dmy_date [] {
    let d = ((date now) | date to-record)
    $"($d.day)-($d.month)-($d.year)"
}

def mdy_date [] {
    let d = ((date now) | date to-record)
    $"($d.month)-($d.day)-($d.year)"
}

def time_now [] {
    let d = ((date now) | date to-record)
    $"($d.hour):($d.minute):($d.second)"
}