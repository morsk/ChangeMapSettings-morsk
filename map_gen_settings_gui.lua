local factorio_util = require("util")
local util = require("__EditMapSettings__/utilities")
local MOD_PREFIX = "edit-map-settings-"
local GUI_PREFIX = "map-gen-"
local ENTIRE_PREFIX = MOD_PREFIX .. GUI_PREFIX
local map_gen_gui = {}

map_gen_gui.create = function(parent)
  local frame1 = parent.add{
    type = "frame",
    direction = "vertical",
    style = "frame_in_deep_frame",
    name = ENTIRE_PREFIX .. "gui-frame-1"
  }
  local frame2 = parent.add{
    type = "frame",
    direction = "vertical",
    style = "frame_in_deep_frame",
    name = ENTIRE_PREFIX .. "gui-frame-2"
  }


  local resource_scroll_pane = frame1.add{
    type = "scroll-pane",
    name = ENTIRE_PREFIX .. "resource-scroll-pane",
    style ="scroll_pane_in_shallow_frame"
  }
  resource_scroll_pane.style.maximal_height = 300
  map_gen_gui.create_resource_table(resource_scroll_pane)
  map_gen_gui.create_enemies_table(frame1)


  map_gen_gui.create_expression_selectors(map_gen_gui.create_expression_selectors_parent(frame2))
  local terrain_scroll_pane = frame2.add{
    type = "scroll-pane",
    name = ENTIRE_PREFIX .. "terrain-scroll-pane",
    style ="scroll_pane_in_shallow_frame"
  }
  terrain_scroll_pane.style.maximal_height = 150
  map_gen_gui.create_controls_with_scale_table(terrain_scroll_pane)
  map_gen_gui.create_cliffs_table(frame2)
  map_gen_gui.create_climate_table(frame2)
end

map_gen_gui.create_expression_selectors_parent = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "expression-selectors-table",
    column_count = 1,
    style = "bordered_table"
  }
  table.style.horizontally_stretchable = true
  local flow = table.add{
    type = "flow",
    name = ENTIRE_PREFIX .. "expression-selectors-flow",
    direction = "vertical"
  }
  flow.style.horizontally_stretchable = true
  return flow
end

map_gen_gui.create_expression_selectors = function(parent)
  parent.add{
    type = "label",
    caption = {"gui-map-generator.terrain-generators-group-title"},
    style = "caption_label"
  }

  local noise_expressions = util.get_relevant_noise_expressions()
  for intended_property, expressions in pairs(noise_expressions) do
    map_gen_gui.make_expression_selector(intended_property, expressions, parent, false)
  end
end

map_gen_gui.make_expression_selector = function(intended_property, expressions, parent, force_creation)
  if table_size(expressions) == 1 and not force_creation then return end -- dont make dropdowns if there is only one option

  local flow = parent.add{
    type = "flow",
    name = ENTIRE_PREFIX .. intended_property .. "-flow",
    direction = "horizontal"
  }

  flow.add{
    type = "label",
    caption = {"" , {"noise-property." .. intended_property}, intended_property == "elevation" and {"", "/",  {"gui-map-generator.map-type"}} or ""}
  }
  local stretcher = flow.add{
    type = "flow",
    direction = "horizontal"
  }
  stretcher.style.horizontally_stretchable = true

  local dropdown_data = map_gen_gui.get_expression_dropdown_data(expressions)
  flow.add{
    type = "drop-down",
    name =  ENTIRE_PREFIX .. intended_property .. "-drop-down",
    items = dropdown_data.items,
    selected_index = dropdown_data.selected_index
  }

  return flow
end

map_gen_gui.get_expression_dropdown_data = function(expressions)
  local items = {}
  local lowest_order = expressions[1].order
  local selected_index = 1
  for i, expression in pairs(expressions) do
    items[#items+1] = {"noise-expression." .. expression.name}
    if expression.order < lowest_order then
      lowest_order = expression.order
      selected_index = i
    end
  end
  return {items = items, selected_index = selected_index}
end

map_gen_gui.create_resource_table = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "resource-table",
    column_count = 4,
    style = "bordered_table"
  }
  table.visible = true
  -- header
  table.add{type = "label"}
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.frequency"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.resource-frequency-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.size"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.resource-size-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.richness"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.resource-richness-description"}
  }

  -- resources
  for _, control in pairs(prototypes.autoplace_control) do
    if control.category == "resource" then
      map_gen_gui.make_autoplace_options(control.name, table, true, control)
    end
  end
end

map_gen_gui.create_controls_with_scale_table = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "controls-with-scale-table",
    column_count = 3,
    style = "bordered_table"
  }
  -- header
  table.add{type = "label"}
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.scale"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.terrain-scale-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.coverage"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.terrain-coverage-description"}
  }
  table.children[1].style.horizontally_stretchable = true

  -- trees and custom mod stuff
  for _, control in pairs(prototypes.autoplace_control) do
    if control.category == "terrain" and control.name ~= "planet-size" then -- planet size is a space exploration thing, we don't want the player to change it
      map_gen_gui.make_autoplace_options(control.name, table, false, control)
    end
  end
end

map_gen_gui.create_cliffs_table = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "cliffs-table",
    column_count = 3,
    style = "bordered_table"
  }
  -- header
  table.add{type = "label"}
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.cliff-frequency"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.cliff-frequency-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.cliff-continuity"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.cliff-continuity-description"}
  }
  table.children[1].style.horizontally_stretchable = true

  -- cliffs
  map_gen_gui.make_autoplace_options("cliffs", table, false)
end

map_gen_gui.create_climate_table = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "climate-table",
    column_count = 3,
    style = "bordered_table"
  }
  -- header
  table.add{type = "label"}
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.scale"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.terrain-scale-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.bias"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.terrain-bias-description"}
  }
  table.children[1].style.horizontally_stretchable = true

  map_gen_gui.make_autoplace_options("moisture", table, false)
  map_gen_gui.make_autoplace_options("aux", table, false)
end

map_gen_gui.create_enemies_table = function(parent)
  local table = parent.add{
    type = "table",
    name = ENTIRE_PREFIX .. "enemies-table",
    column_count = 3,
    style = "bordered_table"
  }
  -- header
  table.add{type = "label"}
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.frequency"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.enemy-frequency-description"}
  }
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.size"}),
    style = "caption_label",
    tooltip = {"gui-map-generator.enemy-size-description"}
  }
  table.children[1].style.horizontally_stretchable = true

  -- biter bases
  for _, control in pairs(prototypes.autoplace_control) do
    if control.category == "enemy" then
      map_gen_gui.make_autoplace_options(control.name, table, false, control)
    end
  end

  -- starting area size
  table.add{
    type = "label",
    caption = util.add_info_icon_to_string({"gui-map-generator.starting-area-size"}),
    tooltip = {"gui-map-generator.starting-area-size-description"}
  }
  table.add{type = "label"}
  table.add{
    type = "textfield",
    name = ENTIRE_PREFIX .. "starting-area-size",
    style = "short_number_textfield",
    numeric = true,
    allow_decimal = true,
    allow_negative = true
  }
end

-- autoplace is optional
-- if autoplace is provided, the localised name is taken from there
map_gen_gui.make_autoplace_options = function(name, parent, has_richness, autoplace)
  map_gen_gui.make_autoplace_label(name, parent, autoplace)
  parent.add{
    type = "textfield",
    name = ENTIRE_PREFIX .. name .. "-freq",
    style = "short_number_textfield",
    numeric = true,
    allow_decimal = true,
    allow_negative = true
  }
  parent.add{
    type = "textfield",
    name = ENTIRE_PREFIX .. name .. "-size",
    style = "short_number_textfield",
    numeric = true,
    allow_decimal = true,
    allow_negative = true
  }
  if has_richness then
    parent.add{
      type = "textfield",
      name = ENTIRE_PREFIX .. name .. "-richn",
      style = "short_number_textfield",
      numeric = true,
      allow_decimal = true,
      allow_negative = true
    }
  end
end

local autoplace_name_locale =
{
  ["aux"] = {"gui-map-generator.aux"},
  ["cliffs"] = {"autoplace-control-names.nauvis_cliff"},
  ["moisture"] = {"gui-map-generator.moisture"},
  ["water"] = {"", {"gui-map-generator.water"}, "/", {"gui-map-generator.island-size"}}
}

-- if autoplace is provided, the localised name is taken from there
map_gen_gui.make_autoplace_label = function(name, parent, autoplace)
  local label

  if autoplace then
    -- an autoplace has a flow with (checkbox, label)
    local flow = parent.add {
      type = "flow",
      name = ENTIRE_PREFIX .. name .. "-check-wrapper",
      direction = "horizontal"
    }
    flow.add {
      type = "checkbox",
      name = "check",
      state = true
    }
    label = flow.add{type = "label"}

    label.caption = autoplace.localised_name
    assert(label.caption ~= "nil")
    return
  end

  -- other things just have a label
  label = parent.add{type = "label"}
  label.caption = autoplace_name_locale[name]
  if name == "moisture" or name == "aux" then
    label.tooltip = {"gui-map-generator." .. name .. "-description"}
    label.caption = util.add_info_icon_to_string(label.caption)
  end
  assert(label.caption ~= "nil")
end

map_gen_gui.reset_to_defaults = function(parent)
  local expression_selectors_flow = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "expression-selectors-table"][ENTIRE_PREFIX .. "expression-selectors-flow"]
  local resource_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .. "resource-scroll-pane"][ENTIRE_PREFIX .."resource-table"]
  local controls_with_scale_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "terrain-scroll-pane"][ENTIRE_PREFIX .."controls-with-scale-table"]
  local enemies_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .."enemies-table"]
  local climate_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."climate-table"]
  local cliffs_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."cliffs-table"]

  -- expression selectors
  -- Making these defaults work with existing GUI that may or may not have more or less dropdowns than the default sounds like a nightmare.
  --   So let's just recreate it.
  expression_selectors_flow.clear()
  map_gen_gui.create_expression_selectors(expression_selectors_flow)


  -- starting area
  enemies_table[ENTIRE_PREFIX .. "starting-area-size"].text = "1"

  -- resources and terrain and enemies
  local autoplace_control_prototypes = prototypes.autoplace_control
  for name, control in pairs(autoplace_control_prototypes) do
    local check_wrapper_name = ENTIRE_PREFIX .. name .. "-check-wrapper"
    if control.category == "resource" then
      if resource_table[check_wrapper_name] and not resource_table[check_wrapper_name].check.state then
        resource_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        resource_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
        resource_table[ENTIRE_PREFIX .. name .. "-richn"].text = ""
      else
        resource_table[ENTIRE_PREFIX .. name .. "-freq"].text = "1"
        resource_table[ENTIRE_PREFIX .. name .. "-size"].text = "1"
        resource_table[ENTIRE_PREFIX .. name .. "-richn"].text = "1"
      end
    elseif control.category == "terrain" and name ~= "planet-size" then -- planet size is a space exploration thing, we don't want the player to change it
      if controls_with_scale_table[check_wrapper_name] and not controls_with_scale_table[check_wrapper_name].check.state then
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
      else
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-freq"].text = "1"
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-size"].text = "1"
      end
    elseif control.category == "enemy" then
      if enemies_table[check_wrapper_name] and not enemies_table[check_wrapper_name].check.state then
        enemies_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        enemies_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
      else
        enemies_table[ENTIRE_PREFIX .. name .. "-freq"].text = "1"
        enemies_table[ENTIRE_PREFIX .. name .. "-size"].text = "1"
      end
    end
  end

  -- moisture and terrain type
  climate_table[ENTIRE_PREFIX .. "moisture-freq"].text = "1"
  climate_table[ENTIRE_PREFIX .. "moisture-size"].text = "0"
  climate_table[ENTIRE_PREFIX .. "aux-freq"].text = "1"
  climate_table[ENTIRE_PREFIX .. "aux-size"].text = "0"

  -- cliffs
  cliffs_table[ENTIRE_PREFIX .. "cliffs-freq"].text = "1"
  cliffs_table[ENTIRE_PREFIX .. "cliffs-size"].text = "1"
end

map_gen_gui.set_to_current = function(parent, map_gen_settings, reset_checkboxes)
  local expression_selectors_flow = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "expression-selectors-table"][ENTIRE_PREFIX .. "expression-selectors-flow"]
  local resource_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .. "resource-scroll-pane"][ENTIRE_PREFIX .."resource-table"]
  local controls_with_scale_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "terrain-scroll-pane"][ENTIRE_PREFIX .."controls-with-scale-table"]
  local enemies_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .."enemies-table"]
  local climate_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."climate-table"]
  local cliffs_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."cliffs-table"]
  local property_expression_names = map_gen_settings.property_expression_names
  local autoplace_controls = map_gen_settings.autoplace_controls
  local cliff_settings = map_gen_settings.cliff_settings

  -- expression selectors
  -- The default selected expression is omitted from property_expression_names.
  --   So to make sure we're at current, reset to default first and then apply the changes from property_expression_names.
  expression_selectors_flow.clear()
  map_gen_gui.create_expression_selectors(expression_selectors_flow)

  if property_expression_names then -- can be missing when reading from preset
    local possible_properties = util.get_possible_noise_expression_properties()
    local relevant_noise_expressions = util.get_relevant_noise_expressions()
    local valid_named_noise_expressions = prototypes.named_noise_expression
    for property in pairs(possible_properties) do
      local selected_expression = property_expression_names[property]
      if selected_expression then
        local noise_expressions_list_item
        if valid_named_noise_expressions[selected_expression] then -- proper noise expression, not just some number
          noise_expressions_list_item = {"noise-expression." .. selected_expression}
        else
          noise_expressions_list_item = selected_expression -- number that is really a string. we just use it directly
        end
        local property_flow = expression_selectors_flow[ENTIRE_PREFIX .. property .. "-flow"]
        if not property_flow then
          property_flow = map_gen_gui.make_expression_selector(property, relevant_noise_expressions[property], expression_selectors_flow, true)
        end
        local dropdown = property_flow[ENTIRE_PREFIX .. property .. "-drop-down"]
        map_gen_gui.select_in_dropdown_or_add_and_select(noise_expressions_list_item, dropdown) -- select (optionally add) the item
      end
    end
  end

  -- starting area
  enemies_table[ENTIRE_PREFIX .. "starting-area-size"].text = util.number_to_string(util.map_gen_size_to_number(map_gen_settings.starting_area) or 1)

  -- resources and terrain and enemies
  local valid_autoplace_controls = prototypes.autoplace_control
  for name, control_prototype in pairs(valid_autoplace_controls) do
    -- find checkbox
    local checkbox
    if control_prototype.category == "resource" then
      checkbox = resource_table[ENTIRE_PREFIX .. name .. "-check-wrapper"].check
    elseif control_prototype.category == "terrain" then
      checkbox = controls_with_scale_table[ENTIRE_PREFIX .. name .. "-check-wrapper"].check
    elseif control_prototype.category == "enemy" then
      checkbox = enemies_table[ENTIRE_PREFIX .. name .. "-check-wrapper"].check
    end
    -- reset checkbox to match data, if we were told to
    if reset_checkboxes and checkbox then
      if (
        autoplace_controls and
        autoplace_controls[name] and
        autoplace_controls[name].size and
        util.map_gen_size_to_number(autoplace_controls[name].size) > 0
      ) then
        checkbox.state = true
      else
        checkbox.state = false
      end
    end
    -- defaults to 1,1,1
    local autoplace_control = autoplace_controls and autoplace_controls[name] or {frequency=1, size=1, richness=1}
    if control_prototype.category == "resource" then
      if checkbox.state then
        resource_table[ENTIRE_PREFIX .. name .. "-freq"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["frequency"]) or 1)
        resource_table[ENTIRE_PREFIX .. name .. "-size"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["size"]) or 1)
        resource_table[ENTIRE_PREFIX .. name .. "-richn"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["richness"]) or 1)
      else
        resource_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        resource_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
        resource_table[ENTIRE_PREFIX .. name .. "-richn"].text = ""
      end
    elseif control_prototype.category == "terrain" and name ~= "planet-size" then -- planet size is a space exploration thing, we don't want the player to change it
      if checkbox.state then
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-freq"].text = util.number_to_string(1 / (util.map_gen_size_to_number(autoplace_control["frequency"]) or 1)) -- inverse
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-size"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["size"]) or 1)
      else
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        controls_with_scale_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
      end
    elseif control_prototype.category == "enemy" then
      if checkbox.state then
        enemies_table[ENTIRE_PREFIX .. name .. "-freq"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["frequency"]) or 1)
        enemies_table[ENTIRE_PREFIX .. name .. "-size"].text = util.number_to_string(util.map_gen_size_to_number(autoplace_control["size"]) or 1)
      else
        enemies_table[ENTIRE_PREFIX .. name .. "-freq"].text = ""
        enemies_table[ENTIRE_PREFIX .. name .. "-size"].text = ""
      end
    end
  end

  -- moisture and terrain type
  if property_expression_names then -- can be missing when reading from preset
    -- All 4 values are stored as text. The "bias" we can use as-is, while defaulting to 0.
    climate_table[ENTIRE_PREFIX .. "moisture-size"].text = property_expression_names["control:moisture:bias"] or util.number_to_string(0)
    climate_table[ENTIRE_PREFIX .. "aux-size"].text = property_expression_names["control:aux:bias"] or util.number_to_string(0)
    -- The "frequency" we have to invert, which means converting to and from a number.
    local function invert_number_as_text(t)
      local n = tonumber(t)
      return util.number_to_string(1 / n)
    end
    climate_table[ENTIRE_PREFIX .. "moisture-freq"].text = invert_number_as_text(property_expression_names["control:moisture:frequency"] or util.number_to_string(1))
    climate_table[ENTIRE_PREFIX .. "aux-freq"].text = invert_number_as_text(property_expression_names["control:aux:frequency"] or util.number_to_string(1))
  end

  -- cliffs
  if cliff_settings then -- can be missing when reading from preset
    local cliff_control = cliff_settings.control
    if cliff_control and #cliff_control > 0 then
      -- cliff_control is something like "nauvis_cliff"
      -- cliff_autoplace is autoplace_controls["nauvis_cliff"]
      local cliff_autoplace = cliff_control and autoplace_controls and autoplace_controls[cliff_control]
      if cliff_autoplace then
        cliffs_table[ENTIRE_PREFIX .. "cliffs-freq"].text = util.number_to_string(cliff_autoplace.frequency)
        cliffs_table[ENTIRE_PREFIX .. "cliffs-size"].text = util.number_to_string(cliff_autoplace.size)
      end
    else
      -- without a .control, we do it the old way, changing cliff_settings without an autoplace
      cliffs_table[ENTIRE_PREFIX .. "cliffs-freq"].text = util.number_to_string(40 / (cliff_settings.cliff_elevation_interval or 40)) -- inverse with 40
      cliffs_table[ENTIRE_PREFIX .. "cliffs-size"].text = util.number_to_string(util.map_gen_size_to_number(cliff_settings.richness) or 1)
    end
  end
end

map_gen_gui.select_in_dropdown_or_add_and_select = function(item_to_select, dropdown)
  local items = dropdown.items
  for index, item in pairs(items) do
    if util.compare_localized_strings(item_to_select, item) then
      dropdown.selected_index = index
      return -- found in dropdown
    end
  end

  local index = #items+1
  dropdown.add_item(item_to_select, index) -- add to dropdown
  dropdown.selected_index = index
end

-- returns map_gen_settings, can throw!
-- param current_map_gen_settings only used for space exploration "planet-size" !!!
map_gen_gui.read = function(parent, planet, current_map_gen_settings)
  local expression_selectors_flow = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "expression-selectors-table"][ENTIRE_PREFIX .. "expression-selectors-flow"]
  local resource_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .. "resource-scroll-pane"][ENTIRE_PREFIX .."resource-table"]
  local controls_with_scale_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .. "terrain-scroll-pane"][ENTIRE_PREFIX .."controls-with-scale-table"]
  local enemies_table = parent[ENTIRE_PREFIX .. "gui-frame-1"][ENTIRE_PREFIX .."enemies-table"]
  local climate_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."climate-table"]
  local cliffs_table = parent[ENTIRE_PREFIX .. "gui-frame-2"][ENTIRE_PREFIX .."cliffs-table"]
  local map_gen_settings = {}
  local property_expression_names_mine = {}
  local autoplace_controls_mine = {}
  local cliff_settings_mine = {}
  local territory_settings_mine = {}

  -- Moisture and terrain type aren't in these settings anymore. Just copy the planet.
  if planet then
    property_expression_names_mine = factorio_util.table.deepcopy(planet.prototype.map_gen_settings.property_expression_names)
    territory_settings_mine = factorio_util.table.deepcopy(planet.prototype.map_gen_settings.territory_settings)
  end

  -- Nauvis is the only planet that uses the moisture and terrain settings.
  -- If someone tries the setting on a non-planet surface, let them try and see what happens.
  if (not planet) or planet.name == "nauvis" then
    local moisture_bias = util.textfield_to_number_with_error(climate_table[ENTIRE_PREFIX .. "moisture-size"])
    property_expression_names_mine["control:moisture:bias"] = util.number_to_string(moisture_bias)
    local aux_bias = util.textfield_to_number_with_error(climate_table[ENTIRE_PREFIX .. "aux-size"])
    property_expression_names_mine["control:aux:bias"] = util.number_to_string(aux_bias)
    local moisture_freq = 1 / util.textfield_to_number_with_error(climate_table[ENTIRE_PREFIX .. "moisture-freq"]) -- inverse
    property_expression_names_mine["control:moisture:frequency"] = util.number_to_string(moisture_freq)
    local aux_freq = 1 / util.textfield_to_number_with_error(climate_table[ENTIRE_PREFIX .. "aux-freq"]) -- inverse
    property_expression_names_mine["control:aux:frequency"] = util.number_to_string(aux_freq)
  end

  -- expression selectors
  local possible_properties = util.get_possible_noise_expression_properties()
  for property in pairs(possible_properties) do
    local property_flow = expression_selectors_flow[ENTIRE_PREFIX .. property .. "-flow"]
    if property_flow then
      local dropdown = property_flow[ENTIRE_PREFIX .. property .. "-drop-down"]
      local selected_noise_expressions_list_item = dropdown.items[dropdown.selected_index]
      -- above is a localized string in form of {"noise-expression." .. selected_expression} or selected_expression
      -- parse it to get selected_expression
      local selected_expression
      if type(selected_noise_expressions_list_item) == "string" then -- selected_expression
        selected_expression = selected_noise_expressions_list_item
      else -- {"noise-expression." .. selected_expression}
        selected_expression = selected_noise_expressions_list_item[1]:sub(string.len("noise-expression.") + 1)
      end
      property_expression_names_mine[property] = selected_expression
    end
  end

  -- starting area
  map_gen_settings.starting_area = util.textfield_to_number_with_error(enemies_table[ENTIRE_PREFIX .. "starting-area-size"])

  local autoplace_control_prototypes = prototypes.autoplace_control
  -- resources and terrain and enemies
  for _, control in pairs(autoplace_control_prototypes) do
    local check_wrapper_name = ENTIRE_PREFIX .. control.name .. "-check-wrapper"
    if control.category == "resource" then
      if resource_table[check_wrapper_name] and not resource_table[check_wrapper_name].check.state then
        goto continue
      end
      autoplace_controls_mine[control.name] = {
        frequency = util.textfield_to_number_with_error(resource_table[ENTIRE_PREFIX .. control.name .. "-freq"]),
        size = util.textfield_to_number_with_error(resource_table[ENTIRE_PREFIX .. control.name .. "-size"]),
        richness = util.textfield_to_number_with_error(resource_table[ENTIRE_PREFIX .. control.name .. "-richn"])
      }
    elseif control.category == "terrain" and control.name ~= "planet-size" then -- planet size is a space exploration thing, we don't want the player to change it
      if controls_with_scale_table[check_wrapper_name] and not controls_with_scale_table[check_wrapper_name].check.state then
        goto continue
      end
      autoplace_controls_mine[control.name] = {
        frequency = 1 / util.textfield_to_number_with_error(controls_with_scale_table[ENTIRE_PREFIX .. control.name .. "-freq"]), -- inverse
        size = util.textfield_to_number_with_error(controls_with_scale_table[ENTIRE_PREFIX .. control.name .. "-size"])
      }
    elseif control.category == "enemy" then
      if enemies_table[check_wrapper_name] and not enemies_table[check_wrapper_name].check.state then
        goto continue
      end
      autoplace_controls_mine[control.name] = {
        frequency = util.textfield_to_number_with_error(enemies_table[ENTIRE_PREFIX .. control.name .. "-freq"]),
        size = util.textfield_to_number_with_error(enemies_table[ENTIRE_PREFIX .. control.name .. "-size"])
      }
    end
    ::continue::
  end

  -- but space explorations planet size still needs to be set!
  if current_map_gen_settings.autoplace_controls and current_map_gen_settings.autoplace_controls["planet-size"] then
    autoplace_controls_mine["planet-size"] = current_map_gen_settings.autoplace_controls["planet-size"]
  end

  -- cliffs
  if planet then
    -- Default to planet's cliff_settings if we have one.
    -- Or else we'll zero out important things!
    -- Should refactor not to have to pass the planet as an argument, but whatever.
    -- First there needs to be a data model somewhere, not just GUI boxes.
    -- Or an algorithm to modify map_gen_data piece-by-piece, not overwrite from scratch.
    -- (Or there's something I'm not using and can find.)
    cliff_settings_mine = factorio_util.table.deepcopy(planet.prototype.map_gen_settings.cliff_settings)
  else
    cliff_settings_mine.name = "cliff"
  end
  -- In 2.0, cliffs are configured with their autoplace_control.
  -- map_gen_settings.cliff_settings still exists but isn't what the game's sliders change.
  local cliff_autoplace_name = cliff_settings_mine.control
  if cliff_autoplace_name and #cliff_autoplace_name > 0 then
    autoplace_controls_mine[cliff_autoplace_name] = autoplace_controls_mine[cliff_autoplace_name] or {frequency = 1, richness = 1, size = 1}
    autoplace_controls_mine[cliff_autoplace_name].frequency = util.textfield_to_number_with_error(cliffs_table[ENTIRE_PREFIX .. "cliffs-freq"])
    autoplace_controls_mine[cliff_autoplace_name].size = util.textfield_to_number_with_error(cliffs_table[ENTIRE_PREFIX .. "cliffs-size"])
  else
    -- Trying to set cliff settings on a surface where .control is "".
    -- Let them do it the 1.1 way, directly changing cliff_settings.
    -- This has an old bug where -freq can divide by 0. I haven't fixed it.
    cliff_settings_mine.cliff_elevation_interval = 40 / util.textfield_to_number_with_error(cliffs_table[ENTIRE_PREFIX .. "cliffs-freq"]) -- inverse with 40
    cliff_settings_mine.richness = util.textfield_to_number_with_error(cliffs_table[ENTIRE_PREFIX .. "cliffs-size"])
  end

  map_gen_settings.autoplace_controls = autoplace_controls_mine
  map_gen_settings.property_expression_names = property_expression_names_mine
  map_gen_settings.cliff_settings = cliff_settings_mine
  map_gen_settings.territory_settings = territory_settings_mine
  return map_gen_settings
end

return map_gen_gui
