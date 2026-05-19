-- Color palette for Hyprland, mirrored from noctalia-shell.
-- Originally noctalia-colors.conf (hyprlang). If noctalia-shell starts
-- emitting .lua, this file can be replaced wholesale by its output.

local primary       = "rgb(bfc2ff)"
local surface       = "rgb(131316)"
local secondary     = "rgb(c5c4dd)"
local error_color   = "rgb(ffb4ab)"
-- Defined for parity with the .conf even though not consumed below:
local tertiary       = "rgb(e8b9d5)"
local surface_lowest = "rgb(0e0e11)"

hl.config({
    general = {
        col = {
            active_border   = primary,
            inactive_border = surface,
        },
    },

    group = {
        col = {
            border_active          = secondary,
            border_inactive        = surface,
            border_locked_active   = error_color,
            border_locked_inactive = surface,
        },
        groupbar = {
            col = {
                active          = secondary,
                inactive        = surface,
                locked_active   = error_color,
                locked_inactive = surface,
            },
        },
    },
})
