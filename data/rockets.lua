local rocket_speed = 0.5

local old = {
  type = "ammo",
  name = "rocket",
  icon = "__base__/graphics/icons/rocket.png",
  icon_size = 32,
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
  },
  subgroup = "ammo",
  order = "d[rocket-launcher]-a[basic]",
  stack_size = 200
}

local make_rocket = function(rocket)
  if not rocket then return end
  rocket.direction_only = false
  rocket.acceleration = 0
  rocket.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
  rocket.shadow = util.copy(rocket.animation)
  rocket.shadow.draw_as_shadow = true
  rocket.hit_at_collision_position = true
  rocket.force_condition = "not-same"
end

local fix_ammo_type = function(ammo_type)
  ammo_type.target_type = "position"
  ammo_type.clamp_position = "true"

  for k, action in pairs (ammo_type.action and ammo_type.action[1] and ammo_type.action or {ammo_type.action}) do
    if action.action_delivery and action.action_delivery.projectile and data.raw.projectile[action.action_delivery.projectile] then
      action.action_delivery.starting_speed = rocket_speed
      make_rocket(data.raw.projectile[action.action_delivery.projectile])
    end
  end
end

local make_rocket_ammo = function(ammo)

  local ammo_type = ammo.ammo_type

  if ammo_type[1] then
    for k, type in pairs (ammo_type) do
      fix_ammo_type(type)
    end
  else
    fix_ammo_type(ammo_type)
  end

end

for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("rocket") then
    make_rocket_ammo(ammo)
  end
end