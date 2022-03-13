local M = {}

local uv = vim.loop
local api = vim.api

local opts = {}

local old_cursor

function M.on_cursor_moved()
    local cursor = api.nvim_win_get_cursor(0)
    if old_cursor then
        local jump = math.abs(cursor[1] - old_cursor[1])
        if jump >= opts.min_jump then
            M.show_specs()
        end
    end
    old_cursor = cursor
end

function M.on_win_enter()
    if opts.show_on_win_enter then
        M.show_specs()
    end
end

local function should_show_specs(start_winid)
    return api.nvim_win_is_valid(start_winid)
        and not opts.ignore_buftypes[vim.bo.buftype]
        and not opts.ignore_filetypes[vim.bo.filetype]
end

local timer

function M.show_specs()
    if timer and timer:is_active() then
        -- happens on WinEnter
        return
    end

    local start_winid = api.nvim_get_current_win()
    if not should_show_specs(start_winid) then
        return
    end

    local cursor_col = vim.fn.wincol() - 1
    local cursor_row = vim.fn.winline() - 1
    local bufh = api.nvim_create_buf(false, true)
    local win_id = api.nvim_open_win(bufh, false, {
        relative = 'win',
        width = 1,
        height = 1,
        col = cursor_col,
        row = cursor_row,
        style = 'minimal',
    })
    vim.wo[win_id].winhl = 'Normal:' .. opts.popup.winhl
    vim.wo[win_id].winblend = opts.popup.blend

    local cnt = 0
    local config = api.nvim_win_get_config(win_id)
    local closed = false

    timer = uv.new_timer()
    timer:start(
        opts.popup.delay_ms,
        opts.popup.inc_ms,
        vim.schedule_wrap(function()
            if closed or api.nvim_get_current_win() ~= start_winid then
                if not closed then
                    pcall(uv.close, timer)
                    pcall(api.nvim_win_close, win_id, true)

                    -- Callbacks might stack up before the timer actually gets closed, track that state
                    -- internally here instead
                    closed = true
                end
                return
            end

            if api.nvim_win_is_valid(win_id) then
                local bl = opts.popup.fader(opts.popup.blend, cnt)
                local dm = opts.popup.resizer(opts.popup.width, cursor_col, cnt)

                if bl ~= nil then
                    vim.wo[win_id].winblend = bl
                end
                if dm ~= nil then
                    config['col'][false] = dm[2]
                    api.nvim_win_set_config(win_id, config)
                    api.nvim_win_set_width(win_id, dm[1])
                end
                if bl == nil and dm == nil then -- Done blending and resizing
                    timer:close()
                    api.nvim_win_close(win_id, true)
                end
                cnt = cnt + 1
            end
        end)
    )
end

--[[ ▁▁▂▂▃▃▄▄▅▅▆▆▇▇██ ]]
--

function M.linear_fader(blend, cnt)
    if blend + cnt <= 100 then
        return cnt
    else
        return nil
    end
end

--[[ ▁▁▁▁▂▂▂▃▃▃▄▄▅▆▇ ]]
--

function M.exp_fader(blend, cnt)
    if blend + math.floor(math.exp(cnt / 10)) <= 100 then
        return blend + math.floor(math.exp(cnt / 10))
    else
        return nil
    end
end

--[[ ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁ ]]
--

function M.pulse_fader(blend, cnt)
    if cnt < (100 - blend) / 2 then
        return cnt
    elseif cnt < 100 - blend then
        return 100 - cnt
    else
        return nil
    end
end

--[[ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ]]
--

function M.empty_fader(_, _)
    return nil
end

--[[ ░░▒▒▓█████▓▒▒░░ ]]
--

function M.shrink_resizer(width, ccol, cnt)
    if width - cnt > 0 then
        return { width - cnt, ccol - (width - cnt) / 2 + 1 }
    else
        return nil
    end
end

--[[ ████▓▓▓▒▒▒▒░░░░ ]]
--

function M.slide_resizer(width, ccol, cnt)
    if width - cnt > 0 then
        return { width - cnt, ccol }
    else
        return nil
    end
end

--[[ ███████████████ ]]
--

function M.empty_resizer(width, ccol, cnt)
    if cnt < 100 then
        return { width, ccol - width / 2 }
    else
        return nil
    end
end

local enabled

function M.create_autocmds()
    vim.cmd [[
    augroup Specs
    autocmd!
    " Add delay to correct cursor position, some users may use plugins like 'lastplace',
    " which may cause the popup position to be displayed inaccurately
    silent autocmd CursorMoved * lua vim.defer_fn(require('specs').on_cursor_moved, 5)
    silent autocmd WinEnter    * lua vim.defer_fn(require('specs').on_win_enter, 5)
    augroup END
  ]]
    enabled = true
end

function M.clear_autocmds()
    vim.cmd 'augroup Specs | autocmd! | augroup END'
    enabled = false
end

function M.toggle()
    if enabled then
        M.clear_autocmds()
    else
        M.create_autocmds()
    end
end

local function get_default_opts()
    return {
        show_jumps = true,
        show_on_win_enter = false,
        min_jump = 30,
        popup = {
            delay_ms = 10,
            inc_ms = 5,
            blend = 10,
            width = 20,
            winhl = 'PMenu',
            fader = M.exp_fader,
            resizer = M.shrink_resizer,
        },
        ignore_filetypes = {
            TelescopePrompt = true,
        },
        ignore_buftypes = {
            nofile = true,
        },
    }
end

function M.setup(user_opts)
    opts = vim.tbl_deep_extend('force', get_default_opts(), user_opts)
    if opts.show_jumps then
        M.create_autocmds()
    end
end

return M
