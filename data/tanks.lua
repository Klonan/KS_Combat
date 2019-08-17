-- Make shells shoot in an arc.

local shell_speed = 0.5


local old_stuff =
{
  type = "ammo",
  name = "cannon-shell",
  icon = "__base__/graphics/icons/cannon-shell.png",
  icon_size = 32,
  ammo_type =
  {
    category = "cannon-shell",
    target_type = "direction",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = "cannon-projectile",
        starting_speed = 1,
        direction_deviation = 0.1,
        range_deviation = 0.1,
        max_range = 30,
        min_range = 5,
        source_effects =
        {
          type = "create-explosion",
          entity_name = "explosion-gunshot"
        }
      }
    }
  },
  subgroup = "ammo",
  order = "d[cannon-shell]-a[basic]",
  stack_size = 200
}

local old_projectile =
{
  type = "projectile",
  name = "cannon-projectile",
  flags = {"not-on-map"},
  collision_box = {{-0.3, -1.1}, {0.3, 1.1}},
  acceleration = 0,
  direction_only = true,
  piercing_damage = 300,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = {amount = 200 , type = "physical"}
        },
        {
          type = "damage",
          damage = {amount = 100 , type = "explosion"}
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        }
      }
    }
  },
  final_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-entity",
          entity_name = "small-scorchmark",
          check_buildability = true
        }
      }
    }
  },
  animation =
  {
    filename = "__base__/graphics/entity/bullet/bullet.png",
    frame_count = 1,
    width = 3,
    height = 50,
    priority = "high"
  }
}

local make_shell_stream = function(ammo_type)
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

  local action = util.copy(projectile_prototype.action)
  local actions = action and action[1] and action or {action}
  for k, action in pairs (actions) do
    if action.type == "direct" then
      action.type = "area"
      action.radius = 1
      local dupe = util.copy(action)
      dupe.target_entities = false
      table.insert(actions, dupe)
    end
  end
  if projectile_prototype.final_action then
    for k, action in pairs (projectile_prototype.final_action[1] and projectile_prototype.final_action or {projectile_prototype.final_action}) do
      table.insert(actions, action)
    end
  end

  local shadow = projectile_prototype.shadow
  if not shadow then
    shadow = util.copy(projectile_prototype.animation)
    shadow.draw_as_shadow = true
  end

  local stream =
  {
    type = "stream",
    name = projectile_prototype.name.."-stream",
    particle = (projectile_prototype.animation and projectile_prototype.animation[1]) or projectile_prototype.animation,
    shadow = shadow,
    particle_buffer_size = 1,
    particle_spawn_interval = 1,
    particle_spawn_timeout = 1,
    particle_vertical_acceleration = 0.981 / 100,
    particle_horizontal_speed = shell_speed,
    particle_horizontal_speed_deviation = shell_speed * 0.1,
    particle_start_alpha = 1,
    particle_end_alpha = 1,
    particle_start_scale = 1,
    particle_loop_frame_count = 1,
    particle_fade_out_threshold = 1,
    particle_loop_exit_threshold = 1,
    smoke_sources = projectile_prototype.smoke,
    action = actions,
    progress_to_create_smoke = 0,
    oriented_particle = true,
    stream_light = projectile_prototype.light
  }

  data:extend{stream}
  --error(serpent.block(stream))

  ammo_type.action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = stream.name,
      source_offset = {0, -(projectile_prototype.height or 1)},
      source_effects = ammo_type.action.action_delivery.source_effects
    }
  }

end

local make_shell = function(ammo_item)
  ammo_item.ammo_type.target_type = "position"
  ammo_item.ammo_type.clamp_position = true
  make_shell_stream(ammo_item.ammo_type)
  --error(serpent.block(ammo_item))
end

for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("cannon") then
    make_shell(ammo)
  end
end

local make_cannon_gun = function(gun_item)
  gun_item.attack_parameters.range = 36
end

for k, gun in pairs (data.raw.gun) do
  if gun.name:find("cannon") then
    make_cannon_gun(gun)
  end
end