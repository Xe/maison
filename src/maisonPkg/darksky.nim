import asyncdispatch, cache, httpclient, json, logging, strformat, strutils

type
  WeatherStatus* = object
    ## A simplified view of DarkSky weather status
    time*: int
    summary*: string
    temperature*: float
    apparentTemperature*: float
    humidity*: float
    icon*: string

  Daily* = object
    ## Daily info
    summary*: string
    icon*: string
    data*: seq[WeatherData]

  WeatherData* = object
    ## detailed weather data
    time*: int
    icon*: string
    temperatureHigh*: float
    temperatureLow*: float

  Weather* = object
    ## A simplified view of DarkSky weather
    currently*: WeatherStatus
    daily*: Daily

proc getCurrentWeather(apiKey: string, loc: string, hc = newAsyncHttpClient()): Future[Weather] {.async.} =
  let url = fmt"https://api.darksky.net/forecast/{apiKey}/{loc}?units=si"
  let body = await hc.getContent(url)
  return to(parseJson(body), Weather)

proc getCachedWeather*(apiKey, loc: string, hc = newAsyncHttpClient()): Future[Weather] {.async.} =
  let cacheKey = apiKey & loc
  try:
    result = await loadFromCache[Weather](cacheKey)
  except NotCachedException:
    result = await getCurrentWeather(apiKey, loc, hc)
    await cacheData[Weather](cacheKey, result)
    info "grabbed weather from darksky"
