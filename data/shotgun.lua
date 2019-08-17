-- Shotgun sucks. Lets fix it.

local old_shit =
{
  type = "gun",
  name = "shotgun",
  icon = "__base__/graphics/icons/shotgun.png",
  icon_size = 32,
  subgroup = "gun",
  order = "b[shotgun]-a[basic]",
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "shotgun-shell",
    cooldown = 60,
    movement_slow_down_factor = 0.6,
    projectile_creation_distance = 1.125,
    range = 20,
    min_range = 1,
    sound =
    {
      {
        filename = "__base__/sound/pump-shotgun.ogg",
        volume = 0.5
      }
    }
  },
  stack_size = 5
}


local old_shell = {
  type = "ammo",
  name = "shotgun-shell",
  icon = "__base__/graphics/icons/shotgun-shell.png",
  icon_size = 32,
  ammo_type =
  {
    category = "shotgun-shell",
    target_type = "direction",
    clamp_position = true,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            {
              type = "create-explosion",
              entity_name = "explosion-gunshot"
            }
          }
        }
      },
      {
        type = "direct",
        repeat_count = 12,
        action_delivery =
        {
          type = "projectile",
          projectile = "shotgun-pellet",
          starting_speed = 1,
          direction_deviation = 0.3,
          range_deviation = 0.3,
          max_range = 15
        }
      }
    }
  },
  magazine_size = 10,
  subgroup = "ammo",
  order = "b[shotgun]-a[basic]",
  stack_size = 200
}

local fix_shotgun_projectile = function(projectile_name)
  local projectile_prototype = data.raw.projectile[projectile_name]
  if not projectile_prototype then return end
  projectile_prototype.hit_at_collision_position = true
  projectile_prototype.force_condition = "not-same"
  projectile_prototype.final_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-entity",
          entity_name = "explosion-hit"
        }
      }
    }
  }

  projectile_prototype.animation =
  {
    filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
    frame_count = 1,
    width = 3,
    height = 50,
    priority = "high"
  }
  projectile_prototype.shadow =
  {
    filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
    frame_count = 1,
    width = 3,
    height = 50,
    priority = "high",
    draw_as_shadow = true
  }

end


local fix_shells = function(ammo_item)
  local ammo_type = ammo_item.ammo_type
  ammo_type.target_type = "position"
  --ammo_type.clamp_position = true

  local action = ammo_type.action

  for k, effect in pairs(action) do
    local projectile
    if effect.type == "direct" and effect.action_delivery and effect.action_delivery.projectile then

      effect.type = "area"
      effect.target_entities = false
      effect.radius = 1.5

      projectile = effect.action_delivery.projectile
      fix_shotgun_projectile(projectile)
      effect.action_delivery.starting_speed_deviation = 0.1
      effect.action_delivery.max_range = 26
      effect.action_delivery.min_range = 5
      effect.action_delivery.direction_deviation = 0.01

    end
  end

  ammo_item.reload_time = 60

end

local fix_shotgun_gun = function(gun_item)
  gun_item.attack_parameters.cooldown = gun_item.attack_parameters.cooldown * 0.66
  gun_item.attack_parameters.movement_slow_down_factor = 0.2
  gun_item.attack_parameters.min_range = 2
end


for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("shotgun") then
    fix_shells(ammo)
  end
end

for k, gun in pairs (data.raw.gun) do
  if gun.name:find("shotgun") then
    fix_shotgun_gun(gun)
  end
end
