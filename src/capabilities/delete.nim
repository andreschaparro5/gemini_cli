import std/[json, os, strutils, strformat]

proc toolDeleteFile*(args: JsonNode): JsonNode =
  let path = args["path"].getStr()
  try:
    if dirExists(path):
      removeDir(path)
      result = %*{"ok": true, "path": path, "type": "directory"}
    elif fileExists(path):
      removeFile(path)
      result = %*{"ok": true, "path": path, "type": "file"}
    else:
      result = %*{"error": fmt"'{path}' no existe."}
  except CatchableError as e:
    result = %*{"error": e.msg}
