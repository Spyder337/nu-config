# Returns a list of the soulash 2 entity file paths.
def --env entities [] {
  let sp = [$env.SteamApps,  "Soulash 2", "data", "mods", "core_2"] | path join
  let ep = [$sp, "entities"] | path join
  let old = $env.PWD
  cd $ep
  let entities  = glob $"*.json"
  let entities = $entities | where {
    |e| ($e | (regex "([0-9]+_)([a-zA-Z_]*).json") | length) >= 1
    }
  cd $old
  $entities
}

# Query the soulash entities for an entity with a matching id.
export def --env soulash_item_query_id [
  id: int # Entity Id for an item.
  ] {
  let e = entities
  $e | find $id
}

# Query the soulash entities by name.
export def --env soulash_item_query_str [
  name: string  # Item name.
  ] {
  let e = entities
  $e | find $name
}
