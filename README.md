# specs.nvim 👓
Show where your cursor moves when jumping large distances (e.g between windows). Fast and lightweight, written completely in Lua.

![demo](https://user-images.githubusercontent.com/28115337/111098526-90923e00-853b-11eb-8e7c-c5892d64c180.gif)

![showcase8](https://user-images.githubusercontent.com/28115337/112546694-aa404a80-8db1-11eb-8b1a-588ee62bfca5.gif)
![showcase7](https://user-images.githubusercontent.com/28115337/112546696-ab717780-8db1-11eb-8753-65205dd81535.gif)
![showcase6](https://user-images.githubusercontent.com/28115337/112546697-ab717780-8db1-11eb-85f4-9d68c2884103.gif)
![showcase5](https://user-images.githubusercontent.com/28115337/112546698-ac0a0e00-8db1-11eb-96bf-b1f3f5bca601.gif)
![showcase4](https://user-images.githubusercontent.com/28115337/112546699-ac0a0e00-8db1-11eb-8c6a-a1ecbdca410f.gif)
![showcase3](https://user-images.githubusercontent.com/28115337/112546700-ac0a0e00-8db1-11eb-80b7-f5ff0b9c052c.gif)
![showcase2](https://user-images.githubusercontent.com/28115337/112546701-aca2a480-8db1-11eb-8338-1cf695404881.gif)
![showcase1](https://user-images.githubusercontent.com/28115337/112546702-aca2a480-8db1-11eb-9cfb-8a068b06abf7.gif)

## Install
Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {'edluffy/specs.nvim'}
```
Using [vim-plug](https://github.com/junegunn/vim-plug):
```vimscript
Plug 'edluffy/specs.nvim'
```
## Usage
If you are using init.vim instead of init.lua, remember to wrap block below with `lua << EOF` and `EOF`
```lua
require('specs').setup{ 
    show_jumps  = true,
    min_jump = 30,
    popup = {
        delay_ms = 0, -- delay before popup displays
        inc_ms = 10, -- time increments used for fade/resize effects 
        blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
        width = 10,
        winhl = "PMenu",
        fader = require('specs').linear_fader,
        resizer = require('specs').shrink_resizer
    }
}
```

Faders:
- linear_fader   `▁▂▂▃▃▄▄▅▅▆▆▇▇██`
- exp_fader      `▁▁▁▁▂▂▂▃▃▃▄▄▅▆▇`

- pulse_fader    `▁▂▃▄▅▆▇█▇▆▅▄▃▂▁`

- empty_fader    `▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁`

Resizers:
- shrink_resizer `░░▒▒▓█████▓▒▒░░`

- slide_resizer  `████▓▓▓▒▒▒▒░░░░`

- empty_resizer  `███████████████`

You can implement your own custom fader/resizer functions for some pretty cool effects:
```lua
require('specs').setup{ 
    popup = {
	-- Simple constant blend effect
        fader = function(blend, cnt)
            if cnt > 100 then
                return 80
            else return nil end
        end,
	-- Growing effect from left to right
        resizer = function(width, ccol, cnt)
            if width-cnt > 0 then
                return {width+cnt, ccol}
            else return nil end
        end,
    }
}
```
