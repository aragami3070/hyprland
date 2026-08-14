-- #######################################################################################
-- HYPRLAND LUA CONFIGURATION.
-- Converted from hyprland.conf while preserving its order and behavior.
-- #######################################################################################

-- This is an example Hyprland config file.
-- Refer to https://wiki.hypr.land/Configuring/

-- You can split this configuration into multiple files with require().

-- ################
-- ### MONITORS ###
-- ################

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = "",
    mode = "highres highrr",
    position = "0x0",
    scale = 1,
})

-- ###################
-- ### MY PROGRAMS ###
-- ###################

-- See https://wiki.hypr.land/Configuring/Basics/Dispatchers/

-- Set programs that you use
local terminal = "kitty"
local fileManager = "Thunar"
local menu = "wofi --show drun"
local browser = "firefox"
local editor = "nvim"

-- #################
-- ### AUTOSTART ###
-- #################
hl.on("hyprland.start", function()
    local amnezia_listener
    amnezia_listener = hl.on("window.open", function(window)
        if window.class == "AmneziaVPN" or window.initial_class == "AmneziaVPN" then
            hl.dispatch(hl.dsp.window.move({
                window = window,
                workspace = "4",
                follow = false,
            }))

            hl.timer(function()
                hl.dispatch(hl.dsp.focus({
                    workspace = "1",
                    on_current_monitor = true,
                }))
            end, { timeout = 1, type = "oneshot" })

            -- Обрабатываем только стартовое окно Amnezia
            amnezia_listener:remove()
        end
    end)

    hl.exec_cmd("hypridle & hyprsunset & syncthing")
    hl.exec_cmd("hyprpaper & sleep 1 && ~/.bin/hyprpaper-picker display-last")
    hl.exec_cmd("dunst --config ~/.config/dunst/dunstrc")
    hl.exec_cmd(browser, { workspace = "1 silent" })
    hl.exec_cmd(terminal, { workspace = "special:magic silent" })

    if hl.get_monitor("DP-2") ~= nil then
        hl.exec_cmd("chromium", { workspace = "2 silent" })
        hl.exec_cmd("Telegram", { workspace = "3 silent" })
        hl.exec_cmd("AmneziaVPN", { workspace = "4 silent" })
    else
        hl.exec_cmd("env QT_QPA_PLATFORM=xcb QT_QUICK_BACKEND=software AmneziaVPN", { workspace = "4 silent" })
    end
end)

-- #############################
-- ### ENVIRONMENT VARIABLES ###
-- #############################

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- For nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("__GL_VRR_ALLOWED", "1")
hl.env("WLR_DRM_NO_ATOMIC", "1")

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

-- debug:disable_logs = false

-- #####################
-- ### LOOK AND FEEL ###
-- #####################

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,

        border_size = 2,

        -- https://wiki.hypr.land/Configuring/Basics/Variables/
        col = {
            active_border = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        -- https://wiki.hypr.land/Configuring/Basics/Variables/
        blur = {
            enabled = false,
            size = 3,
            passes = 1,

            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", {
    type = "bezier",
    points = { { 0.23, 1 }, { 0.32, 1 } },
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = { { 0.65, 0.05 }, { 0.36, 1 } },
})
hl.curve("linear", {
    type = "bezier",
    points = { { 0, 0 }, { 1, 1 } },
})
hl.curve("almostLinear", {
    type = "bezier",
    points = { { 0.5, 0.5 }, { 0.75, 1 } },
})
hl.curve("quick", {
    type = "bezier",
    points = { { 0.15, 0 }, { 0.1, 1 } },
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    bezier = "easeOutQuint",
    style = "popin 87%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.49,
    bezier = "linear",
    style = "popin 87%",
})
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- Uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding = 0,
-- })
-- hl.window_rule({
--     name = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

-- #############
-- ### INPUT ###
-- #############

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    input = {
        kb_layout = "us, ru",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0.0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Empty `gestures {}` section from the original config has no effect.

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "compx-vgn-mouse-2.4g-receiver-1",
    sensitivity = -1.0,
})

-- ###################
-- ### KEYBINDINGS ###
-- ###################

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

-- Example binds
hl.bind("CTRL + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("if pgrep waybar; then pkill waybar; fi"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("if pgrep waybar; then pkill waybar; fi && waybar"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("hyprpicker --autocopy --quiet"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.bin/hyprpaper-picker next"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.bin/hyprpaper-picker prev"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.bin/hyprpaper-picker rand"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m region"))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Example special workspace (scratchpad)
hl.bind("ALT + TAB", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local repeatLocked = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"), repeatLocked)
hl.bind("XF86Search", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"), repeatLocked)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"), repeatLocked)
hl.bind("XF86Mail", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"), repeatLocked)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeatLocked)
hl.bind("XF86Explorer", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeatLocked)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 1%+"), repeatLocked)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 1%-"), repeatLocked)

-- NOTE: for pc
hl.bind(
    "XF86HomePage",
    hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10 | hyprctl hyprsunset temperature -10"),
    repeatLocked
)
-- NOTE: for laptop
hl.bind("F11", hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10 | hyprctl hyprsunset temperature -10"), repeatLocked)
hl.bind("F4", hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10 | hyprctl hyprsunset temperature -10"), repeatLocked)
hl.bind("F6", hl.dsp.exec_cmd("hyprsunset"), repeatLocked)
hl.bind("F7", hl.dsp.exec_cmd("killall hyprsunset"), repeatLocked)

-- Requires playerctl
-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ##############################
-- ### WINDOWS AND WORKSPACES ###
-- ##############################

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    name = "all-windows",
    match = {
        class = "^$",
        title = "^$",
        float = true,
    },
})

hl.window_rule({
    name = "AmneziaVPN",
    workspace = "unset",
    match = {
        class = "^(AmneziaVPN)$",
        float = true,
    },
})

hl.window_rule({
    name = "pavucontrol",
    match = {
        class = "^(pavucontrol)$",
        float = true,
    },
})

hl.window_rule({
    name = "showmethekey",
    match = {
        class = "^(one.alynx.showmethekey)$",
        float = true,
    },
})

hl.window_rule({
    name = "showmethekey_gtk",
    match = {
        class = "^(showmethekey-gtk)$",
        float = true,
    },
})

hl.window_rule({
    name = "fix_xwayland",
    match = {
        focus = false,
        class = "^$",
        title = "^$",
        xwayland = true,
        fullscreen = false,
        pin = false,
        float = true,
    },
})

-- For libadwaita GTK4 apps.
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')

-- For GTK3 apps; requires the adw-gtk3 theme.
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')

-- For KDE apps.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
