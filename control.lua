event_listener = require('__event-listener__/branch-2/stable-version')
local modules = require("modules")

log(serpent.block(modules))
event_listener.add_events(modules)

script.on_nth_tick(60 * 60, modules.soft_evolution.check_researches_on_nth_tick)
