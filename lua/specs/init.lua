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
    vim.api.nvim_win_set_option(win_id, "winblend", opts.popup.blend)

    local cnt = 0
    local config = vim.api.nvim_win_get_config(win_id)
    local timer = vim.loop.new_timer()

    vim.loop.timer_start(timer, opts.popup.delay_ms, opts.popup.inc_ms, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win_id) then
            local bl = opts.popup.fader(win_id, opts.popup.blend, cnt)
            local dm = opts.popup.resizer(win_id, {opts.popup.width, cursor_col}, cnt)

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

function M.linear_fader(win_id, bl, cnt)
    if bl + cnt <= 100 then
        return cnt
    else return nil end
end


--[[ ▁▁▁▁▂▂▂▃▃▃▄▄▅▆▇ ]]--

function M.exp_fader(win_id, bl, cnt)
    if bl + math.floor(math.exp(cnt/10)) <= 100 then
        return bl + math.floor(math.exp(cnt/10))
    else return nil end
end


--[[ ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁ ]]--
             
function M.pulse_fader(win_id, bl, cnt)
    if cnt < (100-bl)/2 then
        return cnt
    elseif cnt < 100-bl then
        return 100-cnt
    else return nil end
end

--[[ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ]]--

function M.empty_fader(win_id, bl, cnt)
    return nil
end


--[[ ░░▒▒▓█████▓▒▒░░ ]]--

function M.shrink_resizer(win_id, dm, cnt)
    width = dm[1]-cnt
    col = dm[2] - width/2 +1
    if width > 0 then
        return {width, col}
    else return nil end
end


--[[ ████▓▓▓▒▒▒▒░░░░ ]]--

function M.slide_resizer(win_id, dm, cnt)
    width = dm[1]-cnt
    col = dm[2]
    if width > 0 then
        return {width, col}
    else return nil end
end


--[[ ███████████████ ]]--

function M.empty_resizer(win_id, dm, cnt)
    if cnt < 100 then
        width = dm[1]
        col = dm[2] - width/2
        return {width, col}
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
