--Biters colliding is dumb!

for k, unit in pairs (data.raw.unit) do
  unit.collision_mask = unit.collision_mask or {"player-layer", "train-layer", "not-colliding-with-itself"}
  if unit.ai_settings then
    unit.ai_settings.path_resolution_modifier = unit.ai_settings.path_resolution_modifier or -1
  end
end

-- Make groups pathfind with lower resolution.

data.raw["utility-constants"]["default"].unit_group_pathfind_resolution = -2