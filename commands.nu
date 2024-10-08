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