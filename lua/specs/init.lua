local opts = {}
local M = {}

local old_cur

function M.on_cursor_moved()
    local cur = vim.api.nvim_win_get_cursor(0)
    if old_cur then
        jump = math.abs(cur[1]-old_cur[1])
        if jump >= opts.min_jump then
            M.show_specs()
        end
    end
    old_cur = cur
end

function M.show_specs()
    local bufh = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufh, false, {
        relative='win',
        width = 1,
        height = 1, 
        col = vim.fn.wincol()-1,
        row = vim.fn.winline()-1,
        style = 'minimal'
    })

    local cnt = 0
    local timer = vim.loop.new_timer()
    vim.loop.timer_start(timer, opts.popup.delay_ms, opts.popup.inc_ms, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win_id) then
            local fade_done = opts.popup.fader(win_id, cnt)
            local resize_done = opts.popup.resizer(win_id, cnt)

            if fade_done and resize_done then
                vim.loop.close(timer)
                vim.api.nvim_win_close(win_id, true)
            end
            cnt = cnt+1
        end
    end))
end

-- Used as the default fader
--[[ ▁▁▂▂▃▃▄▄▅▅▆▆▇▇██ ]]--

function M.linear_fader(win_id, cnt)
    if opts.popup.blend+cnt < 100 then
        vim.api.nvim_win_set_option(win_id, "winblend", opts.popup.blend+cnt)
        return false
    else return true end
end


--[[ ▁▁▁▁▂▂▂▃▃▃▄▄▅▆▇ ]]--

function M.exp_fader(win_id, cnt)
    local new_bl = math.floor(opts.popup.blend+math.exp(cnt/10))
    if new_bl < 100 then
        vim.api.nvim_win_set_option(win_id, "winblend", new_bl)
        return false
    else return true end
end


--[[ ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁ ]]--

function M.pulse_fader(win_id, cnt)
    local bl = opts.popup.blend
    if cnt < (100-bl)/2 then
        vim.api.nvim_win_set_option(win_id, "winblend", bl+cnt)
        return false
    elseif cnt < 100-bl then
        vim.api.nvim_win_set_option(win_id, "winblend", 100-cnt)
        return false
    else return true end
end


--[[ ░░▒▒▓█████▓▒▒░░ ]]--

function M.shrink_resizer(win_id, cnt)
    if opts.popup.width-cnt > 0 then
        local config = {
            relative = "win",
            row = vim.fn.winline()-1,
            col = { 
                [false] = vim.fn.wincol()-(opts.popup.width-cnt)/2,
                [true] = 3 -- temporary
            },
        }
        vim.api.nvim_win_set_width(win_id, opts.popup.width-cnt)
        vim.api.nvim_win_set_config(win_id, config)
        return false
    else return true end
end


--[[ ████▓▓▓▒▒▒▒░░░░ ]]--

function M.slide_resizer(win_id, cnt)
    if opts.popup.width-cnt > 0 then
        vim.api.nvim_win_set_width(win_id, opts.popup.width-cnt)
        return false
    else return true end
end


--[[ ███████████████ ]]--

function M.empty_resizer(win_id, cnt)
    if opts.popup.width-cnt > 0 then
        vim.api.nvim_win_set_width(win_id, opts.popup.width)
        return false
    else return true end
end

-- function M.exp_resizer()
-- end
--

function M.setup(user_opts)
    opts = user_opts or {}
    M.create_autocmds(opts)
end

function M.create_autocmds(opts)
    vim.cmd("augroup Specs") vim.cmd("autocmd!")
    if opts.show_jumps then
        vim.cmd("silent autocmd CursorMoved * :lua require('specs').on_cursor_moved()")
    end
    vim.cmd("augroup END")
end


return M
