local keys = KEYS
local args = ARGV
local Wtm = {}      -- Wtm library

Wtm.serialize = function(self, obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. self:serialize(k) .. "]=" .. self:serialize(v) .. ",\n"
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end
Wtm.log = function(self, v)
    redis.log(redis.LOG_NOTICE, self:serialize(v))
end
Wtm:log("下面回显输入的keys");
Wtm:log(keys);

Wtm:log("下面回显输入的values");
Wtm:log(args);
