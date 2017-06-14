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

  TogglClient* = ref object of RootObj
    ## An object wrapper around a Toggl client.
    id*: int
    name*: string
    wid*: int
    notes*: string


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


proc newTogglClient(data: JsonNode): TogglClient =
  ## Create a new TogglClient instance from Json data as returned by the Toggl
  ## API.
  TogglClient(
    id: int(data["id"].getNum()),
    name: data["name"].getStr(),
    wid: int(data["wid"].getNum()),
    notes: data{"notes"}.getStr()
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


proc togglGetCurrentUser*(): TogglUser =
  ## Request the user profile of the user to whom the currently configured API
  ## token belongs and return it as a TogglUser instance.
  ##
  ## Only fields that are officially documented are available on the TogglUser
  ## instance. Check the documentation of the TogglUser type to see which fields
  ## those are.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##    var user = togglGetCurrentUser()
  ##    echo user.fullname, user.email
  let res: Response = callTogglApiEndpoint("/me")
  newTogglUser(parseJson(res.body)["data"])


proc togglUpdateCurrentUser*(t: TogglUser): TogglUser =
  ## Update the user profile of the user to whome the currently configured API
  ## token belongs and return the updated profile as a TogglUser instance.
  ##
  ## The updated information will be extracted from the given TogglUser
  ## instance.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##    var user = togglGetCurrentUser()
  ##    user.email = "johndoe@example.com"
  ##    togglUpdateCurrentUser(user)
  let
    body = %*{"user": {
      "fullname": t.fullname,
      "email": t.email,
      "send_product_emails": t.sendProductEmails,
      "send_weekly_report": t.sendWeeklyReport,
      "send_timer_notifications": t.sendTimerNotifications,
      "store_start_and_stop_time": t.storeStartAndStopTime,
      "beginning_of_week": int(t.beginningOfWeek),
      "timezone": t.timezone,
      "timeofday_format": t.timeOfDayFormat,
      "date_format": t.dateFormat
    }}
    res: Response = callTogglApiEndpoint("/me", httpMethod = HttpPut, body = body)

  newTogglUser(parseJson(res.body)["data"])


proc togglCreateClient*(name: string, wid: int, notes: string = ""): TogglClient =
  ## Create a new client for the workspace specified by ``wid``. The created
  ## client will be returned as an instance of ``TogglClient``.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##    var client: TogglClient = togglCreateClient("Big Corp", 12345)
  ##    echo client.name
  let
    body = %*{
      "client": {
        "name": name,
        "wid": wid,
        "notes": notes
      }
    }
    res: Response = callTogglApiEndpoint("/clients", httpMethod = HttpPost, body = body)

  newTogglClient(parseJson(res.body)["data"])
