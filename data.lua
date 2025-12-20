
local pirate_ship = table.deepcopy(data.raw["car"]["car"])

pirate_ship.name = "pirateship"
pirate_ship.icon = "__pirateship__/Graphics/pirateship.png"
pirate_ship.icon_size = 1000
pirate_ship.collision_mask = { layers = { ground_tile = true, train = true, car = true, is_object = true } }

pirate_ship.collision_box = {{-1.2, -2.2}, {1.2, 4.2}}
pirate_ship.selection_box = {{-1.2, -0.2}, {1.2, 6.2}}
pirate_ship.localised_description = {"entity-description.pirateship"}
pirate_ship.selection_priority = 60
pirate_ship.max_health = 3000
pirate_ship.weight = 1000
pirate_ship.braking_power = "200kW"
pirate_ship.friction = 0.002
pirate_ship.terrain_friction_modifier = 0.2
pirate_ship.minable = { mining_time = 1, result = "pirateship" }
pirate_ship.rotation_speed = 0.010
pirate_ship.inventory_size = 80
pirate_ship.energy_source = { type = "void" }
pirate_ship.guns = { "pirateship-cannon-gun" }

pirate_ship.working_sound = {
  sound = {
    filename = "__pirateship__/Sound/ship-sailing.ogg",
    volume = 0.7,
    min_speed = 0.6,
    max_speed = 0.9,
  },
  activate_sound = {
    filename = "__pirateship__/Sound/ship-start.ogg",
    volume = 1,
    speed = 0.6,
  },
  deactivate_sound = {
    filename = "__pirateship__/Sound/ship-start.ogg",
    volume = 1,
    speed = 0.6,
  },
  match_speed_to_activity = true
}

pirate_ship.stop_trigger = {
  {
    type = "play-sound",
    sound = {filename = "__pirateship__/Sound/ship-start.ogg", volume = .5}
  }
}

pirate_ship.animation = {
  layers = {
    {
      priority = "low",
      direction_count = 128,
      width = 1002,
      height = 1002,
      stripes = {
        {
          filename = "__pirateship__/Graphics/newRend_0.png",
          width_in_frames = 8,
          height_in_frames = 8
        },
        {
          filename = "__pirateship__/Graphics/newRend_1.png",
          width_in_frames = 8,
          height_in_frames = 8
        }
      },
      shift = util.by_pixel(0, 0),
      scale = 1,
      max_advance = 0.2
    }
  }
}

pirate_ship.turret_animation = nil
pirate_ship.light_animation = nil
pirate_ship.corpse = nil

local pirate_ammo_category = {
  type = "ammo-category",
  name = "pirate-cannon"
}

local pirate_smoke = {
  type = "smoke-with-trigger",
  name = "pirate-cannon-smoke",
  flags = {"not-on-map"},
  show_when_smoke_off = true,
  animation = {
    filename = "__base__/graphics/entity/smoke/smoke.png",
    priority = "high",
    width = 152,
    height = 120,
    frame_count = 60,
    line_length = 5,
    animation_speed = 0.25,
    scale = 2.0,
    shift = {0, 0}
  },
  slow_down_factor = 0,
  affected_by_wind = true,
  cyclic = false,
  duration = 90,
  fade_away_duration = 60,
  spread_duration = 15,
  start_scale = 1.0,
  end_scale = 3.0,
  color = {r = 0.05, g = 0.05, b = 0.05, a = 0.8}
}


local pirate_trail_smoke = {
  type = "trivial-smoke",
  name = "pirate-cannon-trail",
  duration = 45,
  fade_away_duration = 30,
  spread_duration = 5,
  start_scale = 0.2,
  end_scale = 0.5,
  color = {r = 0.2, g = 0.2, b = 0.2, a = 0.5},
  affected_by_wind = true,
  animation = {
    filename = "__base__/graphics/entity/smoke/smoke.png",
    width = 152,
    height = 120,
    frame_count = 60,
    line_length = 5,
    animation_speed = 0.25,
    scale = 0.5  
  }
}



local cannonball_projectile = {
  type = "projectile",
  name = "pirateship-cannonball-projectile",
  flags = {"not-on-map"},
  acceleration = 0.015,
  animation = {
    filename = "__pirateship__/Graphics/cannonball.png",
    frame_count = 1,
    width = 500,
    height = 500,
    priority = "high",
    blend_mode = "normal",
    scale = 0.10
  },
  light = {intensity = 0.5, size = 10},

  smoke = {
    {
      name = "pirate-cannon-trail",
      deviation = {0.1, 0.1},
      frequency = 1,
      position = {0, 0},
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  },

  action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "damage",
          damage = {amount = 750, type = "physical"}
        },
        {
          type = "create-entity",
          entity_name = "pirate-cannon-smoke"
        }
      }
    }
  },

  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-entity",
          entity_name = "big-explosion"
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 6,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = {amount = 250, type = "explosion"}
                }
              }
            }
          }
        },
        {
          type = "create-entity",
          entity_name = "explosion-hit"
        }
      }
    }
  }
}


local cannonball_ammo = {
  type = "ammo",
  name = "pirateship-cannonball",
  icon = "__pirateship__/Graphics/cannonball1.png",
  icon_size = 199,
  ammo_category = "pirate-cannon",
  magazine_size = 5,
  subgroup = "ammo",
  order = "d[rocket]-z[pirate-cannonball]",
  stack_size = 10,
  ammo_type = {
    category = "pirate-cannon",
    target_type = "direction",
    action = {
      type = "direct",
      action_delivery = {
        type = "projectile",
        projectile = "pirateship-cannonball-projectile",
        starting_speed = 0.4,
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 75,

        source_effects = {
          {
            type = "create-entity",
            entity_name = "pirate-cannon-smoke"
          },
          {
            type = "create-entity",
            entity_name = "explosion-gunshot"
          }
        }
      }
    }
  }
}


local cannonball_recipe = {
  type = "recipe",
  name = "pirateship-cannonball",
  enabled = false,
  energy_required = 5,
  ingredients = {
    {type = "item", name = "iron-plate", amount = 25}
  },
  results = {
    {type = "item", name = "pirateship-cannonball", amount = 1}
  }
}


local pirate_cannon_gun = {
  type = "gun",
  name = "pirateship-cannon-gun",
  icon = "__pirateship__/Graphics/cannonball1.png",
  icon_size = 199,
  subgroup = "gun",
  order = "a[basic-clips]-z[pirate-cannon]",
  attack_parameters = {
    type = "projectile",
    ammo_category = "pirate-cannon",
    cooldown = 60,
    movement_slow_down_factor = 0,
    projectile_creation_distance = 3.0,
    projectile_center = {0, 0},
    range = 150,
    sound = {
      {
        filename = "__pirateship__/Sound/cannonSound.ogg",
        volume = 1.5
      }
    }
  },
  stack_size = 1
}

local pirate_ship_item = {
  type = "item-with-entity-data",
  name = "pirateship",
  icon = "__pirateship__/Graphics/pirateship.png",
  icon_size = 1000,
  subgroup = "transport",
  order = "a[water-system]-f[pirateship]",
  place_result = "pirateship",
  stack_size = 5
}

local pirate_ship_recipe = {
  type = "recipe",
  name = "pirateship",
  enabled = false,
  energy_required = 3,
  ingredients = {
    {type = "item", name = "wood", amount = 120}
  },
  results = {
    {type = "item", name = "pirateship", amount = 1}
  }
}


local pirate_ship_technology = {
  type = "technology",
  name = "Pirate_Ship",
  icon = "__pirateship__/Graphics/pirateship.png",
  icon_size = 1000,
  prerequisites = {"logistic-science-pack"},
  effects = {
    {type = "unlock-recipe", recipe = "pirateship"},
    {type = "unlock-recipe", recipe = "pirateship-cannonball"}
  },
  unit = {
    count = 100,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  }
}


local pirate_ship_input = {
  type = "custom-input",
  name = "enter-pirate-ship",
  key_sequence = "SHIFT + ENTER",
  consuming = "game-only"
}


data:extend{
  pirate_ship,
  pirate_ammo_category,
  pirate_ship_item,
  pirate_ship_recipe,
  pirate_ship_technology,
  pirate_ship_input,
  cannonball_projectile,
  cannonball_ammo,
  pirate_cannon_gun,
  cannonball_recipe,
  pirate_smoke,
  pirate_trail_smoke
}
