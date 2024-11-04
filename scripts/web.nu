# Searches the query on Google.
#
# Query format
# OR => Or operator
# + => And operator
# - => Not operator
# "" => Exact match
#
# Flags:
# - verbose (v): Prints extra information.
# - website (w): Limits search to a website or domain.
export def google_search [query: string, --verbose (-v), --website (-w): string] {
  let rootUrl = 'https://www.google.com/search?'
  mut query = $'q=($query)'

  if ($website != null) {
    $query = $query + $' site:($website)'
  }

  let query = $'($query)' | str replace " " "+"
  let url = $'($rootUrl)($query)'
  if $verbose {
    print $url
  }
  start $url
}

export def build_query [$query: string] -> {
# Google Query Parameters
# &hl=en
# &as_q=Cat+Feline
# &as_epq="Domestic+Cat"
# &as_oq="Maine+Coon"+OR+"Ragamuffin"
# &as_eq=-"Big+Cat"
# &as_nlo=
# &as_nhi=
# &lr=lang_en
# &cr=
# &as_qdr=all
# &as_sitesearch=wikipedia.org
# &as_occt=any
# &as_filetype=
# &tbs=
}

export def fetch_html [url: string] -> string {
  http get -r $url
}