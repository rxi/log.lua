# log.lua
A tiny logging module for Lua. WITH ADDED SUPPORT FOR LOVE AND VIM USERS!

## SETUP

Here's a simple setup

* Download and Install this vim [script](https://www.vim.org/scripts/script.php?script_id=302)
* Add this line into your **.vimrc**

```lua
autocmd BufNewFile,BufRead *.log :AnsiEsc
```

```lua
local Log = require("path-to-log.lua")
Log.usecolor = false
Log.outfile = "log.log" -- the filename to save in the love appdata
Log.lovesave = true
```
When you open the **log.log** file in your love appdata directory, that should be colorized :)

## Installation
The [log.lua](log.lua?raw=1) file should be dropped into an existing project
and required by it.
```lua
log = require "log"
``` 

## Usage
log.lua provides 6 functions, each function takes all its arguments,
concatenates them into a string then outputs the string to the console and --
if one is set -- the log file:

* **log.trace(...)**
* **log.debug(...)**
* **log.info(...)**
* **log.warn(...)**
* **log.error(...)**
* **log.fatal(...)**


### Additional options
log.lua provides variables for setting additional options:

#### log.usecolor
Whether colors should be used when outputting to the console, this is `true` by
default. If you're using a console which does not support ANSI color escape
codes then this should be disabled.

#### log.outfile
The name of the file where the log should be written, log files do not contain
ANSI colors and always use the full date rather than just the time. By default
`log.outfile` is `nil` (no log file is used). If a file which does not exist is
set as the `log.outfile` then it is created on the first message logged. If the
file already exists it is appended to.

#### log.level
The minimum level to log, any logging function called with a lower level than
the `log.level` is ignored and no text is outputted or written. By default this
value is set to `"trace"`, the lowest log level, such that no log messages are
ignored.

The level of each log mode, starting with the lowest log level is as follows:
`"trace"` `"debug"` `"info"` `"warn"` `"error"` `"fatal"`


## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

