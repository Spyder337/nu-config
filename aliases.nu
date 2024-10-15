#########################
#   Project Creation    #
#########################
alias cdc = default_crates
alias cdac = default_async_crates
alias cdwc = default_web_crates

#########################
#   Change Directory    #
#########################
alias cdr = cd $env.PERSONAL_REPOS
alias cdn = cd $env.NOTES_DIR
alias cdp = cd $env.PLANS_DIR
alias cdnu = cd $env.NU_CONFIG

###################
#   Git Aliases   #
###################
alias ivs = fetch_git_ignore "Visual Studio"
alias irs = fetch_git_ignore "Rust"
alias gc = git clone --depth=1
alias add = git add .
alias com = git commit -m $"Updated: (dmy_date) (time_now)"
alias push = git push

#####################
#   Miscellaneous   #
#####################
alias cat = bat
alias seed = random chars
alias lf = lf-rust
alias repos = repos-list
