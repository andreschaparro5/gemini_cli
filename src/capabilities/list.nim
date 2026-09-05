import std/[json, os, strutils, strformat]

proc toolListDir*(args: JsonNode): JsonNode =
  let path = if args.hasKey("path"): args["path"].getStr() else: "."
  try:
    if not dirExists(path):
      return %*{"error": fmt"El directorio '{path}' no existe."}
    var entries = newJArray()
    for kind, name in walkDir(path):
      let kindStr = case kind
        of pcFile: "file"
        of pcDir: "dir"
        of pcLinkToFile: "symlink_file"
        of pcLinkToDir: "symlink_dir"
      entries.add(%*{"name": name, "type": kindStr})
    result = %*{"path": path, "entries": entries}
  except CatchableError as e:
    result = %*{"error": e.msg}
