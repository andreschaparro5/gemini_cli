import std/[json, os, strutils, strformat]

proc toolCreateDir*(args: JsonNode): JsonNode =
  let path = args["path"].getStr()
  try:
    createDir(path)
    result = %*{"ok": true, "path": path}
  except CatchableError as e:
    result = %*{"error": e.msg}
