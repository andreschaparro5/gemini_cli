import std/[json]
import capabilities/[read, write, append, delete, list, create]

proc dispatchTool*(name: string, args: JsonNode): JsonNode =
  case name
  of "read_file": result = toolReadFile(args)
  of "write_file": result = toolWriteFile(args)
  of "append_file": result = toolAppendFile(args)
  of "delete_file": result = toolDeleteFile(args)
  of "list_dir": result = toolListDir(args)
  of "create_dir": result = toolCreateDir(args)
  else: result = %*{"error": "Herramienta desconocida: " & name}
