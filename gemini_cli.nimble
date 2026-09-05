# Package

version       = "0.0.1"
author        = "Andres Felipe Chaparro"
description   = "Gemini cli pero version nim"
license       = "GPL"
srcDir        = "src"
bin           = @["gemini_cli"]

# Build settings
# Command: nim c -d:danger --opt:speed --threads:on --mm:orc --panics:on -d:strip -d:ssl gemini_cli.nim
#binFlags      = " -d:danger --opt:speed --threads:on --mm:orc --panics:on  -d:strip -d:ssl"
binDir = "build/"
backend = "c"
skipDirs = @["tests"]

# Dependencies
requires "nim >= 1.6.0"

# Tasks
task dev, "Compila la versión de desarrollo con logs":
  exec "nim c -d:debug --hints:on -d:ssl --out:build/gemini_cli src/gemini_cli.nim "

task release, "Compila la versión optimizada de producción":
  exec "nim c -d:release --opt:speed -d:danger --threads:on --mm:orc -d:strip -d:ssl --out:build/gemini_cli src/gemini_cli.nim"

task ran, "Ejecuta el binario":
  exec "./build/gemini_cli"  