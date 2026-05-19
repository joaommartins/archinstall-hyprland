-- Hyprland Lua configuration (Hyprland >= 0.55).
-- Converted from hyprland.conf. The old .conf is kept alongside as a fallback,
-- but Hyprland prefers hyprland.lua when both exist.
-- See https://wiki.hypr.land/Configuring/Start/

------------------
---- HELPERS -----
------------------
local mod     = "SUPER"
local ipc     = "qs -c noctalia-shell ipc call"
local home    = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts"

----------------
---- COLORS ----
----------------
-- noctalia-shell currently emits noctalia-colors.conf (hyprlang). require()
-- can't load that, so we maintain a sibling .lua port. dofile takes an
-- absolute path; switch to require() if/when noctalia-shell ships a .lua
-- file under a clean module name.
dofile(home .. "/.config/hypr/noctalia/noctalia-colors.lua")

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("solaar --window=hide")
    -- Allow root-elevated X11 apps (e.g. gparted via polkit) to use XWayland.
    hl.exec_cmd("xhost +SI:localuser:root")
    -- hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user restart kanshi.service")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
    },

    misc = {
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },

    dwindle = {
        split_width_multiplier = 1.25,
        force_split = 2,
    },

    decoration = {
        rounding       = 20,
        rounding_power = 2,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    input = {
        repeat_delay = 300,
        repeat_rate  = 25,
        kb_options   = "compose:caps",
        touchpad = {
            clickfinger_behavior = true,
            tap_to_click         = false,
            natural_scroll       = true,
            disable_while_typing = true,
        },
    },
})

-------------------
---- LAYER RULE ---
-------------------
hl.layer_rule({
    name  = "noctalia",
    match = { namespace = "noctalia-background-.*$" },
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

-- Lid switch
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd(scripts .. "/lid-close.sh"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(scripts .. "/lid-open.sh"),  { locked = true })

-- Core
hl.bind(mod .. " + SPACE",     hl.dsp.exec_cmd(ipc .. " launcher toggle"))
hl.bind(mod .. " + S",         hl.dsp.exec_cmd(ipc .. " controlCenter toggle"))
hl.bind(mod .. " + comma",     hl.dsp.exec_cmd(ipc .. " settings toggle"))
hl.bind(mod .. " + l",         hl.dsp.exec_cmd("bash -c 'pidof hyprlock || hyprlock & sleep 5; hyprctl dispatch dpms off; " .. scripts .. "/suspend-if-locked.sh 30'"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("bash -c 'pidof hyprlock || hyprlock & sleep 5; systemctl suspend'"))
hl.bind(mod .. " + return",    hl.dsp.exec_cmd("ghostty"))
hl.bind(mod .. " + B",         hl.dsp.exec_cmd("firefox"))

-- Screenshot
hl.bind(mod .. " + P",         hl.dsp.exec_cmd(scripts .. "/screenshot_selection.sh"))
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd(scripts .. "/screenshot_display.sh"))
hl.bind(mod .. " + CTRL + P",  hl.dsp.exec_cmd(scripts .. "/screenshot_window.sh"))

-- Clipboard history
hl.bind(mod .. " + v",      hl.dsp.exec_cmd(ipc .. " launcher clipboard"))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pamixer --default-source -t"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- Media
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind(mod .. " + period", hl.dsp.exec_cmd(ipc .. " launcher emoji"))

-- Window management
hl.bind(mod .. " + f",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + m",         hl.dsp.window.fullscreen({ mode = 1 }))  -- TODO: verify fullscreen dispatcher signature
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())

-- Workspace switching + move-to-workspace (1..9, 0 -> 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move focus
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mouse drag / resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active (repeating)
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.resize({ x =  10, y =   0, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -10, y =   0, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.resize({ x =   0, y = -10, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.resize({ x =   0, y =  10, relative = true }), { repeating = true })

-- Move active window by direction
hl.bind("SUPER + ALT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + ALT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + ALT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + ALT + J", hl.dsp.window.move({ direction = "d" }))
