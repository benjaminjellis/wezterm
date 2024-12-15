## Private module
This config supports adding a file `private.lua` in the root. Private config set up can be specified doing something like
```lua
local M = {}

function M.run(config)
    -- change the wezterm config here 
end

return M
```
