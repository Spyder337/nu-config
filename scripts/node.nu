use git.nu gitignore

export def --env "new" [
  --ts_enabled (-t), 
  --es_lint_enabled (-e),
  name?: string             # If provided creates a directory.
  ] {

  mut steps = 3
  if $ts_enabled {
    $steps = $steps + 4
  }
  if $es_lint_enabled {
    $steps = $steps + 1
  }
  let old = $env.PWD
  print $"\(1/($steps)\) Creating directory..."
  let path = $env.Repos_Dir | path join $name
  mkdir $path
  cd $path
  print $"\(2/($steps)\) Initializing Git..."
  git init
  gitignore "Node"
  print $"\(3/($steps)\) Initializing node project..."
  npm init

  if $ts_enabled {
    print $"\(4/($steps)\) Installing @types/node..."
    npm install --save-dev "@types/node"
    print $"\(5/($steps)\) Installing TypeScript..."
    npm install --save-dev "typescript"
    print $"\(6/($steps)\) Initializing TypeScript..."
    npx tsc --init -t esnext -m esnext
    print $"\(7/($steps)\) Fetching preset files..."
    # Add a curl command to download a index template file
    http get "https://gist.githubusercontent.com/Spyder337/0f661205074f0daf35b8324a4404aefc/raw/18cd00ac66a5c85b0460c41bfb25a096795cd1ae/tsconfig.json" | save -f "tsconfig.json"
    mkdir src
    http get "https://gist.githubusercontent.com/Spyder337/926add4b507252ff9716a9c726c9378b/raw/41114968d718d178a187871c47aa8c7afbf8978d/index.ts" | save "src/index.ts"
    # touch "index.ts"
    
  }


  # TODO: Make this step less painful.
  # There must be a way to load in presets.
  if $es_lint_enabled {
    print "\(8/($steps)\) Installing ES Lint..."
    npm init "@eslint/config@latest" --config eslint-config-standard
  }

  cd $old
}
