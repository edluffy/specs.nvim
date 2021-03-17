# specs.nvim 👓
Show where your cursor moves when jumping large distances (e.g between windows). Fast and lightweight, written completely in Lua. WIP.

![demo](https://user-images.githubusercontent.com/28115337/111098526-90923e00-853b-11eb-8e7c-c5892d64c180.gif)
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
        fader = require('specs').linear_fader,
        resizer = require('specs').shrink_resizer
    }
}
```
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
