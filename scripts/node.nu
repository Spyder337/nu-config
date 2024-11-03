export def create_npm_project [--ts_enabled (-t), --es_lint_enabled (-e)] {
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
    http get "https://gist.githubusercontent.com/Spyder337/926add4b507252ff9716a9c726c9378b/raw/41114968d718d178a187871c47aa8c7afbf8978d/index.ts" | save "index.ts"
    # touch "index.ts"
  }

  if $es_lint_enabled {
    print "Installing ES Lint..."
    npm init "@eslint/config@latest"
  }
}
