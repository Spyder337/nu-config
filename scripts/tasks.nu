use ./lib/database.nu
use ./lib/time.nu
use ./lib/strings.nu [encode escape]

# Displays all current tasks or a task if an id is provided.
export def main [
  id?: int            # If provided gets the task matching the id.
  --incomplete (-i)   # If enabled only prints incomplete tasks.
  --complete (-c)     # If enabled only prints complete tasks.
  ] {
  if ($incomplete and $complete) {
    print "Incompatible flags. --incomplete and --complete are mutually exclusive."
    return null
  }

  if $id == null {
    mut tasks = null
    if $incomplete {
      $tasks = database getTasks --incomplete
    } else if $complete {
      $tasks = database getTasks --complete
    } else {
      $tasks = database getTasks
    }
    for $t in $tasks {
      print (display ($t | into record))
    }
  } else {
    let t = (database get task $id)
    if ($t == null) {
      print $"Could not find a task with ID=($id)"
      return null
    }
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
  let rec = {NAME:$name, DESC:$desc, TYPE:$type, CREATED:$created, DUE:$due, COMPLETED:$completed}
  stor insert -t Tasks -d $rec
  database refresh
  return null
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

# Marks a task as completed.
export def mark [
  id: int   # Task to mark.
  ] -> none {
  database update task $id {COMPLETED: 1}
}

# Marks a task as incomplete.
export def unmark [
  id: int   # Task to unmark.
  ] -> none {
  database update task $id {COMPLETED: 0}
}

export def remove [id: int] {
  database delete task $id
}

def display [task: record<ID: int, DESC: string, NAME: string, CREATED: string, DUE: string, COMPLETED: int, TYPE: int>] {
  let com = if $task.COMPLETED == 0 {char -u "274E"} else {char -u "2705"}
  let due = ($task.DUE | format date "%A, %B, %d%n%tAt %T")
  let label = escape --foreground "#FFFFFF"
  let content = escape --foreground "#FFBBFF"
  mut $msg = "\n"
  $msg = $msg ++ $'(encode $label $"Task \(($task.ID)\): ")'
  $msg = $msg ++ $'(encode $content $task.NAME)' ++ "\n"
  $msg = $msg ++ (encode $label $"Desc: ") ++ (encode $content $task.DESC) ++ "\n"
  $msg = $msg ++ (encode $label $"Due: ") ++ (encode $content $task.DUE) ++ "\n"
  $msg = $msg ++ (encode $label $"Completed: ") ++ ($com)
  return $msg
}

def within [
  dur: duration
  ] -> list<record> {
  mut tasks = database getTasks
  let start = (date now)
  let end = $start + $dur
  let timeframe = [["Start" "End"]; [(time $start) (time $end)] [($start | format date "%T") ($end | format date "%T")]]
  $tasks = $tasks | where {|t|
    let due = $t.DUE | into datetime
    # print $"DUE: ($due)\nEND: ($end)\n"
    ($due <= $end) and ($due >= $start) 
  }
  print $timeframe
  $tasks
}
