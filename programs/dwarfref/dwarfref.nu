let nobles: record = ("data/nobles.json" | open)
let room_tiers: record = ("data/room_qualities.json" | open)
let fortress_tiers: record = ("data/fortress_tiers.json" | open)
let professions: record = ("data/professions.json" | open)
let tips: record = ("data/tips.json" | open)

#print $nobles."Positions"

def get_noble_info (title: string) -> record {
  let t = $nobles | get "Positions" | where {|p| $p.Title == $title} | first
  let r = $room_tiers | get $t."Quarters"
  print $r
  return {}
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

#get_noble_info "Baron"
#get_noble_info "Expedition Leader"
#random_tip
#all_tips