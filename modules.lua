local modules = {}
modules.soft_evolution = require("soft_evolution/control")
modules.custom_events = {}
modules.custom_events.events = {}
modules.custom_events.handle_events = function()
  -- Searching events "on_round_start" and "on_round_end"
  for interface_name, _ in pairs( remote.interfaces ) do
    local function_name = "get_event_name"
    if remote.interfaces[interface_name][function_name] then
      local ID_1 = remote.call(interface_name, function_name, "on_round_start")
      local ID_2 = remote.call(interface_name, function_name, "on_round_end")
      if (type(ID_1) == "number") and (type(ID_2) == "number") then
        if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
          local interface_function = "get_teams"

          -- Attach "on_round_end"
          script.on_event(ID_1, function()
            local soft_evolution = storage.soft_evolution
            if remote.interfaces[interface_name] then
              if remote.interfaces[interface_name][interface_function] then
                soft_evolution.teams = remote.call(interface_name, interface_function)
              end
            end
          end)

          -- Attach "on_round_end"
          script.on_event(ID_2, function()
            local soft_evolution = storage.soft_evolution
            if remote.interfaces[interface_name] then
              if remote.interfaces[interface_name][interface_function] then
                soft_evolution.teams = {}
              end
            end
          end)
        end
      end
    end
  end
end
modules.custom_events.on_load = modules.custom_events.handle_events
modules.custom_events.on_init = modules.custom_events.handle_events

return modules
