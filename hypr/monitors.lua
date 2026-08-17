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

local M = {}

local monitor_mode = "mirror"
local monitor_layout_signature = nil
local split_workspace_rules = {}
local known_monitors = {}

local function remember_monitor(monitor)
    if monitor ~= nil and monitor.name ~= nil then
        known_monitors[monitor.name] = monitor
    end
end

local function forget_monitor(monitor)
    if monitor ~= nil and monitor.name ~= nil then
        known_monitors[monitor.name] = nil
    end
end

local function get_known_monitors()
    local result = {}
    local seen = {}

    for _, monitor in ipairs(hl.get_monitors()) do
        remember_monitor(monitor)
        table.insert(result, monitor)
        seen[monitor.name] = true
    end

    -- Mirrored outputs are not returned by hl.get_monitors(). Keep using the
    -- monitor object received from monitor.added while the output is mirrored.
    for name, monitor in pairs(known_monitors) do
        if not seen[name] then
            table.insert(result, monitor)
        end
    end

    return result
end

local function is_primary_candidate(name)
    return name:match("^eDP%-") ~= nil or name:match("^DP%-") ~= nil
end

local function is_hdmi(name)
    return name:match("^HDMI%-") ~= nil
end

local function is_dp(name)
    return name:match("^DP%-") ~= nil
end

local function get_primary_monitor(monitors)
    -- The first eDP-* or DP-* monitor is the primary monitor.
    for _, monitor in ipairs(monitors) do
        if is_primary_candidate(monitor.name) then
            return monitor
        end
    end

    return nil
end

local function get_external_monitors(monitors, primary)
    local result = {}

    for _, monitor in ipairs(monitors) do
        if is_hdmi(monitor.name)
            or (is_dp(monitor.name) and monitor.name ~= primary.name) then
            table.insert(result, monitor)
        end
    end

    return result
end

local function disable_split_workspace_rules()
    for _, rule in ipairs(split_workspace_rules) do
        rule:set_enabled(false)
    end

    split_workspace_rules = {}
end

local function create_workspace_rules(primary, secondary)
    disable_split_workspace_rules()

    for workspace = 1, 10 do
        local monitor = primary

        if monitor_mode == "split" and workspace >= 6 then
            monitor = secondary
        end

        table.insert(split_workspace_rules, hl.workspace_rule({
            workspace = tostring(workspace),
            monitor = monitor.name,
            enabled = true,
        }))
    end
end

local function get_target_monitor(workspace_id, primary, secondary)
    if workspace_id < 1 or workspace_id > 10 then
        return nil
    end

    if monitor_mode == "split" and workspace_id >= 6 then
        return secondary
    end

    return primary
end

local function move_existing_workspaces(primary, secondary)
    for _, workspace in ipairs(hl.get_workspaces()) do
        local target = get_target_monitor(workspace.id, primary, secondary)

        if workspace.windows > 0
            and target ~= nil
            and (workspace.monitor == nil or workspace.monitor.name ~= target.name) then
            hl.dispatch(hl.dsp.workspace.move({
                workspace = tostring(workspace.id),
                monitor = target.name,
            }))
        end
    end
end

local function move_created_workspace(workspace)
    local monitors = get_known_monitors()
    local primary = get_primary_monitor(monitors)
    if primary == nil then
        return
    end

    local external_monitors = get_external_monitors(monitors, primary)
    if #external_monitors == 0 then
        return
    end

    local target = get_target_monitor(workspace.id, primary, external_monitors[1])
    if target == nil or workspace.monitor == nil or workspace.monitor.name == target.name then
        return
    end

    hl.timer(function()
        hl.dispatch(hl.dsp.workspace.move({
            workspace = tostring(workspace.id),
            monitor = target.name,
        }))
    end, { timeout = 1, type = "oneshot" })
end

local function apply_monitor_mode(force)
    local monitors = get_known_monitors()
    local primary = get_primary_monitor(monitors)

    if primary == nil then
        disable_split_workspace_rules()
        monitor_layout_signature = "no-primary"
        return
    end

    local external_monitors = get_external_monitors(monitors, primary)
    if #external_monitors == 0 then
        disable_split_workspace_rules()
        monitor_layout_signature = "no-external|" .. primary.name
        return
    end

    local names = {}
    for _, monitor in ipairs(external_monitors) do
        table.insert(names, monitor.name)
    end
    table.sort(names)

    local signature = monitor_mode .. "|" .. primary.name .. "|" .. table.concat(names, ",")
    if not force and signature == monitor_layout_signature then
        return
    end
    monitor_layout_signature = signature

    for _, monitor in ipairs(external_monitors) do
        hl.monitor({
            output = monitor.name,
            mode = "preferred",
            position = "2560x0",
            scale = 1,
            mirror = monitor_mode == "mirror" and primary.name or "",
        })
    end

    -- Reconfiguring a mirrored output is asynchronous. Move workspaces only
    -- after the output has finished switching to/from mirror mode.
    hl.timer(function()
        local current_monitors = get_known_monitors()
        local current_primary = get_primary_monitor(current_monitors)
        if current_primary == nil then
            return
        end

        local current_external = get_external_monitors(current_monitors, current_primary)
        if #current_external == 0 then
            return
        end

        create_workspace_rules(current_primary, current_external[1])

        -- Workspace rules are applied at the end of the current Lua callback.
        -- Refresh them before moving already existing workspaces.
        hl.exec_scheduled_prop_refresh_immediately()

        move_existing_workspaces(current_primary, current_external[1])
    end, { timeout = 1, type = "oneshot" })
end

function M.toggle_mode()
    local monitors = get_known_monitors()
    local primary = get_primary_monitor(monitors)

    if primary == nil or #get_external_monitors(monitors, primary) == 0 then
        return
    end

    monitor_mode = monitor_mode == "mirror" and "split" or "mirror"
    apply_monitor_mode(true)
end

hl.on("hyprland.start", function()
    apply_monitor_mode(true)
end)

hl.on("monitor.added", function(monitor)
    remember_monitor(monitor)
    apply_monitor_mode(true)
end)

hl.on("monitor.removed", function(monitor)
    forget_monitor(monitor)
    apply_monitor_mode(true)
end)

hl.on("monitor.layout_changed", function()
    apply_monitor_mode(false)
end)

hl.on("workspace.created", function(workspace)
    if monitor_mode == "split" then
        move_created_workspace(workspace)
    end
end)

return M
