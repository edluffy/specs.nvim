local M = {}
local opts = {}

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
    local cursor_col = vim.fn.wincol()-1
    local cursor_row = vim.fn.winline()-1
    local bufh = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufh, false, {
        relative='win',
        width = 1,
        height = 1, 
        col = cursor_col,
        row = cursor_row,
        style = 'minimal'
    })
    vim.api.nvim_win_set_option(win_id, 'winhl', 'Normal:'.. opts.popup.winhl)
    vim.api.nvim_win_set_option(win_id, "winblend", opts.popup.blend)

    

    local cnt = 0
    local config = vim.api.nvim_win_get_config(win_id)
    local timer = vim.loop.new_timer()

    vim.loop.timer_start(timer, opts.popup.delay_ms, opts.popup.inc_ms, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win_id) then
            local bl = opts.popup.fader(opts.popup.blend, cnt)
            local dm = opts.popup.resizer(opts.popup.width, cursor_col, cnt)

            if bl ~= nil then
                vim.api.nvim_win_set_option(win_id, "winblend", bl)
            end
            if dm ~= nil then
                config["col"][false] = dm[2]
                vim.api.nvim_win_set_config(win_id, config)
                vim.api.nvim_win_set_width(win_id, dm[1])
            end
            if bl == nil and dm == nil then -- Done blending and resizing
                vim.loop.close(timer)
                vim.api.nvim_win_close(win_id, true)
            end
            cnt = cnt+1
        end
    end))
end

--[[ ▁▁▂▂▃▃▄▄▅▅▆▆▇▇██ ]]--

function M.linear_fader(blend, cnt)
    if blend + cnt <= 100 then
        return cnt
    else return nil end
end


--[[ ▁▁▁▁▂▂▂▃▃▃▄▄▅▆▇ ]]--

function M.exp_fader(blend, cnt)
    if blend + math.floor(math.exp(cnt/10)) <= 100 then
        return blend + math.floor(math.exp(cnt/10))
    else return nil end
end


--[[ ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁ ]]--
             
function M.pulse_fader(blend, cnt)
    if cnt < (100-blend)/2 then
        return cnt
    elseif cnt < 100-blend then
        return 100-cnt
    else return nil end
end

--[[ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ]]--

function M.empty_fader(blend, cnt)
    return nil
end


--[[ ░░▒▒▓█████▓▒▒░░ ]]--

function M.shrink_resizer(width, ccol, cnt)
    if width-cnt > 0 then
        return {width-cnt, ccol-(width-cnt)/2 + 1}
    else return nil end
end


--[[ ████▓▓▓▒▒▒▒░░░░ ]]--

function M.slide_resizer(width, ccol, cnt)
    if width-cnt > 0 then
        return {width-cnt, ccol}
    else return nil end
end


--[[ ███████████████ ]]--

function M.empty_resizer(width, ccol, cnt)
    if cnt < 100 then
        return {width, ccol - width/2}
    else return nil end
end

local DEFAULT_OPTS = {
    show_jumps  = true,
    min_jump = 30,
    popup = {
        delay_ms = 10, 
        inc_ms = 5,
        blend = 10,
        width = 20,
        winhl = "PMenu",
        fader = M.exp_fader,
        resizer = M.shrink_resizer
    }
}

function M.setup(user_opts)
    opts = vim.tbl_deep_extend("force", DEFAULT_OPTS, user_opts)
    M.create_autocmds()
end

function M.create_autocmds()
    vim.cmd("augroup Specs") vim.cmd("autocmd!")
    if opts.show_jumps then
        vim.cmd("silent autocmd CursorMoved * :lua require('specs').on_cursor_moved()")
    end
    vim.cmd("augroup END")
end


return M
