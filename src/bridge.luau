--!nolint LocalShadow
-- // Lune Standard Library
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local msgpack = require("../libraries/msgpack")

-- // Bridge Functions
local bridge = {}
bridge.__index = bridge

function bridge.new(processSettings: {
    executable: string,
    params: {string}?,
    options: process.CreateOptions?
})
    return setmetatable({
        process = process.create(processSettings.executable, processSettings.params or {}, processSettings.params)
    }, bridge)
end
type object = typeof(bridge.new())

function bridge:send(data)
    local self: object = self :: any
    local combinedBuff
    local isBuffer = type(data) == "buffer"

    if isBuffer then
        local payload = data
        local len = buffer.len(payload)
        combinedBuff = buffer.create(5 + len)
        
        buffer.writeu8(combinedBuff, 0, 0)      -- Type 0: Raw Buffer
        buffer.writeu32(combinedBuff, 1, len)   -- Length starts at offset 1
        buffer.copy(combinedBuff, 5, payload)   -- Data starts at offset 5
    else
        local payload = msgpack.encode(data)
        local len = #payload
        combinedBuff = buffer.create(5 + len)
        
        buffer.writeu8(combinedBuff, 0, 1)      -- Type 1: MessagePack
        buffer.writeu32(combinedBuff, 1, len)   -- Length starts at offset 1
        buffer.writestring(combinedBuff, 5, payload) -- Data starts at offset 5
    end

    self.process.stdin:write(combinedBuff)
end

function bridge:read()
    local self: object = self :: any
    
    -- 1. Read the 4-byte header
    local headerString = self.process.stdout:read(4)
    if not headerString then return nil end
    
    local headerBuf = buffer.fromstring(headerString)
    local payloadSize = buffer.readu32(headerBuf, 0)
    
    -- 2. Read exactly 'payloadSize' bytes
    -- Lune will yield here until Python sends the full message
    local payload = self.process.stdout:read(payloadSize)
    if not payload then return nil end

    return msgpack.decode(payload)
end

return bridge
