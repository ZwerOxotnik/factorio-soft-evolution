--[[
Copyright (c) 2019-2020, 2024 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the MIT licence;

You can write and receive any information on the links below.
Source: https://gitlab.com/ZwerOxotnik/soft-evolution
Mod portal: https://mods.factorio.com/mod/soft-evolution
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64653

]]--

local M = {}
M.self_events = require("soft_evolution/self_events")


local function reset_compensating_bonus()
	local mod_data = storage.soft_evolution
	local count = 1 - mod_data.compensating_bonus
	for _, force in pairs(game.forces) do
		if force.ai_controllable and force.get_evolution_factor() > 0.0001 then
			force.set_evolution_factor(force.get_evolution_factor() * (1 - count))
		end
	end
	mod_data.compensating_bonus = 1
end

local function change_evolution_due_research(target, pack)
	if pack.spended == 0 then return end
	if pack.spended > pack.total then return end

	local new_evolution = pack.spended / pack.total
	local change_evolution = function(force)
		if settings.global["soft_evolution_factor_decreases"].value then
			if force.get_evolution_factor() < new_evolution then
				force.set_evolution_factor(new_evolution)
			end
		else
			force.set_evolution_factor(new_evolution)
		end
	end

	for _, force in pairs(game.forces) do
		if force.ai_controllable then
			change_evolution(force)
		end
	end
end

local function count_science_pack(target, max_time_teams)
	local pack = {}
	pack.spended = 0
	pack.total   = 0

	for _, team in pairs (target) do
		local force = game.forces[team.name]
		if force then
			if #force.players ~= 0 then
				local time_team = 0
				if settings.global["soft_evolution_count_time_player"].value then
					for _, player in pairs (force.players) do
						time_team = time_team + player.online_time
					end
				end

				if (time_team + 1 > max_time_teams / 1000) and (not force.ai_controllable) and (force.technologies["logistics-2"].researched or not force.technologies["logistics-2"].enabled) then
					pack.spended = pack.spended + force.rockets_launched -- force.rockets_launched is not 'pack' :P
					for _, tech in pairs(force.technologies) do
						if tech.research_unit_count_formula == nil and not tech.upgrade then
							pack.total = pack.total + 1
							if tech.researched then
								pack.spended = pack.spended + 1
							end

							-- Another variant
							--[[
							local count = #tech.research_unit_ingredients
							pack.total = pack.total + count
							if tech.researched then
								pack.spended = pack.spended + count
							end
							]]--

							-- Another variant
							--[[
							for _, ingredient in pairs(tech.research_unit_ingredients) do
								pack.total = pack.total + ingredient.amount
								if tech.researched then
									pack.spended = pack.spended + ingredient.amount
								end
							end
							]]--
						end
					end
				end
			end
		else
			log(team.name .. " is not exist!")
		end
	end

	return pack
end

local function count_time_teams(target)
	local max_time_teams = 0 -- from 0 to 1
	if settings.global["soft_evolution_count_time_player"].value then
		for _, team in pairs (target) do
			local force = game.forces[team.name]
			if force and (force.technologies["logistics-2"].researched or not force.technologies["logistics-2"].enabled) then
				local time_team = 0
				for _, player in pairs (force.players) do
					time_team = time_team + player.online_time
				end
				if max_time_teams < time_team then
					max_time_teams = time_team
				end
			end
		end
	else
		max_time_teams = 1
	end

	return max_time_teams
end

local function check_evolution_due_research(target)
	local max_time_teams = count_time_teams(target)
	local pack = count_science_pack(target, max_time_teams)
	change_evolution_due_research(target, pack)

	storage.soft_evolution.tick_of_update = nil
end

local function balance_evolution_from_research()
	if storage.soft_evolution.teams then
		check_evolution_due_research(storage.soft_evolution.teams)
	else
		check_evolution_due_research(game.forces)
	end

	reset_compensating_bonus()
	script.raise_event(M.self_events.on_balance_evolution_from_researche, {})
end

M.on_init = function()
	storage.soft_evolution = storage.soft_evolution or {}
	local mod_data = storage.soft_evolution
	mod_data.teams = mod_data.teams or nil
	mod_data.tick_of_update = mod_data.tick_of_update -- see function "check_researches_on_nth_tick"
	mod_data.compensating_bonus = mod_data.compensating_bonus or 1 -- see event "on_entity_died"
	mod_data.dynamic_bonus = mod_data.dynamic_bonus or 1 -- see function "check_map_settings"
end

local function update_research_timer()
	storage.soft_evolution.tick_of_update = game.tick + (60 * 60)
end

local function on_entity_died(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if not (entity.type == "assembling-machine" and entity.products_finished > 300) then return end

	local count = 0.02

	for _, force in pairs(game.forces) do
		if force.ai_controllable and force.evolution_factor > 0.0001 then
			force.evolution_factor = force.evolution_factor * (1 - count)
		end
	end

	local mod_data = storage.soft_evolution
	mod_data.compensating_bonus = mod_data.compensating_bonus - count
	if mod_data.compensating_bonus < 0.5 then
		mod_data.compensating_bonus = 0.5
	end
end

local function change_map_settings()
	-- Find dynamic bonus
	local mod_data = storage.soft_evolution
	local connected_players = #game.connected_players
	local dynamic_bonus = (1 + connected_players) / 5
	if dynamic_bonus > 1.5 then
		dynamic_bonus = 1.5
	elseif dynamic_bonus < 0.5 then
		dynamic_bonus = 0.5
	end
	mod_data.dynamic_bonus = dynamic_bonus

	-- Apply dynamic bonus
	local original_data = mod_data.original
	local map_settings = game.map_settings
	local enemy_evolution = map_settings.enemy_evolution
	local enemy_expansion = map_settings.enemy_expansion
	log(math.floor(original_data.settler_group_min_size * dynamic_bonus))
	map_settings.settler_group_min_size = math.floor(original_data.settler_group_min_size * dynamic_bonus)
	map_settings.settler_group_max_size = math.ceil(original_data.settler_group_max_size * dynamic_bonus)
	enemy_expansion.max_expansion_distance = math.ceil(original_data.max_expansion_distance * dynamic_bonus)
	enemy_expansion.min_expansion_cooldown = original_data.min_expansion_cooldown / dynamic_bonus
	enemy_expansion.max_expansion_cooldown = original_data.max_expansion_cooldown / dynamic_bonus

	-- Adjust parameters
	if connected_players == 0 then
		enemy_evolution.time_factor = 0
	else
		enemy_evolution.time_factor = original_data.time_factor * dynamic_bonus
	end
	if enemy_expansion.settler_group_min_size < 1 then
		enemy_expansion.settler_group_min_size = 1
	end
	if enemy_expansion.settler_group_max_size < 1 then
		enemy_expansion.settler_group_max_size = 1
	end
end

local function check_map_settings(event)
	if not game.is_multiplayer() then return end

	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	-- Check data
	local original_data = storage.soft_evolution.original
	if not original_data then
		original_data = {}
		local map_settings = game.map_settings
		local enemy_expansion = map_settings.enemy_expansion
		original_data.time_factor = map_settings.enemy_evolution.time_factor
		original_data.settler_group_min_size = enemy_expansion.settler_group_min_size
		original_data.settler_group_max_size = enemy_expansion.settler_group_max_size
		original_data.max_expansion_distance = enemy_expansion.max_expansion_distance
		original_data.min_expansion_cooldown = enemy_expansion.min_expansion_cooldown
		original_data.max_expansion_cooldown = enemy_expansion.max_expansion_cooldown
		storage.soft_evolution.original = original_data
	end

	change_map_settings()
end

local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end

	if event.setting == "soft_evolution_from_research" then
		if settings.global[event.setting].value then
			script.on_event(defines.events.on_research_finished,    update_research_timer)
			script.on_event(defines.events.on_forces_merged,        update_research_timer)
			script.on_event(defines.events.on_player_changed_force, update_research_timer)
			script.on_event(defines.events.on_technology_effects_reset, balance_evolution_from_research)
		else
			script.on_event(defines.events.on_research_finished,        function() end)
			script.on_event(defines.events.on_forces_merged,            function() end)
			script.on_event(defines.events.on_player_changed_force,     function() end)
			script.on_event(defines.events.on_technology_effects_reset, function() end)
		end
	elseif event.setting == "soft_evolution_on_entity_died" then
		if settings.global[event.setting].value then
			script.on_event(defines.events.on_entity_died, on_entity_died)
		else
			script.on_event(defines.events.on_entity_died, function() end)
			reset_compensating_bonus()
		end
	end
end

M.on_load = function()
	if not game then
		if storage.soft_evolution == nil then
			M.on_init()
		end
	end
end

local function check_researches_on_nth_tick()
	local tick_of_update = storage.soft_evolution.tick_of_update
	if not tick_of_update then return end
	if game.tick < tick_of_update then return end

	balance_evolution_from_research()
end

M.events = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_technology_effects_reset] = balance_evolution_from_research,
	[defines.events.on_rocket_launched]      = reset_compensating_bonus,
	[defines.events.on_player_changed_force] = update_research_timer,
	[defines.events.on_research_finished]    = update_research_timer,
	[defines.events.on_forces_merged]        = update_research_timer,
	[defines.events.on_player_joined_game] = check_map_settings,
	[defines.events.on_player_left_game]   = check_map_settings,
	[defines.events.on_entity_died] = on_entity_died,
}

if not settings.global["soft_evolution_from_research"].value then
	M.events[defines.events.on_research_finished]        = function() end
	M.events[defines.events.on_forces_merged]            = function() end
	M.events[defines.events.on_player_changed_force]     = function() end
	M.events[defines.events.on_technology_effects_reset] = function() end
end
if not settings.global["soft_evolution_on_entity_died"].value then
	M.events[defines.events.on_entity_died] = function() end
end

M.remove_interface = function()
	remote.remove_interface("soft_evolution")
end

M.add_interface = function()
	remote.add_interface("soft_evolution",
	{
		get_event_name = function(name)
			return M.self_events[name]
		end,
		get_data = function()
			return storage.soft_evolution
		end,
		add_team = function(team)
			local list = storage.soft_evolution.teams
			table.insert(list, team)
		end,
		set_teams = function(teams)
			storage.soft_evolution.teams = teams
		end,
		remove_team = function(name)
			local teams = storage.soft_evolution.teams
			for k, team in pairs(teams) do
				if team.name == name then
					table.remove(teams, k)
					return k
				end
			end

			return 0 -- not found
		end,
		find_team = function(name)
			local teams = storage.soft_evolution.teams
			for k, team in pairs(teams) do
				if team.name == name then
					return k
				end
			end

			return 0 -- not found
		end,
		delete_teams = function()
			storage.soft_evolution.teams = nil
		end,
		balance_evolution_from_research = balance_evolution_from_research
	})
end

M.on_nth_tick = {
	[60 * 60] = check_researches_on_nth_tick
}

return M
