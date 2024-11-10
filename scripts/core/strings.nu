# Converts hex strings to an ansi format.
export def hex_to_ansi [foreground: string, background: string = "", attr: string = ""] -> record {
  mut $r = {}
  $r = $r | insert fg $foreground
  if (($background | str length ) >= 1) {
    $r = $r | insert bg $background
  }
  if (($attr | str length ) >= 1) {
    $r = $r | insert attr $attr
  }
  return $r
}

# Converts a css theme into a record for ansi.
export def css_to_nushell [theme: string] -> record {
  let vals = $theme | lines
  mut themes = {}
  mut curr_theme = ""
  mut rec = {}
  for val in $vals {
    if ($val | str length) == 0 {
      continue
    }
    if ($val | str starts-with ":") {
      $curr_theme = ($val | regex '"[a-zA-Z0-9]+"').match | first | str replace -a '"' ''
      # print $curr_theme
    } else if ($val | str starts-with "}") {
      let $r = $rec
      $themes = $themes | insert $curr_theme { $r }
      $rec = {}
      $curr_theme = ""
    } else {
      let name = ($val | regex '([a-z|0-9]+\-*([0-9]*))').match | first
      let hex_code = ($val | regex "#([a-f|0-9]{1,6})").match | first
      let vis = $'(ansi -e (hex_to_ansi $hex_code))(char --unicode "2B1B")(ansi reset)'
      $rec = $rec | insert $name { Code: $hex_code, Appearance: $vis }
    }
  }
  return $themes
}

export def save_nushell_theme [theme: record] {
  print $theme | to json
}

export def dokkodo [] -> string {
  mut out = ""
  let path = [$env.Nu_Path, "data", "dokkodo.json"] | path join
  mut lines = ($path | open -r) | lines
  $lines = $lines | skip 1 | take (($lines | length) - 2)
  $lines = $lines | each {|l| $l | str replace -a "\\\"" "" | str replace "," ""}
  let len = $lines | length
  let rule_ansi = {
    fg: $'($env.Themes.simple.accent.Code)'
  }
  let text_ansi = {
    fg: $'($env.Themes.simple.text.Code)'
  }
  $out = $out ++ $'(ansi -e $text_ansi)Dokkōdō by Miyamoto Musashi
'
  for i in 0..($len - 1) {
    $out = $out ++ $'(ansi -e $rule_ansi)Rule ($i + 1):(ansi reset)
'
    $out = $out ++ $'(ansi -e $text_ansi)($lines | get $i)(ansi reset)
    
'
  }
  $out
}

export def "format day" [$num: string] {
  let c = $'($num)' | split chars | last
  mut postfix = ""
  match $c {
    "1" => {$postfix = "st"}
    "2" => {$postfix = "nd"}
    "3" => {$postfix = "rd"}
    _ => {$postfix = "th"}
  }
  return $'($num)($postfix)'
}