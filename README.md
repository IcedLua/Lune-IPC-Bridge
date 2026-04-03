`
C++ (Running Luau Bytecode) -> Requesting Rust (lune runtime) -> Lune Standard Library -> "blocking" rust crate -> STDIO -> C -> Python (running inside C) -> Send a small text packet status back over the bridge -> In a sixty-th of a second... sending 4mb raw buffers, with a 5 byte header
`

Last time i tested... yknow what i got? 100 miliseconds. To send a 4mb image. I assume it's warmed up, because the previous test I did was one-shot, but, now we're raymarching a continous animation, at 60+ frames!!!

`FPS: Current: 68 Average: 51 Best: 72 Worst: 0`
<details>
  <summary>Code used</summary>

  ```luau
local task = require("@lune/task")
local Bridge = require("./lunetools/Bridge")
local PythonExecutable = `Python`
local RunLocation = "secondary/main.py"

local myBridge = Bridge.new({
    executable = PythonExecutable,
    params = {RunLocation, "-u"}
})


local width, height = 1024, 1024
local imgBuffer = buffer.create(width * height * 4)

local BG_R, BG_G, BG_B = 0, 0, 0
local W_INV, H_INV = 1/width, 1/height

local lastTime = os.clock()

while true do
    local t = os.clock()
    
    local lx, lz = math.sin(t) * 0.57, math.cos(t) * 0.57
    local radius = 0.6 + math.sin(t * 1.5) * 0.1
    local radiusSq = radius * radius

    for y = 0, height - 1 do
        local uvY = (y * H_INV) * 2 - 1
        for x = 0, width - 1 do
            local uvX = (x * W_INV) * 2 - 1
            local distSq = uvX*uvX + uvY*uvY
            
            local r, g, b = BG_R, BG_G, BG_B
            
            if distSq < radiusSq then
                local uvZ = math.sqrt(radiusSq - distSq)
                local dot = (uvX * lx + uvY * 0.57 + uvZ * lz)
                local intensity = (dot > 0.1) and dot or 0.1
                
                r = intensity * 190
                g = intensity * 190
                b = intensity * 255
            end

            local offset = (y * width + x) * 4
            buffer.writeu8(imgBuffer, offset, r)
            buffer.writeu8(imgBuffer, offset + 1, g)
            buffer.writeu8(imgBuffer, offset + 2, b)
            buffer.writeu8(imgBuffer, offset + 3, 255)
        end
    end

    myBridge:send(imgBuffer)
    local currentTime = os.clock()
    local deltaTime = currentTime - lastTime
    local fps = 1 / deltaTime -- Since FPS = Frames / Seconds
    
    print("FPS: " .. math.floor(fps)) -- Not the best way to calculate, but, great estimation.
    
    lastTime = currentTime
end
```
</details>

(ai generated readme below)
(slightly edited by human)
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
