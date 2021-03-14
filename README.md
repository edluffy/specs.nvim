# specs.nvim 👓
Specs.nvim - show where your cursor moves when jumping large distances (e.g between windows). Fast and lightweight, written completely in Lua.

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
```
require('specs').setup{ 
    show_jumps  = true,
    min_jump = 30,
    popup = {
        delay_ms = 0, 
        inc_ms = 10,
        blend = 10,
        width = 10,
        fader = require('specs').linear_fader,
        resizer = require('specs').shrink_resizer
    }
}
```
