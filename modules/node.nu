
export def create_npm_project [ts_enabled: bool = true, es_lint_enabled: bool = true] {
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
