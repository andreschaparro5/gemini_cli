# Nim Gemini CLI

A recreation of Gemini CLI written in Nim.

## Overview

Nim Gemini CLI is an interactive command-line interface for Google's Gemini models, built from scratch in Nim. It aims to provide the same core experience as the original Gemini CLI while leveraging Nim's performance, small binaries, and clean syntax.

## Features

- **Fast startup:** compiled native binary with minimal overhead
- **Interactive REPL:** chat with Gemini models directly from your terminal
- **Tool calling:** extensible tool/function execution (file I/O, shell commands, web fetch)
- **Conversation history:** persistent sessions with context management
- **Syntax highlighting:** readable markdown and code output in the terminal
- **Flexible auth:** API key or environment-variable based authentication
- **Configurable** model selection, temperature, and system prompt via config file

## Requirements

- Nim >= 1.6.0
- A Gemini API key from Google AI Studio

## Installation

### From source

```bash
git clone https://github.com/andreschaparro5/gemini_cli.git
cd gemini_cli
nimble install
```

### Build a release binary

```bash
nimble build -d:release
```

The binary will be available at build/gemini_cli.

## Configuration

Set your API key as an environment variable:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

## Usage

Start an interactive session:

```bash
./build/gemini_cli
```

### Interactive commands

Command Description:
- **/help** Show available commands
- **/clear** Clear conversation history
- **/save** <file> Save the current session to a file
- **/exit** Quit the CLI

### Example session

```
$ gemini_cli
> Write a Nim function that reverses a string

Here's a simple implementation:

proc reverseString(s: string): string =
  result = newString(s.len)
  for i in 0 ..< s.len:
    result[i] = s[s.len - 1 - i]

> /exit
```

## Development

```bash
# Install dependencies
nimble install -d

# Dev mode
nimble build -d:dev
```

## License

Distributed under the GPL-V3 license. See LICENSE for more information.
