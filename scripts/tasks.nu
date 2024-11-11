use ./lib/database.nu
use ./lib/time.nu

# Displays all current tasks or a task if an id is provided.
export def main [id?: int] {
  if $id == null {
    let tasks = (database get task -a)
    for $t in $tasks {
      print (display ($t | into record))
    }
  } else {
    let t = (database get task $id)
    print (display ($t | into record))
  }
}

# Create a new task
export def --env new [] {
  let name = input "Task Name: "
  let desc = input "Task Desc: "
  let type = (input "Task Type: " | into int)
  let created = $'(date now | format date "%F %T")'
  let due = (input "Due date (YYYY-MM-DD HH:mm:ss): ")
  let completed = (input "Completed (true|false): " | into bool)
  let id = (database get task -a | length)
  let rec = {ID:$id, NAME:$name, DESC:$desc, TYPE:$type, CREATED:$created, DUE:$due, COMPLETED:$completed}
  stor insert -t Tasks -d $rec
  database refresh
  return null
}

def within [dur: duration] -> list<record> {
  mut tasks = $env.Database | query db "SELECT * FROM Tasks"
  let start = (date now)
  let end = $start + $dur
  let timeframe = [["Start" "End"]; [(time $start) (time $end)] [($start | format date "%T") ($end | format date "%T")]]
  $tasks = $tasks | where {|t| $t | ($t.DUE | into datetime) <= $end }
  print $timeframe
  $tasks
}

# Print tasks for the current week.
export def week [] -> list<record> {
  let $tasks = within 1wk | select NAME DUE COMPLETED ID
  $tasks
}

# Print tasks for the month.
export def month [] -> list<record> {
  mut tasks = within 4wk | select NAME DUE COMPLETED ID
  $tasks
}

# Print tasks for the year.
export def year [] {
  mut tasks = within 54wk | select NAME DUE COMPLETED ID
  $tasks
}

def display [task: record<ID: int, DESC: string, NAME: string, CREATED: string, DUE: string, COMPLETED: int, TYPE: int>] {
  let com = if $task.COMPLETED == 0 {char -u "274E"} else {char -u "2611"}
  let due = ($task.DUE | format date "%A, %B, %d%n%tAt %T")
  mut $msg = ""
  $msg = $msg ++ $"Task: ($task.NAME)\n"
  $msg = $msg ++ $"Desc: ($task.DESC)\n"
  $msg = $msg ++ $"Due: ($due)\n"
  $msg = $msg ++ $"Completed: ($com)\n"
  return $msg
}