export def dbPath [] {([$env.Nu_Path, "data", "env.db"] | path join)}

export def convert_quotes [] -> none {
  stor import -f (dbPath)
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
  rm (dbPath)
  stor export -f (dbPath)
  print $'Inserted Quotes: ($inserted)'
}

# Inserts a list of quotes into the database.
export def "insert quotes" [quotes: list<record<
ID: int, 
AUTHOR: string, 
QUOTE: string>>,
--refresh (-r)  # If enabled updates the env.db file
] -> int {
  let db = stor import -f (dbPath)
  mut cnt = 0
  for $q in $quotes {
    let res = ($db | query db "SELECT * FROM Quotes WHERE QUOTE = :quote" -p {quote:$q.QUOTE})
    if ($res | length) == 0 {
      (insert quote $q)
      $cnt = $cnt + 1
    }
  }
  if $refresh {
    rm (dbPath)
    stor export -f (dbPath)
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
    $idx = ((dbPath) | open | query db "SELECT * FROM Quotes") | length
  } else {
    $idx = $quote.ID
  }
  # Combine the new id with the old data and insert it in the table.
  stor insert -t "Quotes" -d {ID: $idx, QUOTE: $quote.QUOTE, AUTHOR: $quote.AUTHOR}
  # If we need to update the database then update the file.
  if $refresh {
    rm (dbPath)
    stor export -f (dbPath)
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
    $q = ((dbPath) | open | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id:$id}) | first
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
  let len = ((dbPath) | open | query db "SELECT * FROM Quotes") | length
  let id = random int 0..($len - 1)
  return (get quote -i $id)
}

# Returns the daily quote.
export def daily_quote [] -> string {
  let q = ((dbPath) | open | query db "SELECT * FROM DailyQuote WHERE DOQ=:date" -p {date: (date now | format date "%F")})
  if ($q | length)  == 0 {
    return generate_daily
  } else {
    let i = ($q | first)
    let q = (get quote -i $i.QUOTE_ID)
    
    return $"\"($q.QUOTE)\"
    - ($q.AUTHOR)"
  }
}

# Generates a new daily note.
def generate_daily [] -> string {
  let len =  ((dbPath) | open  | query db "SELECT * FROM DailyQuote") | length
  let qlen = ((dbPath) | open | query db "SELECT * FROM Quotes") | length
  let qid = (random int 0..($qlen - 1))
  let q = ((dbPath) | open | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id: $qid}) | first
  let id = if $len == 0 {0} else {$len - 1}
  let r = {ID:$id, QUOTE_ID: $qid, DOQ: (date now | format date "%F")}
  insert_daily $r
  rm (dbPath)
  stor export -f (dbPath)
  return $q
}

export def insert_daily [daily: record<
  ID: int,
  QUOTE_ID: int,
  DOQ: string
>,
--refresh (-r)] -> {
  stor insert -t DailyQuote -d $daily
  if $refresh {
    rm (dbPath)
    stor export -f (dbPath)
  }
}

export def update_quote [q_id: int] {

}


export def insert_task [task: record<
  ID: int, 
  NAME: string, 
  DESC: string, 
  CREATED: string, 
  DUE: string, 
  COMPLETED: bool>] {

}