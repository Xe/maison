import asyncdispatch, cache, httpclient, json, logging, os, strutils

type
  Front* = object
    who*: string

proc front(hc = newAsyncHttpClient()): Future[string] {.async.} =
  var front = await hc.getContent(getEnv "FRONT_URL")
  front.stripLineEnd
  return front

proc frontCached*(hc = newAsyncHttpClient()): Future[Front] {.async.} =
  let url = getEnv "FRONT_URL"
  try:
    result = await loadFromCache[Front](url)
  except NotCachedException:
    result = Front(who: await front(hc))
    await cacheData[Front](url, result)
    info "grabbed front from remote host"
