#########################
#   Project Creation    #
#########################
alias cdc = default_crates
alias cdac = default_async_crates
alias cdwc = default_web_crates

#########################
#   Change Directory    #
#########################
alias cdr = cd $env.Personal_Repos
alias cdn = cd $env.Notes_Dir
alias cdp = cd $env.Plans_Dir
alias cfg = cd $env.NU_CONFIG

###################
#   Git Aliases   #
###################
alias ivs = fetch_git_ignore "Visual Studio"
alias irs = fetch_git_ignore "Rust"
alias gc = git clone --depth=1
alias add = git add .
alias com = git commit -m $"Updated: (time dmy) (time)"
alias push = git push

#####################
#   Miscellaneous   #
#####################
alias cd = z
alias cat = bat
alias seed = random chars
alias lf = lf-rust
alias repos = repos-list
alias code = exec r#'C:\Program Files\Microsoft VS Code Insiders\Code - Insiders.exe'#
alias obsidian = exec r#'C:\Users\spyder\AppData\Local\Programs\Obsidian\Obsidian.exe'#
alias emacs = exec r#'C:\Program Files\Emacs\emacs-29.2\bin\emacs.exe'#