--We want to turn the hitscan auto aim into a fun dakka dakka shoot with bullets thing.

local base_bullet =
{
  type = "projectile",
  name = "piercing-shotgun-pellet",
  flags = {"not-on-map"},
  collision_box = {{-0.05, -0.25}, {0.05, 0.25}},
  acceleration = 0,
  direction_only = true,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        type = "damage",
        damage = {amount = 8, type = "physical"}
      }
    }
  },
  animation =
  {
    filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
    frame_count = 1,
    width = 3,
    height = 50,
    priority = "high"
  }
}

local old =
{
  type = "ammo",
  name = "firearm-magazine",
  icon = "__base__/graphics/icons/firearm-magazine.png",
  icon_size = 32,
  ammo_type =
  {
    category = "bullet",
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          {
            type = "instant",
            source_effects =
            {
              {
                type = "create-explosion",
                entity_name = "explosion-gunshot"
              }
            },
            target_effects =
            {
              {
                type = "create-entity",
                entity_name = "explosion-hit"
              },
              {
                type = "damage",
                damage = { amount = 5 , type = "physical"}
              }
            }
          }
        }
      }
    }
  },
  magazine_size = 10,
  subgroup = "ammo",
  order = "a[basic-clips]-a[firearm-magazine]",
  stack_size = 200
}

local make_bullet_entity = function(param)
  data:extend
  {
    {
      type = "projectile",
      name = param.name,
      flags = {"not-on-map"},
      collision_box = {{-0.05, -0.25}, {0.05, 0.25}},
      acceleration = 0,
      direction_only = true,
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects = param.target_effects
        }
      },
      animation =
      {
        filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
        frame_count = 1,
        width = 3,
        height = 50,
        priority = "high"
      },
      shadow =
      {
        filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
        frame_count = 1,
        width = 3,
        height = 50,
        priority = "high",
        draw_as_shadow = true
      },
      hit_at_collision_position = true,
      force_condition = "not-same",
      light = {intensity = 0.6, size = 4, color = {r=1.0, g=1.0, b=0.5}},
    }
  }
  return
  {
    type = "direct",
    action_delivery =
    {
      {
        type = "projectile",
        projectile = param.name,
        starting_speed = 1,
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 24
      }
    }
  }
end


local shotgun_delivery =
{
  type = "direct",
  repeat_count = 16,
  action_delivery =
  {
    type = "projectile",
    projectile = "piercing-shotgun-pellet",
    starting_speed = 1,
    direction_deviation = 0.3,
    range_deviation = 0.3,
    max_range = 15
  }
}

local make_into_bullet = function(ammo_item)
  local ammo_type = ammo_item.ammo_type
  ammo_type.target_type = "direction"

  local actions = (ammo_type.action and ammo_type.action[1] and ammo_type.action) or {ammo_type.action}

  for k, action in pairs (actions) do
    local action_deliverys = action.action_delivery and action.action_delivery[1] and action.action_delivery or {action.action_delivery}
    for k, delivery in pairs (action_deliverys) do
      if delivery.target_effects then
        local bullet = make_bullet_entity
        {
          target_effects = delivery.target_effects,
          name = ammo_item.name
        }
        table.insert(actions, bullet)
        delivery.target_effects = nil
      end
    end
  end

  ammo_type.action = actions
end

for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("magazine") then
    make_into_bullet(ammo)
  end
end
--e
--emake_into_bullet(data.raw.ammo["firearm-magazine"])
--emake_into_bullet(data.raw.ammo["piercing-rounds-magazine"])
--emake_into_bullet(data.raw.ammo["uranium-rounds-magazine"])
