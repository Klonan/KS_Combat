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
  rocket.direction_only = false
  rocket.acceleration = 0
  rocket.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
  rocket.shadow = util.copy(rocket.animation)
  rocket.shadow.draw_as_shadow = true
end

local make_rocket_ammo = function(ammo)

  ammo.ammo_type.target_type = "position"
  ammo.ammo_type.clamp_position = "true"


  ammo.ammo_type.action.action_delivery.starting_speed = rocket_speed
  local projectile = ammo.ammo_type.action.action_delivery.projectile

  make_rocket(data.raw.projectile[projectile])

end

for k, ammo in pairs (data.raw.ammo) do
  if ammo.name:find("rocket") then
    make_rocket_ammo(ammo)
  end
end