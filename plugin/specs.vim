fun! Specs()
    " remember to remove this line later ;)
	lua for k in pairs(package.loaded) do if k:match("^specs") then package.loaded[k] = nil end end
	lua require('specs').show_specs({ delay_ms = 1, inc_ms = 10, blend = 10, width = 20, fader=require('specs').linear_fader, resizer=require('specs').shrink_resizer })
endfun

    " e.g:
    " require('specs').specs_popup({
    "   delay = ...,
    "   reps = ...,
    "   blend = ...,
    "   width = ...,
    "   fader    = require('specs').linear_fader(),
    "   resizer  = require('specs').shrink_resizer()
    "   colorizer = ...,
    " })


    " pre-packaged opts could come as 'styles', which also have opts
    " themselves:
    " require('specs').specs_popup(require('specs').blink_style({ }))

augroup Specs
	autocmd!
augroup END

