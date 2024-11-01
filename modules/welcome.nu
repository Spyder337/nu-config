# Displays the shell's welcome message.
export def main [] {
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  let t = time full
  print $"Welcome (ansi -e $w_c)($env.Git_User_Name)(ansi reset)!
Today is (ansi -e $w_c)($t.DayOfWeek)(ansi reset) the (ansi -e $w_c)($t.Day)(ansi reset) of (ansi -e $w_c)($t.Month)(ansi reset).
The Date is (ansi -e $w_c)($t.Date)(ansi reset)"
}