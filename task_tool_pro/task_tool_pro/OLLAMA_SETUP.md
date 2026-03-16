# Ollama Local AI Setup Guide

This guide explains how to set up Ollama for offline blog generation in Task Tool Pro.

## What is Ollama?

Ollama lets you run large language models locally on your machine — no internet, no API keys, completely free and private.

## Installation

### Windows
1. Download from https://ollama.com/download/windows
2. Run the installer
3. Ollama will start automatically in the system tray

### macOS
```bash
# Using Homebrew
brew install ollama

# Or download from https://ollama.com/download/mac
```

### Linux
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Pull a Model

After installing, pull the recommended model for blog writing:

```bash
# Recommended: Llama 3.1 (8B) — best balance of quality and speed
ollama pull llama3.1

# Alternative: Mistral (7B) — fast and good for writing
ollama pull mistral

# Alternative: Llama 3.1 (70B) — highest quality, needs 48GB+ RAM
ollama pull llama3.1:70b
```

### Model Comparison

| Model | Size | RAM Required | Quality | Speed |
|-------|------|-------------|---------|-------|
| `llama3.1` | 4.7 GB | 8 GB | Good | Fast |
| `mistral` | 4.1 GB | 8 GB | Good | Fast |
| `llama3.1:70b` | 40 GB | 48 GB | Excellent | Slow |
| `gemma2` | 5.4 GB | 8 GB | Good | Fast |
| `qwen2.5` | 4.7 GB | 8 GB | Good | Fast |

## Start Ollama

Ollama usually runs automatically after installation. If it's not running:

```bash
ollama serve
```

This starts the local API server at `http://localhost:11434`.

## Verify It's Working

```bash
# Check if Ollama is running
curl http://localhost:11434

# Should return: "Ollama is running"

# List installed models
ollama list

# Quick test
ollama run llama3.1 "Hello, write a short paragraph about AI"
```

## Configure in Task Tool Pro

1. Open the **AI Blog Generator** tool from the sidebar
2. Click the **Settings** (gear) icon
3. Select **Ollama (Local)** as the active provider
4. Set the **Model Name** (default: `llama3.1`)
5. Set the **Base URL** (default: `http://localhost:11434`) — change only if you run Ollama on a different port or machine
6. Click **Save Keys**
7. Enter a blog topic and click **Generate Blog**

## Troubleshooting

### "Cannot connect to Ollama"
- Make sure Ollama is running: `ollama serve`
- Check the base URL matches (default: `http://localhost:11434`)
- On Windows, check that Ollama is in the system tray

### "Model not found"
- Pull the model first: `ollama pull llama3.1`
- Check installed models: `ollama list`
- Make sure the model name in settings matches exactly

### Slow generation
- Local generation depends on your hardware (CPU/GPU/RAM)
- Use a smaller model like `mistral` for faster results
- Close other memory-intensive applications
- If you have an NVIDIA GPU, Ollama will use it automatically

### Generation quality issues
- Try a larger model if you have enough RAM
- The structured format works best with `llama3.1` or `mistral`
- If output format is wrong, try regenerating — local models may occasionally deviate from the format
