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
  let inserted = insert_quotes $quotes
  rm (dbPath)
  stor export -f (dbPath)
  print $'Inserted Quotes: ($inserted)'
}

# Inserts a list of quotes into the database.
export def insert_quotes [quotes: list<record<
ID: int, 
AUTHOR: string, 
QUOTE: string>>,
--refresh (-r)] -> int {
  let db = stor import -f (dbPath)
  mut cnt = 0
  for $q in $quotes {
    let res = ($db | query db "SELECT * FROM Quotes WHERE QUOTE = :quote" -p {quote:$q.QUOTE})
    if ($res | length) == 0 {
      insert_quote $q
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
# 
# --refresh (-r): Whether to update the database file or leave changes in memory.
export def insert_quote [quote: record<
  ID: int, 
  AUTHOR: string, 
  QUOTE: string>,
  --refresh (-r)] {
  stor insert -t "Quotes" -d $quote
  if $refresh {
    rm (dbPath)
    stor export -f (dbPath)
  }
}

export def quote [--id (-i): int] {
  let q = ((dbPath) | open | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id:$id}) | first
  return $q
}

# Returns a random quote record.
#
# Contains:
# 1. ID
# 2. AUTHOR
# 3. QUOTE
export def "random quote" [] {
  let len = ((dbPath) | open | query db "SELECT * FROM Quotes") | length
  let id = random int 0..($len - 1)
  return (quote -i $id)
}

# Returns the daily quote.
export def daily_quote [] -> string {
  let q = ((dbPath) | open | query db "SELECT * FROM DailyQuote WHERE DOQ=:date" -p {date: (date now | format date "%F")})
  if ($q | length)  == 0 {
    return generate_daily
  } else {
    let i = ($q | first)
    let q = ((dbPath) | open | query db "SELECT * FROM Quotes WHERE ID=:id" -p {id:$i.QUOTE_ID}) | first
    
    return $"\"($q.QUOTE)\"
    - ($q.AUTHOR)"
  }
}

# Generates a new daily note.
export def generate_daily [] -> string {
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