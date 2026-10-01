-- Shared normal-wave stats and Boss pressure. Native models do not dictate balance.
local Curve = {VERSION="wave-curve-2026-10-01-1"}
function Curve.Normal(wave)
 local w=math.max(1,math.min(60,wave))
 local late=math.max(0,(w-40)/20)
 return {
  hp=math.floor(120*1.055^(w-1)*(1+1.8*late^3)),
  damage=math.floor(10*1.037^(w-1)*(1+1.25*late^2)),
  armor=math.floor(12*(w-1)/59),speed=math.floor(270+80*(w-1)/59),
  magicResistance=math.floor(25*(w-1)/59),
 }
end
function Curve.Solo(wave)
 local progress=math.max(0,math.min(1,(wave-1)/29))
 return 0.75+0.25*progress,0.70+0.30*progress
end
function Curve.Boss(wave)
 local progress=math.max(0,math.min(1,(wave-5)/55))
 return 0.80+1.70*progress^1.5,0.85+0.90*progress^1.3
end
return Curve
