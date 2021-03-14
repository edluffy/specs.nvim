if !has('nvim') || exists('g:loaded_specs')
	finish
endif

let g:loaded_specs = 1

" fun! Specs()
"     lua for k in pairs(package.loaded) do if k:match("^specs") then package.loaded[k] = nil end end
" endfun

" augroup Specs
" 	autocmd!
" augroup END
