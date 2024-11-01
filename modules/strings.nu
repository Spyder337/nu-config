
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
