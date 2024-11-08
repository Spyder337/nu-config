#########################
#   Project Creation    #
#########################
alias cdc = rust crates_default
alias cdac = rust crates_async
alias cdwc = rust crates_web

#########################
#   Change Directory    #
#########################
alias cdr = cd $env.Personal_Repos
alias cdn = cd $env.Notes_Dir
alias cdp = cd $env.Plans_Dir
alias cfg = cd $env.NU_CONFIG

###################
#   Git aliases   #
###################
alias ivs = git gitignore "Visual Studio"
alias irs = git gitignore "Rust"
alias gc = git clone --depth=1
alias add = git add .
alias com = git commit -m $"Updated: (date now | format date '%t%F%n%t%t%T')"
alias push = git push

#####################
#   Miscellaneous   #
#####################
alias core-cd = cd
# use environment cd
# alias cd = environment cd
alias cat = bat
alias seed = random chars
alias lf = rust files
alias repos = git list
alias code = exec $env.Editor
alias obsidian = exec r#'C:\Users\spyder\AppData\Local\Programs\Obsidian\Obsidian.exe'#
alias emacs = exec r#'C:\Program Files\Emacs\emacs-29.2\bin\emacs.exe'#
alias gs = google_search
alias ys = google_search -w "www.youtube.com"
alias clr = clear -k