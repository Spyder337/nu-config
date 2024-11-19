export def refresh [] -> none {
  rm ($env.DatabasePath)
  stor export -f ($env.DatabasePath)
}

export def convert_quotes [] -> none {
  let quotes = (([$env.Nu_Path, "data", "quotes.json"] | path join) | open | into record)
  let keys = $quotes | columns
  mut quotes  = []
  for $key in $keys {
    let author = $key
    let qlen = $quotes | get $key | length
    for $quote in ($quotes | get $key) {
      $quotes = $quotes ++ {"AUTHOR": $author, "QUOTE": $quote}
    }
  }
  let inserted = (insert quotes -r $quotes)
  print $'Inserted Quotes: ($inserted)'
}

# Inserts a list of quotes into the database.
export def "insert quotes" [quotes: list<record<
ID: int, 
AUTHOR: string, 
QUOTE: string>>,
--refresh (-r)  # If enabled updates the env.db file
] -> int {
  mut cnt = 0
  for $q in $quotes {
    let res = ($env.Database | query db "SELECT * FROM Quotes WHERE QUOTE = :quote" -p {quote:$q.QUOTE})
    if ($res | length) == 0 {
      (insert quote $q)
      $cnt = $cnt + 1
    }
  }
  if $refresh {
    refresh
  }
  return $cnt
}

# Inserts a quote into the sqlite database.
export def "insert quote" [quote: record<
  AUTHOR: string, 
  QUOTE: string>,
  --refresh (-r)  # If enabled updates the env.db file
  ] {
  # If the id for the quote is out of bounds generate a new one.
  # Combine the new id with the old data and insert it in the table.
  stor insert -t "Quotes" -d {QUOTE: $quote.QUOTE, AUTHOR: $quote.AUTHOR}
  # If we need to update the database then update the file.
  if $refresh {
    refresh
  }
}

# Returns a quote.
# 
# If id is null then a random quote is returned.
# Otherwise a quote with a matching id is returned.
export def "get quote" [
  --id (-i): int  # Quote ID in the database.
  ] {
  mut q = null
  if $id != null {
    $q = ($env.Database | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id:$id}) | first
  } else {
    $q = (random quote)
  }
  return $q
}

# Returns a random quote record.
#
# Contains:
# 1. ID
# 2. AUTHOR
# 3. QUOTE
def "random quote" [] {
  let len = ($env.Database | query db "SELECT COUNT(*) FROM Quotes").0."COUNT(*)"
  let id = random int 0..($len - 1)
  return (get quote -i $id)
}

# Returns the daily quote as a formatted string.
export def "get daily quote" [] -> string {
  let q = ($env.Database | query db "SELECT * FROM DailyQuote WHERE DOQ=:date" -p {date: (date now | format date "%F")})
  mut quote = {}
  if ($q | length)  == 0 {
    $quote = generate daily
  } else {
    let i = ($q | first)
    $quote = (get quote -i $i.QUOTE_ID)
  }
    
  return $"\"($quote.QUOTE)\"
  - ($quote.AUTHOR)"
}

# Generates a new daily note.
def "generate daily" [] -> string {
  let len =  ($env.Database | query db "SELECT * FROM DailyQuote") | length
  let qlen = ($env.Database | query db "SELECT COUNT(*) FROM Quotes").0."COUNT(*)"
  let qid = (random int 0..($qlen - 1))
  let q = ($env.Database | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id: $qid}) | first
  let r = {QUOTE_ID: $qid, DOQ: (date now | format date "%F")}
  insert daily $r -r
  return $q
}

# Insert a new daily quote entry.
# Used to generate the daily quote only.
def "insert daily" [daily: record<
  QUOTE_ID: int,
  DOQ: string
>,
--refresh (-r)
] -> {
  stor insert -t DailyQuote -d $daily
  if $refresh {
    refresh
  }
}

# Updates a quote with the new values provided in the record.
#
# The keys in data must match the columns for Quotes.
# - ID
# - AUTHOR
# - QUOTE
export def "update quote" [
  q_id: int,      # Quote id.
  data: record,   # Record containing the keys to update for the quote.
] {
  let keys = $data | columns
  mut queryStr = $""
  for $key in $keys {
    if ($key == ($keys | last)) {
      $queryStr = $queryStr ++ " = " ++ $key
    } else {
      $queryStr = $queryStr ++ " = " ++ $key ++ ", \n"
    }
  }
  $queryStr = $"UPDATE Quotes ($queryStr) WHERE ID=:id"
  let res = ($env.Database | query db $queryStr -p {id: $q_id})
}

export def "insert env" [
  val: record<Key: string, Value: string>
  --refresh (-r) # If enabled updates the env.db file
] {
  let envVar = {KEY: $val.Key, VALUE: $val.Value}
  stor insert -t Env -d $envVar
  if $refresh {
    refresh
  }
}

# Get environment variable by a column and a value.
export def "get env" [
  query?: record<Key: string, Val: string>   # COLUMN and value to filter by.
] -> {
  mut qStr = $"SELECT * FROM"

  if $query != null {
    $qStr = $qStr ++ $" WHERE ($query.Key) = ($query.Val)"
  }

  let res = $env.Database | query db $qStr
  if ($res | is-empty) {
    return null
  } else {
    return ($res | first)
  }
}

export def "count" [table: string, condition?: string] {
  mut query = $"SELECT COUNT\(*\) FROM ($table)"
  if $condition != null {
    $query = $query ++ $" WHERE ($condition)"
  }
  let res = $env.Database | query db $query
  return $res."COUNT(*)".0
}

# Insert a task record into the database.
export def "insert task" [task: record<
  NAME: string, 
  DESC: string,
  TYPE: int, 
  CREATED: string, 
  DUE: string, 
  COMPLETED: bool>,
  --refresh (-r)  # If enabled updates the env.db file
  ] -> bool {
    try {
      stor insert -t Tasks -d $task
      if $refresh {
        refresh
      }
      return true
    } catch {
      return false
    }
}

# Gets a specific task or all.
export def "get task" [
  --all (-a),   # Gets all tasks from the database.
  id?: int      # Id must be present if the all flag is not used.
] {
  mut $res = [[];[]]
  if not $all {
    if $id == null {
      print "Invalid flag and parameter combination. See help."
      return null
    } else {
      $res = $env.Database | query db "SELECT * FROM Tasks WHERE ID=:id" -p {id:$id}
      if ($res | is-empty) {
        return null
      }
      return ($res | first | into record)
    }
  } else {
    $res = $env.Database | query db "SELECT * FROM Tasks"
    return $res
  }
}

# Updates a task with new values.
# 
# Valid Keys
# ID
# NAME
# DESC
# CREATED
# DUE
# COMPLPETED
export def "update task" [
    id: int         # Id of the task to update.
    data: record    # Record containing the columns to update.
  ] -> bool {
  try {
    stor update -t Tasks -u $data -w $"ID = ($id)"
    refresh
    return true
  } catch {
    return false
  }
}

# Returns all tasks with flags to filter completed.
export def getTasks [
  --complete      # If set returns the completed tasks
  --incomplete    # If set returns the incomplete tasks
] {
  if ($incomplete and $complete) {
    print "Incompatible flags. --incomplete and --complete are mutually exclusive."
    return null
  }
  
  mut query = ""
  if $incomplete {
    $query = $query ++ "WHERE COMPLETED = 0"
  } else if $complete {
    $query = $query ++ "WHERE COMPLETED = 1"
  }
  mut tasks = $env.Database | query db $"SELECT * FROM Tasks ($query)"
  $tasks
}

# Removes a task from the database if it exists.
export def "delete task" [id: int] -> bool {
  try {
    stor delete -t Tasks -w $"ID = ($id)"
    refresh
    return true
  } catch {
    return false
  }
}