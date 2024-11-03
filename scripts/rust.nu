# Adds basic crates.
#
# List:
# - Dirs_next
# - Serde
# - Serde_json
# - Lazy_static
export def "crates_defaults" [] {
  cargo add dirs_next
  cargo add serde --features derive
  cargo add serde_json
  cargo add lazy_static
}

# Adds basic crates and tokio.
export def "crates_async" [] {
  crates_defaults
  cargo add tokio --features full
}

# Adds basic, tokio, reqwest and optionally select.
export def "crates_web" [--parsing (-p)] {
  crates_async
  cargo add reqwest
  if $parsing {
    cargo add select
  }
}

export def "files" [] {
  let files = (glob **/src/**/*.{rs, toml})
  $files | each { |path|
    let link = $"($path | path relative-to ($env.PWD))"
    $"($path)" | ansi link --text $link
  }
}