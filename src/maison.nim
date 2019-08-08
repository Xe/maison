import asyncdispatch, dotenv, jester, json, os, strutils, times

import maisonPkg/[darksky, front]

try: initDotEnv().overload
except: discard

include "./maisonPkg/index.tmpl"

settings:
  port = getEnv("PORT").parseInt().Port
  bindAddr = "0.0.0.0"

routes:
  get "/api/weather":
    let j = %* await getCachedWeather(getEnv("DARKSKY_KEY"), getEnv("WEATHER_LOCATION"))
    resp Http200, $j, "application/json"

  get "/api/front":
    let j = %* await frontCached()
    resp Http200, $j, "application/json"

  get "/":
    resp Http200, genIndex("Données pour notre maison"), "text/html; charset=utf-8"

  error Http404:
    resp Http404, genIndex("Oops!"), "text/html; charset=utf-8"
