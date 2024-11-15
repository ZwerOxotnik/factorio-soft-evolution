if script.level.level_name == "sandbox" then return end -- Don't init if it's "sandbox" scenario


---@type table<string, module>
local modules = require("modules")


-- Safe disabling of this mod remotely on init stage
-- Useful for other map developers and in some rare cases for mod devs
if remote.interfaces["disable-" .. script.mod_name] then
	for _, module in pairs(modules) do
		local update_global_data_on_disabling = module.update_global_data_on_disabling
		module.events = nil
		module.on_nth_tick = nil
		module.commands = nil
		module.on_load = nil
		module.add_remote_interface = nil
		module.add_commands = nil
		module.on_configuration_changed = update_global_data_on_disabling
		module.on_init = update_global_data_on_disabling
	end
end


local event_handler
if script.active_mods["zk-lib"] then
	-- Same as Factorio "event_handler", but slightly better performance
	local is_ok, zk_event_handler = pcall(require, "__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
	if is_ok then
		event_handler = zk_event_handler
	end
end
event_handler = event_handler or require("event_handler")
event_handler.add_libraries(modules)


-- Auto adds remote access for rcon and for other mods/scenarios via zk-lib
if script.active_mods["zk-lib"] then
	local is_ok, remote_interface_util = pcall(require, "__zk-lib__/static-libs/lualibs/control_stage/remote-interface-util")
	if is_ok and remote_interface_util.expose_global_data then
		remote_interface_util.expose_global_data()
	end
	local is_ok, rcon_util = pcall(require, "__zk-lib__/static-libs/lualibs/control_stage/rcon-util")
	if is_ok and rcon_util.expose_global_data then
		rcon_util.expose_global_data()
	end
end


-- This is a part of "gvv", "Lua API global Variable Viewer" mod. https://mods.factorio.com/mod/gvv
-- It makes possible gvv mod to read sandboxed variables in the map or other mod if following code is inserted at the end of empty line of "control.lua" of each.
if script.active_mods["gvv"] then require("__gvv__.gvv")() end
