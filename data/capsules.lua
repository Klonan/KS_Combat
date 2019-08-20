--Make capsules/grenades throw in an arc!

local old_posion =
{
  type = "capsule",
  name = "poison-capsule",
  icon = "__base__/graphics/icons/poison-capsule.png",
  icon_size = 32,
  capsule_action =
  {
    type = "throw",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "capsule",
      cooldown = 30,
      projectile_creation_distance = 0.6,
      range = 25,
      ammo_type =
      {
        category = "capsule",
        target_type = "position",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "projectile",
            projectile = "poison-capsule",
            starting_speed = 0.3
          }
        }
      }
    }
  },
  subgroup = "capsule",
  order = "b[poison-capsule]",
  stack_size = 100
}

local fire_stream ={
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
    width = 32,
    height = 18,
    frame_count = 32,
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

local stream_ammo_type =
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
}


attack_parameters =
{
  type = "projectile",
  ammo_category = "capsule",
  cooldown = 30,
  projectile_creation_distance = 0.6,
  range = 25,
  ammo_type =
  {
    category = "capsule",
    target_type = "position",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = "poison-capsule",
        starting_speed = 0.3
      }
    }
  }
}

local make_capsule_stream = function(attack_parameters)
  local ammo_type = attack_parameters.ammo_type
  local root_projectile
  local root_speed
  if ammo_type and ammo_type.action and ammo_type.action.action_delivery.type == "projectile" then
    root_projectile = ammo_type.action.action_delivery.projectile
    root_speed = ammo_type.action.action_delivery.starting_speed
  end
  if not root_projectile and root_speed then return end
  local projectile_prototype = data.raw.projectile[root_projectile]
  if not projectile_prototype then return end

  root_speed = math.max(root_speed, 0.1)
  --root_speed = root_speed + (300 * root_speed * (projectile_prototype.acceleration or 0))
  if projectile_prototype.max_speed then
    root_speed = math.min(root_speed, projectile_prototype.max_speed)
  end

  local stream =
  {
    type = "stream",
    name = projectile_prototype.name.."-stream",
    particle = (projectile_prototype.animation and projectile_prototype.animation[1]) or projectile_prototype.animation,
    shadow = (projectile_prototype.shadow and projectile_prototype.shadow[1]) or projectile_prototype.shadow,
    particle_buffer_size = 1,
    particle_spawn_interval = 0,
    particle_spawn_timeout = 1,
    particle_vertical_acceleration = 0.981 / 60,
    particle_horizontal_speed = root_speed,
    particle_horizontal_speed_deviation = root_speed * 0.1,
    particle_start_alpha = 1,
    particle_end_alpha = 1,
    particle_start_scale = 1,
    particle_loop_frame_count = 1,
    particle_fade_out_threshold = 1,
    particle_loop_exit_threshold = 1,
    smoke_sources = projectile_prototype.smoke,
    action = projectile_prototype.action,
    progress_to_create_smoke = 0,
    oriented_particle = true,
    stream_light = projectile_prototype.light
  }

  data:extend{stream}

  attack_parameters.ammo_type.action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = stream.name,
      source_offset = {0, -(projectile_prototype.height or 1)}
    }
  }

  return attack_parameters
end

local make_capsule_throw = function(capsule_item)
  local action = capsule_item.capsule_action
  local attack_parameters = make_capsule_stream(action.attack_parameters)
  if not attack_parameters then return end
  --error(serpent.block(attack_parameters))
  capsule_item.capsule_action.attack_parameters = attack_parameters

end

--make_capsule_throw(data.raw.capsule["poison-capsule"])
--make_capsule_throw(data.raw.capsule["slowdown-capsule"])
--make_capsule_throw(data.raw.capsule["grenade"])
--make_capsule_throw(data.raw.capsule["cluster-grenade"])
--make_capsule_throw(data.raw.capsule["defender-capsule"])
--make_capsule_throw(data.raw.capsule["distractor-capsule"])
--make_capsule_throw(data.raw.capsule["destroyer-capsule"])
--make_capsule_throw(data.raw.capsule["cliff-explosives"])

for k, capsule in pairs (data.raw.capsule) do
  if capsule.capsule_action.type == "throw" then
    make_capsule_throw(capsule)
  end
end