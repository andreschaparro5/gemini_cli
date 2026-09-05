import std/[json, strutils, strformat]

proc toolAppendFile*(args: JsonNode): JsonNode =
  let path = args["path"].getStr()
  let content = args["content"].getStr()
  try:
    var f: File
    if not open(f, path, fmAppend):
      return %*{"error": fmt"No se pudo abrir '{path}' para escribir."}
    f.write(content)
    f.close()
    result = %*{"ok": true, "path": path}
  except CatchableError as e:
    result = %*{"error": e.msg}
