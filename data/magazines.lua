--We want to turn the hitscan auto aim into a fun dakka dakka shoot with bullets thing.

local bullet_speed = 1

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
        starting_speed = bullet_speed,
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 24
      }
    }
  }
end


local make_ammo_type = function(ammo_type, name)

  if settings.startup.aim_assist.value then
    ammo_type.target_type = "entity"
    for k, gun in pairs (data.raw.gun) do
      local type = gun.attack_parameters.ammo_category
      if type == ammo_type.category then
        gun.attack_parameters.lead_target_for_projectile_speed = bullet_speed
      end
    end
  else
    ammo_type.target_type = "direction"
  end

  local actions = (ammo_type.action and ammo_type.action[1] and ammo_type.action) or {ammo_type.action}

  local new_target_effects = {}
  for k, action in pairs (actions) do
    local action_deliverys = action.action_delivery and action.action_delivery[1] and action.action_delivery or {action.action_delivery}
    for k, delivery in pairs (action_deliverys) do
      if delivery.target_effects then
        for k, effect in pairs (delivery.target_effects and delivery.target_effects[1] and delivery.target_effects or {delivery.target_effects}) do
          table.insert(new_target_effects, effect)
        end
        delivery.target_effects = nil
      end
    end
  end
  if next(new_target_effects) then
    local bullet = make_bullet_entity
    {
      target_effects = new_target_effects,
      name = name
    }
    table.insert(actions, bullet)
  end

  ammo_type.action = actions
end

for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("magazine") then
    make_ammo_type(ammo.ammo_type, ammo.name)
  end
end
--e
--emake_into_bullet(data.raw.ammo["firearm-magazine"])
--emake_into_bullet(data.raw.ammo["piercing-rounds-magazine"])
--emake_into_bullet(data.raw.ammo["uranium-rounds-magazine"])

--error(serpent.block(data.raw.ammo["incendiary-rounds-magazine"]))

-- Rampant bullet armor

local equipment = data.raw["active-defense-equipment"]["bullets-passive-defense-rampant-arsenal"]
if equipment then
  make_ammo_type(equipment.attack_parameters.ammo_type, equipment.name)
end
