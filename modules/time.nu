# The current time HH:MM:SS
export def main [] -> string {
  let d = ((date now) | date to-record)
  return $"($d.hour):($d.minute):($d.second)"
}

#Description:
#Returns the day of the week and the date.
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

#Description:
#Takes in a day of the month and returns the week day for that day.
export def "day_of_week" [ day: int ]  -> string {
  let c: table = (cal -t)
  # print $"Target Date: ($day)"
  let dow = $c | each {|r|
    if ($"($r.su)" | str contains $"($day)") == true {
      return "Sunday"
    } else if ($"($r.mo)" | str contains $"($day)") == true {
      return "Monday"
    } else if ($"($r.tu)" | str contains $"($day)") == true {
      return "Tuesday"
    } else if ($"($r.we)" | str contains $"($day)") == true {
      return "Wednesday"
    } else if ($"($r.th)" | str contains $"($day)") == true {
      return "Thursday"
    } else if ($"($r.fr)" | str contains $"($day)") == true {
      return "Friday"
    } else if ($"($r.sa)" | str contains $"($day)") == true {
      return "Saturday"
    } else {
      return null
    }
  } | first
  return $dow
}

# Takes a month number and returns the string representation.
export def "str month" [month: int] -> string {
  if ($month == 1) {
    return "January"
  } else if ($month == 2) {
    return "February"
  } else if ($month == 3) {
    return "March"
  } else if ($month == 4) {
    return "April"
  } else if ($month == 5) {
    return "May"
  } else if ($month == 6) {
    return "June"
  } else if ($month == 7) {
    return "July"
  } else if ($month == 8) {
    return "August"
  } else if ($month == 9) {
    return "September"
  } else if ($month == 10) {
    return "October"
  } else if ($month == 11) {
    return "November"
  } else if ($month == 12) {
    return "December"
  }
}

# Takes a number and changes it to a sequential format 21 => 21st.
export def "str day" [day: int] -> string {
  let d_s = $"($day)"
  let len = $d_s | str length
  if ($d_s | str ends-with "1") {
    return $"($d_s)st"
  } else if ($d_s | str ends-with "2") {
    return $"($d_s)nd"
  } else if ($d_s | str ends-with "3") {
    return $"($d_s)rd"
  } else {
    if ((($d_s | str ends-with "0") == true) and ((($len == 1) == true))) {
      return $d_s
    }
    return $"($d_s)th"
  }
}

# Returns the Date in the Day-Month-Year format.
export def "dmy" [] -> string {
  let d = ((date now) | date to-record)
  $"($d.day)-($d.month)-($d.year)"
}

# Returns the Date in the Month-Day-Year format.
export def "mdy" [] -> string {
  let d = ((date now) | date to-record)
  $"($d.month)-($d.day)-($d.year)"
}