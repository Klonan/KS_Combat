-- Make rockets fly in an arc.
error("Decided not to")

ammo_type =
{
  category = "rocket",
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "rocket",
      starting_speed = 0.1,
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local make_rocket_stream = function(ammo_type)
  local root_projectile
  local root_speed
  if ammo_type and ammo_type.action and ammo_type.action.action_delivery.type == "projectile" then
    root_projectile = ammo_type.action.action_delivery.projectile
    root_speed = ammo_type.action.action_delivery.starting_speed
  end
  --if not root_projectile and root_speed then return end
  local projectile_prototype = data.raw.projectile[root_projectile]
  --if not projectile_prototype then return end

  local stream =
  {
    type = "stream",
    name = projectile_prototype.name.."-stream",
    particle = projectile_prototype.animation[1] or projectile_prototype.animation,
    shadow = projectile_prototype.shadow[1] or projectile_prototype.shadow,
    particle_buffer_size = 1,
    particle_spawn_interval = 1,
    particle_spawn_timeout = 1,
    particle_vertical_acceleration = 0.981 / 100,
    particle_horizontal_speed = 0.33,
    particle_horizontal_speed_deviation = 0.01,
    particle_start_alpha = 1,
    particle_end_alpha = 1,
    particle_start_scale = 1,
    particle_loop_frame_count = 100,
    particle_fade_out_threshold = 1,
    particle_loop_exit_threshold = 1,
    smoke_sources = projectile_prototype.smoke,
    action = projectile_prototype.action,
    progress_to_create_smoke = 0,
    oriented_particle = true
  }


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

  return ammo_type
end

local make_rocket = function(rocket)
  local ammo_type = make_rocket_stream(rocket.ammo_type)
  rocket.ammo_type = ammo_type

end

--normal rocket targets entity and fails to do the right damage.

local normal_rocket = data.raw.ammo.rocket


make_rocket(data.raw.ammo["rocket"])
make_rocket(data.raw.ammo["atomic-bomb"])
make_rocket(data.raw.ammo["explosive-rocket"])