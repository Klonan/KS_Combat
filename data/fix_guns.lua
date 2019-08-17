-- Guns don't need to stack. what a stupid idea.
-- And slowing down is dumb, too, just makes shooting a worse option than using PLD and robots.

for k, gun in pairs (data.raw.gun) do
  gun.stack_size = 1
  gun.attack_parameters.movement_slow_down_factor = 0
end