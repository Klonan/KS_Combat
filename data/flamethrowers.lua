-- Shoot more self contained particles, with spread, only create fire entity
-- Area trigger item for position, randomized

local old_turret = {
  prepare_range = 35,
  shoot_in_prepare_state = false,
  attack_parameters =
  {
    type = "stream",
    cooldown = 4,
    range = 30,
    min_range = 6,

    turn_range = 1.0 / 3.0,
    fire_penalty = 15,

    -- lead_target_for_projectile_speed = 0.2* 0.75 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream

    fluids =
    {
      {type = "crude-oil"},
      {type = "heavy-oil", damage_modifier = 1.05},
      {type = "light-oil", damage_modifier = 1.1}
    },
    fluid_consumption = 0.2,

    gun_center_shift =
    {
      north = math3d.vector2.add(fireutil.gun_center_base, fireutil.turret_gun_shift.north),
      east = math3d.vector2.add(fireutil.gun_center_base, fireutil.turret_gun_shift.east),
      south = math3d.vector2.add(fireutil.gun_center_base, fireutil.turret_gun_shift.south),
      west = math3d.vector2.add(fireutil.gun_center_base, fireutil.turret_gun_shift.west)
    },
    gun_barrel_length = 0.4,

    ammo_type =
    {
      category = "flamethrower",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "stream",
          stream = "flamethrower-fire-stream",
          source_offset = {0.15, -0.5}
        }
      }
    },
  }
}

local old_stream =
{
  {
    type = "stream",
    name = "flamethrower-fire-stream",
    flags = {"not-on-map"},
    stream_light = {intensity = 1, size = 4},
    ground_light = {intensity = 0.8, size = 4},

    smoke_sources =
    {
      {
        name = "soft-fire-smoke",
        frequency = 0.05, --0.25,
        position = {0.0, 0}, -- -0.8},
        starting_frame_deviation = 60
      }
    },
    particle_buffer_size = 90,
    particle_spawn_interval = 2,
    particle_spawn_timeout = 8,
    particle_vertical_acceleration = 0.005 * 0.60,
    particle_horizontal_speed = 0.2* 0.75 * 1.5,
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_start_scale = 0.2,
    particle_loop_frame_count = 3,
    particle_fade_out_threshold = 0.9,
    particle_loop_exit_threshold = 0.25,
    action =
    {
      {
        type = "area",
        radius = 2.5,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = "fire-sticker"
            },
            {
              type = "damage",
              damage = { amount = 3, type = "fire" },
              apply_damage_to_trees = false
            }
          }
        }
      },
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-fire",
              entity_name = "fire-flame",
              show_in_tooltip = true
            }
          }
        }
      }
    },

    spine_animation =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-fire-stream-spine.png",
      blend_mode = "additive",
      --tint = {r=1, g=1, b=1, a=0.5},
      line_length = 4,
      width = 1,
      height = 1,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      animation_speed = 2,
      shift = {0, 0}
    },

    shadow =
    {
      filename = "__base__/graphics/entity/acid-projectile/projectile-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },

    particle =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      frame_count = 32,
      line_length = 8
    }
  }
}


local new_action =
{
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-fire",
          entity_name = "fire-flame",
          show_in_tooltip = true
        }
      }
    }
  }
}

data.raw.stream["handheld-flamethrower-fire-stream"].action = new_action
data.raw.stream["handheld-flamethrower-fire-stream"].spine_animation =
{
  filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-fire-stream-spine.png",
  blend_mode = "additive",
  --tint = {r=1, g=1, b=1, a=0.5},
  line_length = 4,
  width = 1,
  height = 1,
  frame_count = 1,
  axially_symmetrical = false,
  direction_count = 1,
  animation_speed = 2,
  shift = {0, 0}
}