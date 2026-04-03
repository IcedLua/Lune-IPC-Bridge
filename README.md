(ai generated readme)
# 🌉 Lune IPC Bridge

A fast, lightweight inter-process communication bridge that enables **Luau** (via [Lune](https://lune.luau.org/)) to communicate with **Python** (or any language) using MessagePack serialization.

## ✨ Features

- **Ultra-Low Latency** - ~80 microseconds per round-trip ping-pong
- **Binary-Safe** - Supports both MessagePack-encoded data and raw buffers
- **Efficient Serialization** - Uses MessagePack for compact data encoding
- **Simple API** - Minimal, intuitive interface for inter-process communication
- **Large Data Support** - Handles multi-megabyte transfers (tested with 4MB image buffers)

## 📋 Prerequisites

- **MessagePack** - Required for serialization on both sides
  - Python: `pip install msgpack`
  - Luau: Included via Lune's standard library

## 🚀 Quick Start

### Copy the Bridge Files

1. Copy `src/bridge.luau` to your Lune project
2. Copy `src/bridge.py` to your Python project (or implement the bridge pattern in C++)

### Basic Usage

**Luau (Lune):**
```luau
local Bridge = require("./bridge")

local myBridge = Bridge.new({
    executable = "python",
    params = {"my_script.py"}
})

-- Send data
myBridge:send({ message = "Hello from Luau!" })

-- Receive data
local response = myBridge:read()
print(response)
```

**Python:**
```python
from bridge import Bridge

def handle_message(data, is_raw):
    print(f"Received: {data}")
    return {"response": "Hello from Python!"}

bridge = Bridge(handle_message)
bridge.listen()
```

## 💡 Examples

See `src/examples/` for working examples:

- **Ping-Pong Test** - Demonstrates low-latency messaging (~80µs per round-trip)
- **Image Transfer** - Shows efficient binary buffer transmission (4MB+ capable)

## 📊 Performance

- Round-trip latency: **~80 microseconds** (ping-pong test)
- Binary data transfer: **100+ milliseconds** for 4MB buffers
- Minimal overhead through direct stdin/stdout communication

## 🔧 How It Works

The bridge uses a simple 5-byte header protocol:

```
[Type (1 byte)][Length (4 bytes)][Payload (variable)]
```

- **Type 0**: Raw buffer data
- **Type 1**: MessagePack-encoded data

This allows both high-performance binary transfer and flexible data serialization.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details
