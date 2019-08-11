--Make gun turrets lead the target

local make_turret_lead = function(turret_prototype)

  turret_prototype.attack_parameters.lead_target_for_projectile_speed = 1
end

make_turret_lead(data.raw["ammo-turret"]["gun-turret"])