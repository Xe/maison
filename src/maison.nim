import asyncdispatch, dotenv, jester, json, os, strutils, times

import maisonPkg/[darksky, front]

initDotEnv().overload

include "./maisonPkg/index.tmpl"

settings:
  port = getEnv("PORT").parseInt().Port
  bindAddr = "0.0.0.0"

routes:
  get "/api/weather":
    let w = await getCachedWeather(getEnv("DARKSKY_KEY"), getEnv("WEATHER_LOCATION"))
    let j = %w
    resp Http200, $j, "application/json"

  get "/api/front":
    let j = %* await frontCached()

    resp Http200, $j, "application/json"

  get "/":
    resp Http200, genIndex("Donn&eacute;es pour notre maison"), "text/html"

  error Http404:
    resp Http404, genIndex("Oops!"), "text/html"
