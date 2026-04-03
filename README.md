(ai generated readme)
# 🌉 Lune IPC Bridge

A fast, lightweight inter-process communication bridge that enables **Luau** (via [Lune](https://lune.luau.org/)) to communicate with **Python** (or any language) using MessagePack serialization.

## ✨ Features

- **i optimized tf out of it** - ~80 microseconds round trip to send... a 4 byte number!! wow!!!
- **meows data in morse code** - ok that's not a feature is it?
- **better than json** - it uses messaagepack!!!
- **Simple API** - WOw so easy to use definitely not me just being lazy and only adding three methods
- **Large Data Support** - It sends... not that much data really.

## 📋 Prerequisites

- **MessagePack** - Required for serialization on both sides
  - Python: `pip install msgpack`
  - Other Languages: dude go figure it out yourself i only speak luau
  - Luau: it's in the repo, or you can find it at... idk where lol

## 🚀 Slow Start

### Copy the Bridge Files

1. Copy `src/bridge.luau` to your Lune project
2. Copy `src/bridge.py` to your Python project (or implement the bridge pattern in your preferred language)

### Basic Usage

**Luau (Lune):**
```luau
local Bridge = require("./bridge") -- or your path

local myBridge = Bridge.new({
    executable = "python", -- yeah that does work with PATH, or wahtever bash uses (w bash)
    params = {"my_script.py"} -- relative to cwd of course
})

-- Send data
myBridge:send({ message = "Hello from Luau!" }) -- Supports most data types, no Luau specific, only Lua pure. also supports buffers if you needasend like vectors or stuff serialize it urself into a buffer

-- Receive data
local response = myBridge:read()
print(response)
```

**Python:**
```python
from bridge import Bridge -- provided in project, or like, you can code your own.

def handle_message(data, is_raw):
    print(f"Received: {data}")
    return {"response": "Hello from Python!"}

bridge = Bridge(handle_message)
bridge.listen()
```

## 💡 Examples

See `src/examples/` for working examples:

- **Ping-Pong Test** - Demonstrates low-latency messaging (~80µs per round-trip)... to calculate n+1
- **Image Transfer** - Shows efficient binary buffer transmission (it can send at least 4mb) (100 milisecond round trip) (ts so slow wtf)

## 📊 Performance

- Round-trip latency: **~80 microseconds** (ping-pong test)
- Binary data transfer: **100+ milliseconds** for 4MB buffers
- Minimal overhead through direct stdin/stdout communication

## 🔧 NOT How It Works
(aiu doesnt understand that much but this is right right)
The bridge uses a simple 5-byte header protocol:

```
[Type (1 byte)][Length (4 bytes)][Payload (variable)]
```

- **Type 0**: Raw buffer data
- **Type 1**: MessagePack-encoded data

This allows both high-performance binary transfer and flexible data serialization.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details
