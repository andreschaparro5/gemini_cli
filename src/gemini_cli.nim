import std/[httpclient, json, os, strutils, strformat, terminal]
import capabilities

# ---------------------------------------------------------------------------
# Configuración global
# ---------------------------------------------------------------------------

const
  DefaultModel = "gemini-3.1-flash-lite"
  ApiBase = "https://generativelanguage.googleapis.com/v1beta/models"
  SystemInstruction = """
Eres un asistente de IA que corre en la terminal de un usuario y tiene
herramientas para leer, crear, modificar, eliminar archivos y listar
directorios del computador del usuario. Usa esas herramientas cuando el
usuario te lo pida o cuando sea necesario para responder correctamente.
Sé claro y conciso en tus respuestas en español.
"""

var
  apiKey: string
  currentModel: string
  history: JsonNode = newJArray()   # historial de "contents" para la API

# ---------------------------------------------------------------------------
# Funciones auxiliares de impresión
# ---------------------------------------------------------------------------

proc printMsg(role: string, text: string) =
  case role
  of "user":
    setForegroundColor(fgCyan)
    stdout.write("Tú: ")
  of "model":
    setForegroundColor(fgYellow)
    stdout.write("Gemini: ")
  of "tool":
    setForegroundColor(fgMagenta)
    stdout.write(">> [herramienta] ")
  of "error":
    setForegroundColor(fgRed)
    stdout.write("⚠️  ")
  resetAttributes()
  echo text

# ---------------------------------------------------------------------------
# Declaración de herramientas
# ---------------------------------------------------------------------------
proc buildTools(): JsonNode =
  result = %*[{
    "functionDeclarations": [
      {
        "name": "read_file",
        "description": "Lee el contenido completo de un archivo de texto.",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del archivo a leer."}
          },
          "required": ["path"]
        }
      },
      {
        "name": "write_file",
        "description": "Crea un archivo o sobreescribe su contenido por completo.",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del archivo a escribir."},
            "content": {"type": "STRING", "description": "Contenido a escribir en el archivo."}
          },
          "required": ["path", "content"]
        }
      },
      {
        "name": "append_file",
        "description": "Agrega contenido al final de un archivo existente (o lo crea si no existe).",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del archivo."},
            "content": {"type": "STRING", "description": "Contenido a agregar."}
          },
          "required": ["path", "content"]
        }
      },
      {
        "name": "delete_file",
        "description": "Elimina un archivo o directorio (recursivamente si es directorio).",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del archivo o directorio a eliminar."}
          },
          "required": ["path"]
        }
      },
      {
        "name": "list_dir",
        "description": "Lista los archivos y carpetas dentro de un directorio.",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del directorio. Por defecto '.'"}
          }
        }
      },
      {
        "name": "create_dir",
        "description": "Crea un directorio (incluyendo padres si no existen).",
        "parameters": {
          "type": "OBJECT",
          "properties": {
            "path": {"type": "STRING", "description": "Ruta del directorio a crear."}
          },
          "required": ["path"]
        }
      }
    ]
  }]

# ---------------------------------------------------------------------------
# Llamada a la API
# ---------------------------------------------------------------------------

proc callGemini(): JsonNode =
  let url = fmt"{ApiBase}/{currentModel}:generateContent?key={apiKey}"
  let body = %*{
    "contents": history,
    "tools": buildTools(),
    "systemInstruction": {"parts": [{"text": SystemInstruction}]}
  }
  var client = newHttpClient(timeout = 60000)
  defer: client.close()
  client.headers = newHttpHeaders({"Content-Type": "application/json"})
  let respStr = client.postContent(url, $body)
  result = parseJson(respStr)

# ---------------------------------------------------------------------------
# Ciclo principal
# ---------------------------------------------------------------------------

proc runTurn() =
  while true:
    var response: JsonNode
    try: response = callGemini()
    except CatchableError as e:
      printMsg("error", "Error al llamar a la API: " & e.msg)
      return

    if response.hasKey("error"):
      printMsg("error", "Error de la API: " & response["error"].getStr())
      return

    let candidate = response["candidates"][0]
    let parts = candidate["content"]["parts"]
    history.add(%*{"role": "model", "parts": parts})

    var functionCalls: seq[JsonNode] = @[]
    var textOut = ""
    for part in parts:
      if part.hasKey("functionCall"): functionCalls.add(part["functionCall"])
      elif part.hasKey("text"): textOut.add(part["text"].getStr())

    if functionCalls.len > 0:
      var responseParts = newJArray()
      for fc in functionCalls:
        let fname = fc["name"].getStr()
        let fargs = if fc.hasKey("args"): fc["args"] else: newJObject()
        printMsg("tool", fmt"{fname}({fargs})")
        responseParts.add(%*{"functionResponse": {"name": fname, "response": dispatchTool(fname, fargs)}})
      history.add(%*{"role": "user", "parts": responseParts})
      continue
    else:
      printMsg("model", textOut)
      return

proc main() =
  apiKey = getEnv("GEMINI_API_KEY")
  if apiKey.len == 0:
    printMsg("error", "Falta GEMINI_API_KEY")
    quit(1)

  currentModel = getEnv("GEMINI_MODEL", DefaultModel)
  
  setForegroundColor(fgBlue)
  echo "========================================"
  echo " Gemini CLI - Modular Edition"
  echo "========================================"
  resetAttributes()

  while true:
    setForegroundColor(fgCyan)
    stdout.write("Tú: ")
    resetAttributes()
    stdout.flushFile()
    
    var line: string
    if not readLine(stdin, line): break
    line = line.strip()
    if line.len == 0: continue
    if line == "/salir": break
    if line == "/reset":
      history = newJArray()
      echo "Historial reiniciado."
      continue
    
    history.add(%*{"role": "user", "parts": [{"text": line}]})
    runTurn()

main()
