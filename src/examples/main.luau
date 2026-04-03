local task = require("@lune/task")
local msgpack = require("./libraries/msgpack")
local Secrets = require("./Secrets")
local Bridge = require("./lunetools/Bridge")
local PythonExecutable = `Python`
local RunLocation = "secondary/main.py"

local myBridge = Bridge.new({
    executable = PythonExecutable,
    params = {RunLocation, "-u"}
})

local function run_ping_pong(iterations) -- 80 microsecond round trip
    local currentNum = 1
    local start = os.clock()

    for i = 1, iterations do
        myBridge:send(currentNum)
        currentNum = myBridge:read()
        if i % 20 == 0 then
            print(`{i}/{iterations}`)
        end
    end

    local totalTime = os.clock() - start
    print(`Final Number:`, currentNum)
    print(`Total Time for {iterations} bounces: {totalTime}s`)
    print(`Avg Latency: {(totalTime / iterations) * 1000}ms`)
end

-- i'm fluent in luau, NOT color math, nor vector math, vibecoded, yeah, not that nice.
-- #recodefriedcheeseinrust
local function fastHueToRGB(h)
    h = h % 360
    local sector = h / 60
    local x = 1 - math.abs(sector % 2 - 1)

    if sector < 1 then return 1, x, 0 -- Red to Yellow
    elseif sector < 2 then return x, 1, 0 -- Yellow to Green
    elseif sector < 3 then return 0, 1, x -- Green to Cyan
    elseif sector < 4 then return 0, x, 1 -- Cyan to Blue
    elseif sector < 5 then return x, 0, 1 -- Blue to Magenta
    else return 1, 0, x end -- Magenta to Red
end

local function send_image() -- 100+ miliseconds round trip
    -- Create a 4MB buffer (1024 * 1024 * 4 bytes)
    local width = 1024
    local height = 1024
    local imgBuffer = buffer.create(width * height * 4)

    for y = 0, height - 1 do
        local R, G, B = fastHueToRGB(y)
        for x = 0, width - 1 do
            local offset = (y * width + x) * 4
            buffer.writeu8(imgBuffer, offset, R*255)     -- Red
            buffer.writeu8(imgBuffer, offset + 1, G*255) -- Green
            buffer.writeu8(imgBuffer, offset + 2, B*255)     -- Blue
            buffer.writeu8(imgBuffer, offset + 3, (x/1024)*255)     -- Alpha
        end
    end

    local startTime = os.clock()
    myBridge:send(imgBuffer)
    print(myBridge:read())
    local endTime = os.clock()
    print(`Total time for sending image: {endTime - startTime}s`)
end

send_image()
