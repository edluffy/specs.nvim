local opts = {}

local M = {}

local old_cur
local old_win

function M.on_cursor_moved()
    local win = vim.api.nvim_get_current_win()
    if old_win then
        if(win ~= old_win) then
            M.show_specs()
        end
    end
    old_win = win

    local cur = vim.api.nvim_win_get_cursor(0)
    if old_cur then
        jump = math.abs(cur[1]-old_cur[1])
        if jump >= opts.min_jump then
            M.show_specs()
        end
    end
    -- print(vim.inspect(cur))

    old_cur = cur
end

function M.show_specs()
    local row = vim.fn.winline()-1
    local col = vim.fn.wincol()
    local bufh = vim.api.nvim_create_buf(false, true)
    win_id = vim.api.nvim_open_win(bufh, false, {
        relative='win',
        width = opts.popup.width*2 + 1,
        height = 1, 
        col = col,
        row = row,
        style = 'minimal'
    })
    vim.api.nvim_win_set_option(win_id, "winblend", opts.popup.blend)

    local can_fade = true
    local can_resize = true
    local timer = vim.loop.new_timer()
    vim.loop.timer_start(timer, opts.popup.delay_ms, opts.popup.inc_ms, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win_id) then
            if can_fade then can_fade = opts.popup.fader(win_id) end
            if can_resize then can_resize = opts.popup.resizer(win_id) end
            if not (can_blend or can_resize) then
                vim.loop.close(timer)
                vim.api.nvim_win_close(win_id, true)
                -- print("Timer done")
            end
        end
    end))
end

-- Used as the default fader
function M.linear_fader(win_id)
    local blend = vim.api.nvim_win_get_option(win_id, "winblend")
    vim.api.nvim_win_set_option(win_id, "winblend", blend+1)
    return (blend+1 < 100)
end

function M.pulse_fader(win_id)
end

-- function M.exp_fader()
-- end

function M.shrink_resizer(win_id)
    local config = vim.api.nvim_win_get_config(win_id)
    config['width'] = config['width']-1
    config['col'][false] = vim.fn.wincol()-config['width']/2
    vim.api.nvim_win_set_config(win_id, config)
    return (config['width']-1 > 0)
end

function M.slide_resizer(win_id)
    local config = vim.api.nvim_win_get_config(win_id)
    config['width'] = config['width']-1
    vim.api.nvim_win_set_config(win_id, config)
    return (config['width']-1 > 0)
end

-- function M.exp_resizer()
-- end
--

function M.setup(user_opts)
    opts = user_opts or {}
    M.create_autocmds(opts)
end

function M.create_autocmds(opts)
    vim.cmd("augroup Specs")
    vim.cmd("autocmd!")
    if opts.show_jumps then
        vim.cmd("silent autocmd CursorMoved * :lua require('specs').on_cursor_moved()")
    end
    vim.cmd("augroup END")
end


return M
