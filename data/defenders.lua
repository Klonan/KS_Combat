-- Defender capsules need to shoot with bullets too!

old_attack_parameters =
{
  type = "projectile",
  cooldown = 20,
  projectile_center = {0, 1},
  projectile_creation_distance = 0.6,
  range = 15,
  sound = make_light_gunshot_sounds(),
  ammo_type =
  {
    category = "bullet",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          type = "create-explosion",
          entity_name = "explosion-gunshot-small"
        },
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          },
          {
            type = "damage",
            damage = { amount = 8 , type = "physical"}
          }
        }
      }
    }
  }
}


local make_bullet_entity = function(param)
  data:extend
  {
    {
      type = "projectile",
      name = param.name.."-projectile",
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
        projectile = param.name.."-projectile",
        starting_speed = 1,
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 20
      }
    }
  }
end


local make_into_bullet = function(defender_prototype)
  local ammo_type = defender_prototype.attack_parameters.ammo_type
  ammo_type.target_type = "direction"

  local actions = (ammo_type.action and ammo_type.action[1] and ammo_type.action) or {ammo_type.action}

  for k, action in pairs (actions) do
    local action_deliverys = action.action_delivery and action.action_delivery[1] and action.action_delivery or {action.action_delivery}
    for k, delivery in pairs (action_deliverys) do
      if delivery.target_effects then
        local bullet = make_bullet_entity
        {
          target_effects = delivery.target_effects,
          name = defender_prototype.name
        }
        table.insert(actions, bullet)
        delivery.target_effects = nil
      end
    end
  end

  ammo_type.action = actions
  defender_prototype.attack_parameters.lead_target_for_projectile_speed = 1
end

make_into_bullet(data.raw["combat-robot"].defender)