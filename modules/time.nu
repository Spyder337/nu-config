# The current time HH:MM:SS
export def main [] -> string {
  let d = ((date now) | date to-record)
  return $"($d.hour):($d.minute):($d.second)"
}

# Returns the day of the week and the date.
export def "full" [] -> record {
  let d = ((date now) | date to-record)
  let m = str month $d.month
  let d = $d.day
  let wd = day_of_week $d
  let d_s = str day $d
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  # Date line ansi
  let ds_s = $env.Themes.dark.accent-700.Code | str replace "#" "0x"
  let ds_e = $env.Themes.dark.accent-400.Code | str replace "#" "0x"
  let date_line = $"($wd) ($m) ($d_s)" | ansi gradient -a $ds_s -b $ds_e
  # Abbreviated Date
  let mdy_s = strings hex_to_ansi $env.Themes.dark.accent-800.Code
  # Combine strings
  let rec = {"DayOfWeek":$wd, "Day": $d_s, "Month":$m, "Date": (mdy)}
  return $rec
}

# Takes in a day of the month and returns the week day for that day.
# 
# If the short flag is supplied than a three letter abbreviation of the day
# is returned.
export def "day_of_week" [ day: int, --short (-s) ]  -> string {
  let c: table = (cal -t)
  # print $"Target Date: ($day)"
  let dow = $c | each {|r|
    if ($"($r.su)" | str contains $"($day)") == true {
      if ($short) {
        return "Sun"
      } else {
        return "Sunday"
      }
    } else if ($"($r.mo)" | str contains $"($day)") == true {
      if ($short) {
        return "Mon"
      } else {
        return "Monday"
      }
    } else if ($"($r.tu)" | str contains $"($day)") == true {
      if ($short) {
        return "Tue"
      } else {
        return "Tuesday"
      }
    } else if ($"($r.we)" | str contains $"($day)") == true {
      if ($short) {
        return "Wed"
      } else {
        return "Wednesday"
      }  
    } else if ($"($r.th)" | str contains $"($day)") == true {
      if ($short) {
        return "Thu"
      } else {
        return "Thursday"
      }  
    } else if ($"($r.fr)" | str contains $"($day)") == true {
      if ($short) {
        return "Fri"
      } else {
        return "Friday"
      }
    } else if ($"($r.sa)" | str contains $"($day)") == true {
      if ($short) {
        return "Sat"
      } else {
        return "Saturday"
      }  
    } else {
      return null
    }
  } | first
  return $dow
}

# Takes a month number and returns the string representation.
export def "str month" [month: int] -> string {
  let m = match $month {
    1 => {"January"},
    2 => {"February"},
    3 => {"March"},
    4 => {"April"},
    5 => {"May"},
    6 => {"June"},
    7 => {"July"},
    8 => {"August"},
    9 => {"September"},
    10 => {"October"},
    11 => {"November"},
    12 => {"December"},
    _ => null
  }
  return $m
}

# Takes a number and changes it to a sequential format 21 => 21st.
export def "str day" [day: int] -> string { 
  let d_s = $"($day)"
  let len = $d_s | str length
  let last_char: string = ($d_s | str substring ($len - 1)..)
  let suffix = match $last_char {
    "1" => "st",
    "2" => "nd",
    "3" => "rd",
    _ => "th"
  }
  return $"($d_s)($suffix)"
}

export def date [--format (-f): string] -> string {
  let res = match $format {
    "dmy" => dmy,
    "ymd" => ymd,
    _ => mdy
  }
  return $res
}

# Returns the Date in the Day-Month-Year format.
def "dmy" [] -> string {
  let d = ((date now) | date to-record)
  $"($d.day)-($d.month)-($d.year)"
}

# Returns the Date in the Month-Day-Year format.
def "mdy" [] -> string {
  let d = ((date now) | date to-record)
  $"($d.month)-($d.day)-($d.year)"
}

# Returns the Date in the Year-Month-Day format.
def "ymd" [] -> string {
  let d = ((date now) | date to-record)
  $"($d.year)-($d.month)-($d.day)"
}