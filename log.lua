--
-- log.lua
--
-- Copyright (c) 2014, 2015 rxi
--
-- Original Author:
--     rxi
--
-- Contributions by:
--     Eric James Michael Ritz <ejmr@plutono.com>
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"


local modes = {
  { name = "trace", color = "\27[34m", },
  { name = "debug", color = "\27[36m", },
  { name = "info",  color = "\27[32m", },
  { name = "warn",  color = "\27[33m", },
  { name = "error", color = "\27[31m", },
  { name = "fatal", color = "\27[35m", },
}

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end

local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, .01)
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end


local create_output = function (level, filename, fileline, ...)
  local levelname = level:upper()
  local lineinfo = filename .. ":" .. fileline
  local msg = tostring(...)
  local color = modes[levels[level]]["color"]

  -- Return early if we're below the log level
  if levels[level] < levels[log.level] then
    return
  end

  -- Output to console
  print(string.format("%s[%-6s%s]%s %s: %s",
                      log.usecolor and color or "",
                      levelname,
                      os.date("%H:%M:%S"),
                      log.usecolor and "\27[0m" or "",
                      lineinfo,
                      msg))

  -- Output to log file
  if log.outfile then
    local fp = io.open(log.outfile, "a")
    local str = string.format("[%-6s%s] %s: %s\n",
                              levelname, os.date(), lineinfo, msg)
    fp:write(str)
    fp:close()
  end
end


for _, x in ipairs(modes) do
  log[x.name] = function(...)
    local info = debug.getinfo(2, "Sl")
    create_output(x.name, info.short_src, info.currentline, ...)
  end
end


log.check = function (value, message, levelname)
  local output = message or "check failed"
  local level = levelname or "warn"
  local info = debug.getinfo(2, "Sl")

  if not value then
    create_output(level, info.short_src, info.currentline, output)
  end

  return value
end

return log
