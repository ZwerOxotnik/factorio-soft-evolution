local event_listener = require("event_listener/control")
local list = require("modules")

event_listener.add_events(list)
script.on_nth_tick(60 * 60, list.soft_evolution.check_researches_on_nth_tick)
