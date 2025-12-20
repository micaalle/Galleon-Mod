for i = 1, 7 do
  local tech = data.raw.technology["stronger-explosives-" .. i]
  if tech then
    table.insert(tech.effects, {
      type = "ammo-damage",
      ammo_category = "pirate-cannon",
      modifier = 0.1 * i
    })
  end
end