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
export def google [query: string, --verbose (-v), --website (-w): string] {
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

# TODO: Take in a query record
# {
#   "Query":"",
#   "Params":{ ... },
#   "Domain":""
# }
# Generate a request url with the record.
# Return the url.
export def build_query [$query: string] -> string {
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

# Fetch a webpage with the url.
export def fetch [url: string] -> string {
  http get -r $url
}