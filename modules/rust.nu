# Adds basic crates.
#
# List:
# - Dirs_next
# - Serde
# - Serde_json
# - Lazy_static
export def default_crates [] {
  cargo add dirs_next
  cargo add serde --features derive
  cargo add serde_json
  cargo add lazy_static
}

# Adds basic crates and tokio.
export def default_async_crates [] {
  default_crates
  cargo add tokio --features full
}

# Adds basic, tokio, reqwest and optionally select.
export def default_web_crates [parsing: bool] {
  default_async_crates
  cargo add reqwest
  if $parsing {
    cargo add select
  }
}
