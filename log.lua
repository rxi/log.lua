--
-- log.lua
--
-- Copyright (c) 2016, 2017 rxi, premek.v
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.2.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"
log.printpattern = "%O[%p %d]%o %F:%L: %m"
log.filepattern = "[%p %d] %F:%L: %m\n"
log.datepattern = "%H:%M:%S"


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

function interp(s, tab)
  return (s:gsub('(%%.)', function(w) return tab[w:sub(2, -1)] or w end))
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
  local nameupper = string.format('%-5s', x.name:upper())
  log[x.name] = function(...)
    
    -- Return early if we're below the log level
    if i < levels[log.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")

    local values = {
      p = nameupper,
      d = os.date(log.datepattern),
      O = log.usecolor and x.color or "",
      o = log.usecolor and "\27[0m" or "",
      F = info.short_src,
      L = info.currentline,
      m = msg,
      ['%'] = '%'
    }

    -- Output to console
    print(interp(log.printpattern, values))

    -- Output to log file
    if log.outfile then
      local fp = io.open(log.outfile, "a")
      fp:write(interp(log.filepattern, values))
      fp:close()
    end

  end
end

return log
