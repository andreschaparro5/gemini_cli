import std/[json, os, strutils, strformat]

proc toolWriteFile*(args: JsonNode): JsonNode =
  let path = args["path"].getStr()
  let content = args["content"].getStr()
  try:
    let parent = parentDir(path)
    if parent.len > 0 and not dirExists(parent):
      createDir(parent)
    writeFile(path, content)
    result = %*{"ok": true, "path": path, "bytes_written": content.len}
  except CatchableError as e:
    result = %*{"error": e.msg}
