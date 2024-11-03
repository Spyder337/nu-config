# Fetches a .gitignore file from the official gitignore repo.
#
# Requires an ignore file name that matches one in their repo.
export def "gitignore" [ignore_file: string] {
  let url = $"($env.GitIgnoreRepoUrl)($ignore_file).gitignore"
  http get $url | save ".gitignore"
}

# Displays a list of current git repos.
#
# include_paths: Whether to include the path to the repo in the table.
export def list [--include_paths (-i)] -> table {
  let ignored_dirs = ["**/.git", "**/.obsidian", "**/*.md", "**/plans/**"]
  let res  = glob ~/repos/*/* --exclude $ignored_dirs | each {|p|
    let parent = $"(($p | path dirname) | path basename)"
    mut r_type = $""
    let r_name = $"($p | path basename)"
    match $parent {
      "Spyder337" => {$r_type = "Working"},
      "cloned" => {$r_type = "Others"},
      _ => {}
    }
    mut row = {"Type":$"($r_type)", "Repo Name":($p | ansi link --text $"($r_name)")}
    if ($include_paths) {
      $row = $row | insert  "Path" {$p}
    }
    $row
  }
  let t = ($res | table)
  return $t
}

export def ls [] -> list {
  return ((git ls-files --exclude-standard ':!:.vs/*' ':!:*.json' ':!:*.css' ':!:.gitignore' ':!:*.md') | split row "\n")
}