-- bst, might seem like overkill but I like them
local bstStorage = {
  root = nil
}

-- basic bst functions
local function bst_new_node(key, value)
  return { key = key, value = value, left = nil, right = nil }
end

local function bst_insert(node, key, value)
  if not node then
    return bst_new_node(key, value)
  end
  if key < node.key then
    node.left = bst_insert(node.left, key, value)
  elseif key > node.key then
    node.right = bst_insert(node.right, key, value)
  else
    node.value = value 
  end
  return node
end

--[[
local function bst_find(node, key)
  if not node then return nil end
  if key < node.key then
    return bst_find(node.left, key)
  elseif key > node.key then
    return bst_find(node.right, key)
  else
    return node
  end
end
]]--

local function bst_find_min(node)
  while node.left do
    node = node.left
  end
  return node
end

local function bst_delete(node, key)
  if not node then return nil end
  if key < node.key then
    node.left = bst_delete(node.left, key)
  elseif key > node.key then
    node.right = bst_delete(node.right, key)
  else
    if not node.left then
      return node.right
    elseif not node.right then
      return node.left
    else

      local minNode = bst_find_min(node.right)
      node.key = minNode.key
      node.value = minNode.value
      node.right = bst_delete(node.right, minNode.key)
    end
  end
  return node
end

local function bst_set_vehicle_for_character(character, vehicle)
  bstStorage.root = bst_insert(bstStorage.root, character.unit_number, vehicle)
end

--[[
local function bst_get_vehicle_for_character(character)
  local node = bst_find(bstStorage.root, character.unit_number)
  if node then return node.value end
  return nil
end
]]--

local function bst_remove_character(character)
  bstStorage.root = bst_delete(bstStorage.root, character.unit_number)
end

-- check for my pirate ship
local function is_nautical(entity)
  return entity and entity.valid and string.find(entity.name, "ship", 1, true)
end

-- debug
local function inform(player, text)
  if player and player.valid then
    player.print(text)
  end
end

-- force player out of the ship
local function evict_character(vehicle, character)
  if vehicle.get_driver() == character then
    vehicle.set_driver(nil)
    return true
  elseif vehicle.get_passenger() == character then
    vehicle.set_passenger(nil)
    return true
  end
  return false
end

-- enter the ship with the bst tracking character assignment
local function board_character(vehicle, character)
  if not vehicle.get_driver() then
    vehicle.set_driver(character)
    bst_set_vehicle_for_character(character, vehicle)
    return true
  elseif vehicle.type == "car" and not vehicle.get_passenger() then
    vehicle.set_passenger(character)
    bst_set_vehicle_for_character(character, vehicle)
    return true
  end
  return false
end

-- finds a nearby area of land to teleport the player to
local function disembark_sequence(player, driver, vessel, fallback_surface)
  if not driver or not vessel then return end

  evict_character(vessel, driver)
  bst_remove_character(driver)

  local position = vessel.position
  local found_spot = nil
  for i = 1, 200 do
    local offset = {
      x = position.x + (math.random() - 0.5) * 20,
      y = position.y + (math.random() - 0.5) * 20
    }
    local free = fallback_surface.find_non_colliding_position("character", offset, 1, 0.2)
    if free then
      found_spot = free
      break
    end
  end

  if found_spot then
    driver.teleport(found_spot)
  else
    inform(player, "No viable terrain for docking!")
    -- keeps player from just dying
    board_character(vessel, driver)
  end
end

-- attempt to board a nearby galleon
local function board_vehicle(player, transport)
  local char = player.character
  if not char or not transport then return end

  if not board_character(transport, char) then
    inform(player, "Occupied vessel.")
  end
end

-- finds the closest vechine that is nearby
local function locate_closest(entity, types, area)
  local results = entity.surface.find_entities_filtered{
    area = area,
    type = types
  }

  local closest, shortest = nil, math.huge
  for _, item in ipairs(results) do
    local dx = item.position.x - entity.position.x
    local dy = item.position.y - entity.position.y
    local dist = dx * dx + dy * dy
    if dist < shortest then
      shortest = dist
      closest = item
    end
  end

  return closest
end


script.on_event("enter-pirate-ship", function(ev)
  local p = game.get_player(ev.player_index)
  if not p or not p.valid or not p.character then return end

  local char = p.character
  local current = char.vehicle
  local surf = p.surface
  local pos = p.position
  local region = {{pos.x - 12, pos.y - 12}, {pos.x + 12, pos.y + 12}}

  -- exit condition
  if current and is_nautical(current) then
    disembark_sequence(p, char, current, surf)
    return
  end

  -- finds the nearest ship
  local float_unit = surf.find_entities_filtered{area = region, name = "pirateship"}[1]

  if float_unit and not current then
    p.teleport(float_unit.position)
    board_vehicle(p, float_unit)
    return
  end

  if current then
    evict_character(current, char)
    bst_remove_character(char)
    local out = surf.find_non_colliding_position("character", pos, 6, 0.3)
    if out then p.teleport(out) end
    return
  end

  -- fallback for when the ship cannot be entered
  local other = locate_closest(p, {"car", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "spider-vehicle"}, region)
  if other and not is_nautical(other) then
    board_vehicle(p, other)
  end
end)
