# Adds basic crates.
#
# List:
# - Dirs_next
# - Serde
# - Serde_json
# - Lazy_static
export def "init defaults" [] {
  cargo add dirs_next
  cargo add serde --features derive
  cargo add serde_json
  cargo add lazy_static
}

# Adds basic crates and tokio.
export def "init async" [] {
  init defaults
  cargo add tokio --features full
}

# Adds basic, tokio, reqwest and optionally select.
export def "init web" [
  --parsing (-p)  # Adds the select crate for html parsing.
  ] {
  init async
  cargo add reqwest
  if $parsing {
    cargo add select
  }
}

export def --env "new" [
  --type (-t): string,
  --crates (-c): string,
  name: string,
] {

  let t = match $type {
    "bin" => { 
      cargo new $name --edition 2024 --type bin 
    }
    "lib" => {
      cargo new $name --edition 2024 --type lib
    }
    null => {
      cargo new $name --edition 2024
    }
    _ => {
      print -e "Incorrect type. Valid: ['bin', 'lib']"
      null
    }
  }

  if $t == null {
    return null
  }

  # Update Cargo.toml to be compatible with 2024 Rust
  let old = $env.PWD
  cd $name
  mut text = 'cargo-features = ["edition2024"]'
  $text = $text ++ "\n\n" ++ (open -r "Cargo.toml")
  $text | save -f "Cargo.toml"
  
  # Handle adding any crates
  let c = match $crates {
    "basic" =>  {
      (init defaults)
    }
    "async" =>  {
      (init async)
    }
    "web"   =>  {
      (init web)
    }
    _       =>  {
      print "No crates added to the workspace."
    }
  }
  
  # Return to the parent directory
  cd $old
}

# Outputs a list of files in a cargo workspace.
# $env.PWD must be the workspace root.
export def "files" [
  --virtual (-v)  # Enable if there is a virtual workspace.
] {
  let globStr: glob = if $virtual { ("**/src/**/*.{rs, toml}" | into glob) } else { ("src/**/*.{rs, toml}" | into glob) }
  let files = (glob $globStr)
  $files | each { |path|
    let link = $"($path | path relative-to ($env.PWD))"
    $"($path)" | ansi link --text $link
  }
}