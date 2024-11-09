# Lists all current tasks.
export def main [id?: int] {
  if $id == null {
    database get task -a
  } else {
    database get task $id
  }
}

export def create [] {
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
}