let nobles: record = ("data/nobles.json" | open)
let room_tiers: record = ("data/room_qualities.json" | open)
let fortress_tiers: record = ("data/fortress_tiers.json" | open)
let professions: record = ("data/professions.json" | open)
let tips: record = ("data/tips.json" | open)

#print $nobles."Positions"

def get_noble_info (title: string) -> record {
  let t = $nobles | get "Positions" | where {|p| $p.Title == $title} | first
  let keys = $t | columns
  print $"Position: ($t."Title")"
  print $"Url: ($t."Url")"
  let t = table
  mut vals = {
    "Quarters":{}, 
    "Office":{}, 
    "Dining Room":{}, 
    "Tomb":{}
  }
  if ($keys | any {|k| $k | str contains "Quarters"}) {
    let idx = $t."Quarters" | into int
    let name = (($room_tiers."Tiers" | get $idx)."Descriptors")."Quarters"
    $vals.Quarters = {"Tier":$idx, "Name":$name}
  }
  if ($keys | any {|k| $k | str contains "Office"}) {
    let idx = $t."Office" | into int
    let name = (($room_tiers."Tiers" | get $idx)."Descriptors")."Office"
    $vals.Office = {"Tier":$idx, "Name":$name}
  }
  if ($keys | any {|k| $k | str contains "Dining Room"}) {
    let idx = $t."Dining Room" | into int
    let name = (($room_tiers."Tiers" | get $idx)."Descriptors").'Dining Room'
    $vals.'Dining Room' = {"Tier":$idx, "Name":$name}
  }
  if ($keys | any {|k| $k | str contains "Tomb"}) {
    let idx = $t."Tomb" | into int
    let name = (($room_tiers."Tiers" | get $idx)."Descriptors")."Tomb"
    $vals.Tomb = {"Tier":$idx, "Name":$name}
  }
  if ($vals | values | all {|v| $v == ""}) == true {
    print ""
  } else {
    print ($vals | table)
    print ""
  }
  # print $keys
}

def random_tip () -> string {
  let num = random int 0..(($tips."Tips" | length) - 1)
  let tip = $tips."Tips" | get $num
  return $tip
}

def all_tips () -> string {
  let t = $tips."Tips"
  return $t
}

get_noble_info "Baron"
get_noble_info "Expedition Leader"
random_tip
#all_tips