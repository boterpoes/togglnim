import
  base64,
  httpclient,
  httpcore,
  json


const TogglApiUrl: string = "https://www.toggl.com/api/v8"


var togglApiToken: string = ""


proc configureTogglApiToken*(token: string) =
  ## Sets the Toggl API token to use.
  ##
  ## This should be called before using any procedure that interacts
  ## with the API.
  togglApiToken = token


proc getTogglAuthHeader(): string =
  "Basic " & encode(togglApiToken & ":api_token")


proc callTogglApiEndpoint(endpoint: string, httpMethod = HttpGet, body = %*{}): Response =
  let
    url: string = TogglApiUrl & endpoint
    headers: HttpHeaders = newHttpHeaders({
      "Content-Type": "application/json",
      "Authorization": getTogglAuthHeader()
    })

  var
    client: HttpClient = newHttpClient()
    res: Response = client.request(url, httpMethod = httpMethod, body = $body, headers = headers)

  res
