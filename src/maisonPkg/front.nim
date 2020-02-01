import asyncdispatch, cache, httpclient, json, logging, os, strutils

type
  Front* = object
    who*: string

proc frontCached*(hc = newAsyncHttpClient()): Future[Front] {.async.} =
  var front = await hc.getContent(getEnv "FRONT_URL")
  front.stripLineEnd
  return Front(who: front)
