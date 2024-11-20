# The current time HH:MM:SS
export def main [
  --full (-f),      # If enabled prints the date and time. 
  date?: datetime   # Optional date to parse. Otherwise 'date now' is used.
  ] -> string? {
  mut str = null
  if $date == null  {
    if $full {
      $str = ((date now) | format date "%F %T")
    } else {
      $str = ((date now) | format date "%F")
    }
  }
  if $full {
    $str = ($date | format date "%F %T")
  } else {
    $str = ($date | format date "%F")
  }
  return $str
}