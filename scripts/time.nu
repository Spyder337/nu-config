# The current time HH:MM:SS
export def main [] -> string {
  let d = ((date now) | format date "%T")
  return $d
}

# An update string for commit messages.
#
# The format is
# 'Updated:   Year-Month-Day
#             HH:MM:SS
# 
# Changess:
# - change 1
# - change 2
# ... rest
export def "update msg" [--changes (-c): list<string>] {
  mut msg = $'Updated: ((date now | format date "%t%F%n%t%t%T"))'
  $msg = $msg ++ "\n\nChanges:\n"
  if $changes != null {
    for $i in $changes {
      $msg = $msg ++ $"- ($i)\n"
    }
  }
  $msg
}