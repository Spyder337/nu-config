# The current time HH:MM:SS
export def main [] -> string {
  let d = ((date now) | format date "%T")
  return $d
}