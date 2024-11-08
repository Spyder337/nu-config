use environment.nu
use database.nu
use strings.nu "format day"
# Displays the shell's welcome message.
export def main [] -> string {
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  # The daily quote
  let q = (database daily_quote)
  
  mut msg = $"Welcome (ansi -e $w_c)($env.GitHubUserName)(ansi reset)!"
  $msg = $msg ++ $"\n\n(date msg $w_c)"
  $msg = $msg ++ $"\n\n($q)"
  return $msg
}

# Outputs a message with the current date.
# 
# Format:
# Today is {day} the {day_fmt} of {month}.
# The Date is {mm-dd-yyyy}.
export def "date msg" [
  highlight_code?: record  # Represents an ansi encoding. Fields fg, bg, attr.
  ] -> string {
  # The day as a padded integer string
  let day = (date now | format date "%e") | str replace " " ""
  let d = (format day $day)
  # The day of the week
  let weekDay = (date now | format date "%A")
  # Full month name
  let month = (date now | format date "%B")
  # Full date string
  let date = (date now | format date "%m-%d-%Y")
  mut msg = ""
  if $highlight_code != null {
    $msg = $'Today is (ansi -e $highlight_code)($weekDay)(ansi reset) the (ansi -e $highlight_code)($d)(ansi reset) of (ansi -e $highlight_code)($month)(ansi reset).
The date is (ansi -e $highlight_code)($date)(ansi reset).'
  } else {
    $msg = $'Today is ($weekDay) the ($d) of ($month).
The date is ($date).'
  }
  return $msg
}