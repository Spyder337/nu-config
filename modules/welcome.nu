# Displays the shell's welcome message.
export def main [] -> string {
  # The welcome line ansi
  let w_c = strings hex_to_ansi $env.Themes.dark.secondary-500.Code
  let t = time full
  let q = daily_quote
  # print $q
  let msg = $"Welcome (ansi -e $w_c)($env.Git_User_Name)(ansi reset)!
Today is (ansi -e $w_c)($t.DayOfWeek)(ansi reset) the (ansi -e $w_c)($t.Day)(ansi reset) of (ansi -e $w_c)($t.Month)(ansi reset).
The Date is (ansi -e $w_c)($t.Date)(ansi reset)

(into str $q)"
  return $msg
}

# Returns a single quote per day.
#
# Uses env.json to store quotes persistently.
export def daily_quote [] -> table<author: string, quote: string> {
  # Get the current date and the environment from the json file.
  let n = (date now)
  let jpath = $"($env.NU_CONFIG)/../env.json"
  mut jenv = ((open $jpath))
  # Create shorthand references
  let lu = $jenv.DailyQuote."LastQuoteUpdate"
  # print $jenv
  if ($lu != "") {
    let time = ($lu | into datetime)
    let elapsed = (($n - $time) | format duration hr)
    let elapsed = ($elapsed | str replace "hr" "" | into float)
    # print $"Last Generated Quote \(hrs ago\): ($elapsed)"
    # If the time elapsed is less than 24 hrs then return the current quote.
    # Otherwise fall through and generate a new quote.
    if ($elapsed <= 24.0) {
      return $jenv.DailyQuote.LastQuote
    } 
  }
  # If there is no LastQuote or the last quote is older than a day
  # then generate a new quote and update LastQuote and LastQuoteUpdate
  let q = random quote
  $jenv.DailyQuote.LastQuote = $q
  $jenv.DailyQuote.LastQuoteUpdate = (time ymd)
  $jenv | to json | save $jpath --force
  return $jenv.DailyQuote.LastQuote
}

# Outputs a random quote from a provided file.
#
# The file path is nushell/quotes.json
export def "random quote" [] -> table<author: string, quote: string> {
  # Open Quotes Json file
  let quotes = ((open $"($env.NU_CONFIG)/../quotes.json"))
  # Get the keys to iterate through the record
  let keys = $quotes | columns
  # Map each entry in keys into a record with the author and quote.
  let list = $keys | each {|k|
    let q = $quotes | get $k
    let rec = {"author":$k, "quote":$q}
    $rec
  } | flatten
  # Get range for the random int
  let len = ($list | length) - 1
  let idx = random int 0..$len
  # Get the quote
  let q = ($list | select $idx)
  return $q
}

def "into str" [ quote: table<author: string, quote: string> ] -> string {
  $"\"($quote.quote | first)\"
  - ($quote.author | first)"
}