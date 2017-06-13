import
  base64,
  httpclient,
  httpcore,
  json


const TogglApiUrl: string = "https://www.toggl.com/api/v8"


var togglApiToken: string = ""


type
  TogglUser* = ref object of RootObj
    ## An object wrapper around a Toggl userprofile.
    apiToken*: string
    defaultWid*: uint
    email*: string
    fullname*: string
    jqueryTimeOfDayFormat*: string
    jqueryDateFormat*: string
    timeOfDayFormat*: string
    dateFormat*: string
    storeStartAndStopTime*: bool
    beginningOfWeek*: uint
    language*: string
    imageUrl*: string
    sidebarPiechart*: bool
    sendProductEmails*: bool
    sendWeeklyReport*: bool
    sendTimerNotifications*: bool
    openIdEnabled*: bool
    timezone*: string


proc newTogglUser(data: JsonNode): TogglUser =
  ## Create a new TogglUser instance from Json data as returned by
  ## the Toggl API.
  TogglUser(
    apiToken: data["api_token"].getStr(),
    defaultWid: uint(data["default_wid"].getNum()),
    email: data["email"].getStr(),
    fullname: data["fullname"].getStr(),
    jqueryTimeOfDayFormat: data["jquery_timeofday_format"].getStr(),
    jqueryDateFormat: data["jquery_date_format"].getStr(),
    timeOfDayFormat: data["timeofday_format"].getStr(),
    dateFormat: data["date_format"].getStr(),
    storeStartAndStopTime: data["store_start_and_stop_time"].getBVal(),
    beginningOfWeek: uint(data["beginning_of_week"].getNum()),
    language: data["language"].getStr(),
    imageUrl: data["image_url"].getStr(),
    sidebarPiechart: data["sidebar_piechart"].getBVal(),
    sendProductEmails: data["send_product_emails"].getBVal(),
    sendWeeklyReport: data["send_weekly_report"].getBVal(),
    sendTimerNotifications: data["send_timer_notifications"].getBVal(),
    openIdEnabled: data["openid_enabled"].getBVal(),
    timezone: data["timezone"].getStr()
  )


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
