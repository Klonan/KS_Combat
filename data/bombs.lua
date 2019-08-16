-- Make atomic bomb fly in an arc

local bomb_speed = 0.5

local old = {
  type = "ammo",
  name = "atomic-bomb",
  icon = "__base__/graphics/icons/atomic-bomb.png",
  icon_size = 32,
  ammo_type =
  {
    range_modifier = 3,
    cooldown_modifier = 3,
    target_type = "position",
    category = "rocket",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = "atomic-rocket",
        starting_speed = 0.05,
        source_effects =
        {
          type = "create-entity",
          entity_name = "explosion-hit"
        }
      }
    }
  },
  subgroup = "ammo",
  order = "d[rocket-launcher]-c[atomic-bomb]",
  stack_size = 10
}

local make_bomb_stream = function(ammo_type)
  local root_projectile
  local root_speed
  if ammo_type and ammo_type.action and ammo_type.action.action_delivery.type == "projectile" then
    root_projectile = ammo_type.action.action_delivery.projectile
    root_speed = ammo_type.action.action_delivery.starting_speed
  end
  if not root_projectile then return end
  local projectile_prototype = data.raw.projectile[root_projectile]
  if not projectile_prototype then return end

  root_speed = math.max(root_speed, 0.1)
  --root_speed = root_speed + (300 * root_speed * (projectile_prototype.acceleration or 0))
  if projectile_prototype.max_speed then
    root_speed = math.min(root_speed, projectile_prototype.max_speed)
  end

  root_speed = bomb_speed

  local stream =
  {
    type = "stream",
    name = projectile_prototype.name.."-stream",
    particle = (projectile_prototype.animation and projectile_prototype.animation[1]) or projectile_prototype.animation,
    shadow = (projectile_prototype.shadow and projectile_prototype.shadow[1]) or projectile_prototype.shadow,
    particle_buffer_size = 1,
    particle_spawn_interval = 1,
    particle_spawn_timeout = 1,
    particle_vertical_acceleration = 0.981 / 150,
    particle_horizontal_speed = root_speed,
    particle_horizontal_speed_deviation = root_speed * 0.1,
    particle_start_alpha = 1,
    particle_end_alpha = 1,
    particle_start_scale = 1,
    particle_loop_frame_count = 1,
    particle_fade_out_threshold = 1,
    particle_loop_exit_threshold = 1,
    smoke_sources = util.copy(projectile_prototype.smoke),
    action = projectile_prototype.action,
    progress_to_create_smoke = 0,
    oriented_particle = true,
    stream_light = projectile_prototype.light
  }
  stream.smoke_sources[1].position = {0,0}
  --error(serpent.block(stream))

  data:extend{stream}

  ammo_type.action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = stream.name,
      source_offset = {0, -(projectile_prototype.height or 1)}
    }
  }

end

local make_bomb = function(bomb_item)
  make_bomb_stream(bomb_item.ammo_type)

end

make_bomb(data.raw.ammo["atomic-bomb"])