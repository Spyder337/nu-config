use lib/environment.nu
use lib/database.nu
use lib/strings.nu "format day"
use lib/strings.nu escape
use lib/strings.nu encode
use tasks.nu
# Displays the shell's welcome message.
export def main [
  --clear (-c)  # Clears the screen before displaying the welcome message.  
] -> none {
  # The welcome line ansi
  let w_c = escape -f ($env.Themes.dark.secondary-500.Code)
  # The daily quote
  let q = (database get daily quote)
  
  mut msg = $"Welcome (ansi -e $w_c)($env.GitHubUserName)(ansi reset)!"
  $msg = $msg ++ $"\n\n(main date $w_c)"
  $msg = $msg ++ $"\n\n($q)"
  if $clear {
    clear -k
  }
  print $msg
  tasks week
}

# Outputs a message with the current date.
# 
# Format:
# Today is {day} the {day_fmt} of {month}.
# The Date is {mm-dd-yyyy}.
export def "main date" [
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
    $msg = $'Today is (encode $highlight_code $weekDay) the '
    $msg = $msg ++ $"(encode $highlight_code $d) of (encode $highlight_code $month)."
    $msg = $msg ++ "\n" ++ $"The date is (encode $highlight_code $date)."
  } else {
    $msg = $'Today is ($weekDay) the ($d) of ($month).'
    $msg = $msg ++ "\n" ++ $'The date is ($date).'
  }
  return $msg
}