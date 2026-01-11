local wezterm = require("wezterm")
local config = wezterm.config_builder()

config = {
    quit_when_all_windows_are_closed = false,
    automatically_reload_config = true,

    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,
    tab_max_width = 114514,

    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",

    font = wezterm.font("Maple Mono NF CN", { weight = "Bold" }),
    font_size = 14,

    default_cursor_style = "SteadyBar",
    -- color_scheme = "Catppuccin Mocha",
    color_scheme = "Monokai Pro (Gogh)",
    macos_window_background_blur = 70,
    window_background_opacity = 0.9,
    text_background_opacity = 0.9,

    window_padding = {
        left = 40,
        right = 40,
        top = 40,
        bottom = 30,
    },
    initial_cols = 110,
    initial_rows = 30,
}

function get_max_cols(window)
    local tab = window:active_tab()
    local cols = tab:get_size().cols
    return cols
end

wezterm.on(
    'window-config-reloaded',
    function(window)
        wezterm.GLOBAL.cols = get_max_cols(window)
    end
)

wezterm.on(
    'window-resized',
    function(window, pane)
        wezterm.GLOBAL.cols = get_max_cols(window)
    end
)

wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local title = tab.active_pane.title
        local full_title = '[' .. tab.tab_index + 1 .. '] ' .. title
        local pad_length = (wezterm.GLOBAL.cols // #tabs - #full_title) // 2
        if pad_length * 2 + #full_title > max_width then
            pad_length = (max_width - #full_title) // 2
        end
        return string.rep(' ', pad_length) .. full_title .. string.rep(' ', pad_length)
    end
)

return config
