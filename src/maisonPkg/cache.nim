import asyncdispatch, asyncfile, json, logging, md5, os, strformat, times

type
  CachedData[T] = object
    data: T
    expires: int64

  NotCachedException* = object of Exception

proc cacheData*[T](key: string, val: T, folder = "./var/cache") {.async.} =
  let
    fullKey = $toMD5(key)
    expires = toUnix(toTime(now()+initTimeInterval(hours=1)))
    data = CachedData[T](data: val, expires: expires)
    asJson = %*data
    asString = $asJson
    fname = folder / fullKey

  var fout = openAsync(fname, fmWrite)
  await fout.write asString
  fout.close

proc loadFromCache*[T](key: string, folder = "./var/cache"): Future[T] {.async.} =
  let
    fullKey = $toMD5(key)
    fname = folder / fullKey

  var fin: AsyncFile
  try:
    fin = openAsync(fname)
  except OSError:
    raise newException(NotCachedException, fmt"{fullKey} is not cached")

  let
    myJson = parseJson(await fin.readAll)
    data = to(myJson, CachedData[T])
    curr = now()
    expiresTime = data.expires.fromUnix.local()

  if expiresTime < curr:
    raise newException(NotCachedException, "data at {fullKey} expired at {data.expires}, it is {curr.toTime.toUnix}")

  result = data.data

when isMainModule:
  import tempdir, unittest

  test "caching":
    withTempDirectory(tmp, "cachetest"):
      waitFor cacheData[string]("test", "hi", tmp)
      let val = waitFor loadFromCache[string]("test", tmp)
      assert val == "hi"
