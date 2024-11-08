export def convert_quotes [] -> none {
  let quotes = (([$env.Nu_Path, "data", "quotes.json"] | path join) | open | into record)
  let keys = $quotes | columns
  mut cnt = 0;
  mut quotes  = []
  for $key in $keys {
    let author = $key
    let qlen = $quotes | get $key | length
    for $quote in ($quotes | get $key) {
      $quotes = $quotes ++ {"ID": $cnt, "AUTHOR": $author, "QUOTE": $quote}
      $cnt = $cnt + 1
    }
  }
  let inserted = (insert quotes $quotes)
  rm ($env.DatabasePath)
  stor export -f ($env.DatabasePath)
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
    rm ($env.DatabasePath)
    stor export -f ($env.DatabasePath)
  }
  return $cnt
}

# Inserts a quote into the sqlite database.
export def "insert quote" [quote: record<
  ID: int, 
  AUTHOR: string, 
  QUOTE: string>,
  --refresh (-r)  # If enabled updates the env.db file
  ] {
  # If the id for the quote is out of bounds generate a new one.
  mut idx = -1
  if $quote.ID == -1 {
    $idx = ($env.Database | query db "SELECT * FROM Quotes") | length
  } else {
    $idx = $quote.ID
  }
  # Combine the new id with the old data and insert it in the table.
  stor insert -t "Quotes" -d {ID: $idx, QUOTE: $quote.QUOTE, AUTHOR: $quote.AUTHOR}
  # If we need to update the database then update the file.
  if $refresh {
    rm ($env.DatabasePath)
    stor export -f ($env.DatabasePath)
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
  let len = ($env.Database | query db "SELECT * FROM Quotes") | length
  let id = random int 0..($len - 1)
  return (get quote -i $id)
}

# Returns the daily quote.
export def daily_quote [] -> string {
  let q = ($env.Database | query db "SELECT * FROM DailyQuote WHERE DOQ=:date" -p {date: (date now | format date "%F")})
  mut quote = {}
  if ($q | length)  == 0 {
    $quote = generate_daily
  } else {
    let i = ($q | first)
    $quote = (get quote -i $i.QUOTE_ID)
  }
    
  return $"\"($quote.QUOTE)\"
  - ($quote.AUTHOR)"
}

# Generates a new daily note.
def generate_daily [] -> string {
  let len =  ($env.Database | query db "SELECT * FROM DailyQuote") | length
  let qlen = ($env.Database | query db "SELECT * FROM Quotes") | length
  let qid = (random int 0..($qlen - 1))
  let q = ($env.Database | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id: $qid}) | first
  let id = if $len == 0 {0} else {$len - 1}
  let r = {ID:$id, QUOTE_ID: $qid, DOQ: (date now | format date "%F")}
  insert_daily $r -r
  return $q
}

export def insert_daily [daily: record<
  ID: int,
  QUOTE_ID: int,
  DOQ: string
>,
--refresh (-r)
] -> {
  stor insert -t DailyQuote -d $daily
  if $refresh {
    rm ($env.DatabasePath)
    stor export -f ($env.DatabasePath)
  }
}

export def update_quote [q_id: int] {

}

export def "insert env" [
  val: record<Key: string, Value: string>
  --refresh (-r) # If enabled updates the env.db file
] {
  let id = ($env.Database | query db "SELECT * FROM Env" | length)
  let envVar = {ID: $id, KEY: $val.Key, VALUE: $val.Value}
  stor insert -t Env -d $envVar
  if $refresh {
    rm ($env.DatabasePath)
    stor export -f ($env.DatabasePath)
  }
}


export def insert_task [task: record<
  ID: int, 
  NAME: string, 
  DESC: string, 
  CREATED: string, 
  DUE: string, 
  COMPLETED: bool>] {

}