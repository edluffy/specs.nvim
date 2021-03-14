local specs = {}

function specs.show_specs(user_opts)
    local opts = user_opts or {}

    local row = vim.fn.winline()-1
    local col = vim.fn.wincol()
    local bufh = vim.api.nvim_create_buf(false, true)
    win_id = vim.api.nvim_open_win(bufh, false, {
        relative='win',
        width = opts.width*2 + 1,
        height = 1, 
        col = col,
        row = row,
        style = 'minimal'
    })
    vim.api.nvim_win_set_option(win_id, "winblend", opts.blend)

    local can_fade = true
    local can_resize = true
    local timer = vim.loop.new_timer()
    vim.loop.timer_start(timer, opts.delay_ms, opts.inc_ms, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win_id) then
            if can_fade then can_fade = opts.fader(win_id) end
            if can_resize then can_resize = opts.resizer(win_id) end
            if not (can_blend or can_resize) then
                vim.loop.close(timer)
                vim.api.nvim_win_close(win_id, true)
                print("Timer done")
            end
        end
    end))
end

-- Used as the default fader
function specs.linear_fader(win_id)
    local blend = vim.api.nvim_win_get_option(win_id, "winblend")
    vim.api.nvim_win_set_option(win_id, "winblend", blend+1)
    return (blend+1 < 100)
end

local function pulse_fader(win_id)
end

-- local function exp_fader()
-- end

function specs.shrink_resizer(win_id)
    local config = vim.api.nvim_win_get_config(win_id)
    config['width'] = config['width']-1
    config['col'][false] = vim.fn.wincol()-config['width']/2
    vim.api.nvim_win_set_config(win_id, config)
    return (config['width']-1 > 0)
end

function specs.slide_resizer(win_id)
    local config = vim.api.nvim_win_get_config(win_id)
    config['width'] = config['width']-1
    vim.api.nvim_win_set_config(win_id, config)
    return (config['width']-1 > 0)
end

-- local function exp_resizer()
-- end

return specs
