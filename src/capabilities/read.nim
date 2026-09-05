import std/[json, os, strutils, strformat]

proc toolReadFile*(args: JsonNode): JsonNode =
  let path = args["path"].getStr()
  try:
    if not fileExists(path):
      return %*{"error": fmt"El archivo '{path}' no existe."}
    let content = readFile(path)
    result = %*{"path": path, "content": content}
  except CatchableError as e:
    result = %*{"error": e.msg}
