use environment.nu
use database.nu
# Displays the shell's welcome message.
export def main [] -> string {
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  # The daily quote
  let q = (database daily_quote)
  # The day as a padded integer string
  let day = (date now | format date "%e")
  let d = if ($day | length) == 1 {$"($day)"} else {$" ($day)"}
  # The day of the week
  let weekDay = (date now | format date "%A")
  # Full month name
  let month = (date now | format date "%B")
  # Full date string
  let date = (date now | format date "%m-%d-%Y")
  
  let msg = $"Welcome (ansi -e $w_c)($env.GitHubUserName)(ansi reset)!
Today is (ansi -e $w_c)($weekDay)(ansi reset) the(ansi -e $w_c)($d)(ansi reset) of (ansi -e $w_c)($month)(ansi reset).
The Date is (ansi -e $w_c)($date)(ansi reset)

($q)"
  return $msg
}