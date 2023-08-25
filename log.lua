--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"
log.entries = {}
log.debuglayer = 2

local os, debug, math, table, string, lfs = os, debug, math, table, string, love and love.filesystem
local ipairs, select, type, print, fileopen = ipairs, select, type, print, lfs and lfs.newFile or io.open

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


for i, x in ipairs(modes) do
  ---@cast x { name: string|function, color: string }
  local nameupper = x.name:upper()
  log[x.name] = function(...)

    -- Return early if we're below the log level
    if i < levels[log.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(log.debuglayer, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    -- Output to console
    print(string.format("%s[%-6s%s]%s %s: %s",
                        log.usecolor and x.color or "",
                        nameupper,
                        os.date("%H:%M:%S"),
                        log.usecolor and "\27[0m" or "",
                        lineinfo,
                        msg))

    local str = string.format("[%-6s%s] %s: %s\n",
                              nameupper, os.date(), lineinfo, msg)

    -- Store to log table
    table.insert(log.entries, str)

    -- Return order: formatted_string, message, level, pathname, lineno, asctime, created_on
    return str, msg, nameupper, info.short_src, info.currentline, os.date("!%Y-%m-%d %H:%M:%S"), os.time()
  end
end


log.flush = function(outfile)
  local e, o = log.entries, outfile or log.outfile
  local length, fp = #e, o and fileopen(o, 'a')

  -- Output to log file
  if fp then
    for i = 1, length do
      fp:write(e[i])
      e[i] = nil
    end

    fp:close()
  else
    for i = 1, length do
      e[i] = nil
    end
  end
end


return log
