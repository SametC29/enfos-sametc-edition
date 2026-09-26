-- Project-owned PvE adaptations. Tuning lives in npc_abilities_custom.txt.
local function value(a,k) return a:GetSpecialValueFor(k) end
local function enemies(c,p,r)
    return FindUnitsInRadius(c:GetTeamNumber(),p,nil,r,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
end
local function damage(a,target,amount,kind)
    if target and not target:IsNull() and target:IsAlive() then
        ApplyDamage({victim=target,attacker=a:GetCaster(),ability=a,damage=amount,damage_type=kind or a:GetAbilityDamageType()})
    end
end
local function effect(path,target)
    local p=ParticleManager:CreateParticle(path,PATTACH_ABSORIGIN_FOLLOW,target)
    ParticleManager:ReleaseParticleIndex(p)
end
for _,name in ipairs({'fury','crit','slashes','frost','slow','marksmanship','precision','fiery','fiery_stacks','combustion','burn','angel','warcry','taunt'}) do
    LinkLuaModifier('modifier_enfos_pve_'..name,'abilities/pve_kits',LUA_MODIFIER_MOTION_NONE)
end

bulwark_challenge=class({})
function bulwark_challenge:OnSpellStart()
    local c=self:GetCaster()
    c:EmitSound('Hero_Sven.WarCry')
    c:AddNewModifier(c,self,'modifier_enfos_pve_warcry',{duration=value(self,'duration')})
    for _,u in ipairs(enemies(c,c:GetAbsOrigin(),value(self,'radius'))) do
        if u:GetUnitName()~='enfos_creep_runner' then
            local duration=value(self,'duration')*(u:GetUnitName():find('enfos_boss_',1,true) and 0.25 or 1)
            u:AddNewModifier(c,self,'modifier_enfos_pve_taunt',{duration=duration*(1-u:GetStatusResistance())})
        end
    end
end
modifier_enfos_pve_warcry=class({})
function modifier_enfos_pve_warcry:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_enfos_pve_warcry:GetModifierPhysicalArmorBonus() return value(self:GetAbility(),'bonus_armor') end
function modifier_enfos_pve_warcry:GetEffectName() return 'particles/units/heroes/hero_sven/sven_warcry_buff.vpcf' end
modifier_enfos_pve_taunt=class({})
function modifier_enfos_pve_taunt:IsDebuff() return true end
function modifier_enfos_pve_taunt:CheckState() return {[MODIFIER_STATE_TAUNTED]=true} end
function modifier_enfos_pve_taunt:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget(self:GetCaster())
    self:StartIntervalThink(0.2)
end
function modifier_enfos_pve_taunt:OnIntervalThink()
    local c=self:GetCaster()
    if not c or c:IsNull() or not c:IsAlive() then self:Destroy() end
end
function modifier_enfos_pve_taunt:OnDestroy() if IsServer() then self:GetParent():SetForceAttackTarget(nil) end end

enfos_juggernaut_blade_fury=class({})
function enfos_juggernaut_blade_fury:OnSpellStart()
    self:GetCaster():EmitSound('Hero_Juggernaut.BladeFuryStart')
    self:GetCaster():AddNewModifier(self:GetCaster(),self,'modifier_enfos_pve_fury',{duration=value(self,'duration')})
end
modifier_enfos_pve_fury=class({})
function modifier_enfos_pve_fury:OnCreated() if IsServer() then self:StartIntervalThink(value(self:GetAbility(),'tick_interval')) end end
function modifier_enfos_pve_fury:OnIntervalThink()
    local a=self:GetAbility();local c=self:GetParent()
    for _,u in ipairs(enemies(c,c:GetAbsOrigin(),value(a,'radius'))) do damage(a,u,value(a,'damage_per_sec')*value(a,'tick_interval')) end
end
function modifier_enfos_pve_fury:DeclareFunctions() return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING} end
function modifier_enfos_pve_fury:GetModifierStatusResistanceStacking() return value(self:GetAbility(),'status_resistance') end
function modifier_enfos_pve_fury:GetEffectName() return 'particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf' end
function modifier_enfos_pve_fury:OnDestroy() if IsServer() then self:GetParent():StopSound('Hero_Juggernaut.BladeFuryStart') end end

enfos_juggernaut_blade_dance=class({})
function enfos_juggernaut_blade_dance:GetIntrinsicModifierName() return 'modifier_enfos_pve_crit' end
modifier_enfos_pve_crit=class({})
function modifier_enfos_pve_crit:IsHidden() return true end
function modifier_enfos_pve_crit:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end
function modifier_enfos_pve_crit:GetModifierPreAttack_CriticalStrike(event)
    if IsServer() and not self:GetParent():PassivesDisabled() and event.target and event.target:GetTeamNumber()~=self:GetParent():GetTeamNumber()
        and RollPercentage(value(self:GetAbility(),'crit_chance')) then return value(self:GetAbility(),'crit_mult') end
end

enfos_juggernaut_omni_slash=class({})
function enfos_juggernaut_omni_slash:OnSpellStart()
    local t=self:GetCursorTarget();if t:TriggerSpellAbsorb(self) then return end
    self:GetCaster():EmitSound('Hero_Juggernaut.OmniSlash')
    self:GetCaster():AddNewModifier(self:GetCaster(),self,'modifier_enfos_pve_slashes',{duration=value(self,'duration'),target=t:entindex()})
end
modifier_enfos_pve_slashes=class({})
function modifier_enfos_pve_slashes:IsPurgable() return false end
function modifier_enfos_pve_slashes:CheckState() return {[MODIFIER_STATE_INVULNERABLE]=true,[MODIFIER_STATE_DISARMED]=true,[MODIFIER_STATE_NO_UNIT_COLLISION]=true} end
function modifier_enfos_pve_slashes:OnCreated(kv)
    if not IsServer() then return end
    self.home=self:GetParent():GetAbsOrigin();self.target=EntIndexToHScript(kv.target)
    self:OnIntervalThink();self:StartIntervalThink(value(self:GetAbility(),'slash_interval'))
end
function modifier_enfos_pve_slashes:OnIntervalThink()
    local c=self:GetParent();local a=self:GetAbility()
    if not c:IsAlive() then self:Destroy();return end
    local t=self.target
    if not t or t:IsNull() or not t:IsAlive() then t=enemies(c,c:GetAbsOrigin(),value(a,'radius'))[1] end
    if not t or (t:GetAbsOrigin()-self.home):Length2D()>1200 then self:Destroy();return end
    c:SetAbsOrigin(t:GetAbsOrigin()+Vector(64,0,0))
    damage(a,t,c:GetAverageTrueAttackDamage(t)+value(a,'bonus_damage'),DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf',t)
    self.target=nil
end
function modifier_enfos_pve_slashes:OnDestroy() if IsServer() and self.home then FindClearSpaceForUnit(self:GetParent(),self.home,true) end end

enfos_drow_frost_arrows=class({})
function enfos_drow_frost_arrows:GetIntrinsicModifierName() return 'modifier_enfos_pve_frost' end
modifier_enfos_pve_frost=class({})
function modifier_enfos_pve_frost:IsHidden() return true end
function modifier_enfos_pve_frost:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_enfos_pve_frost:OnAttackLanded(e)
    local c=self:GetParent();local a=self:GetAbility()
    if not IsServer() or e.attacker~=c or c:PassivesDisabled() or c:IsIllusion() or e.target:GetTeamNumber()==c:GetTeamNumber() then return end
    damage(a,e.target,value(a,'bonus_damage')+c:GetAgility()*value(a,'agility_factor'),DAMAGE_TYPE_PHYSICAL)
    e.target:AddNewModifier(c,a,'modifier_enfos_pve_slow',{duration=value(a,'duration')*(1-e.target:GetStatusResistance())})
    effect('particles/units/heroes/hero_drow/drow_frost_arrow.vpcf',e.target)
    e.target:EmitSound('Hero_DrowRanger.FrostArrows')
end
modifier_enfos_pve_slow=class({})
function modifier_enfos_pve_slow:IsDebuff() return true end
function modifier_enfos_pve_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_enfos_pve_slow:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(),'slow_pct') end

enfos_drow_multishot=class({})
function enfos_drow_multishot:GetChannelTime() return value(self,'channel_time') end
function enfos_drow_multishot:OnSpellStart()
    self.elapsed=0;self.sent=0
    local c=self:GetCaster();self.direction=self:GetCursorPosition()-c:GetAbsOrigin();self.direction.z=0
    if self.direction:Length2D()<1 then self.direction=c:GetForwardVector() end
    self.direction=self.direction:Normalized();c:EmitSound('Hero_DrowRanger.Multishot.Channel')
end
function enfos_drow_multishot:OnChannelThink(dt)
    self.elapsed=self.elapsed+dt
    local count=value(self,'arrow_count');local wanted=math.min(count,math.floor(self.elapsed/value(self,'channel_time')*count)+1)
    while self.sent<wanted do
        local c=self:GetCaster();local lane=self.sent%6;local angle=math.rad(-25+lane*10)
        local d=self.direction;local velocity=Vector(d.x*math.cos(angle)-d.y*math.sin(angle),d.x*math.sin(angle)+d.y*math.cos(angle),0)*1200
        ProjectileManager:CreateLinearProjectile({Ability=self,EffectName='particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf',
            vSpawnOrigin=c:GetAbsOrigin(),fDistance=value(self,'arrow_range'),fStartRadius=65,fEndRadius=65,Source=c,
            bHasFrontalCone=false,bReplaceExisting=false,iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType=DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE,
            bDeleteOnHit=false,vVelocity=velocity,bProvidesVision=false})
        self.sent=self.sent+1
    end
end
function enfos_drow_multishot:OnProjectileHit(t)
    if t then damage(self,t,self:GetCaster():GetAverageTrueAttackDamage(t)*value(self,'arrow_damage_pct')/100,DAMAGE_TYPE_PHYSICAL) end
    return false
end
function enfos_drow_multishot:OnChannelFinish() self:GetCaster():StopSound('Hero_DrowRanger.Multishot.Channel') end

enfos_drow_marksmanship=class({})
function enfos_drow_marksmanship:GetIntrinsicModifierName() return 'modifier_enfos_pve_marksmanship' end
modifier_enfos_pve_marksmanship=class({})
function modifier_enfos_pve_marksmanship:IsHidden() return true end
function modifier_enfos_pve_marksmanship:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_enfos_pve_marksmanship:OnAttackLanded(e)
    if IsServer() and e.attacker==self:GetParent() and not e.attacker:PassivesDisabled() and not e.attacker:IsIllusion()
        and e.target:GetTeamNumber()~=e.attacker:GetTeamNumber() and RollPercentage(value(self:GetAbility(),'proc_chance')) then
        damage(self:GetAbility(),e.target,value(self:GetAbility(),'bonus_damage'),DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf',e.target)
    end
end
enfos_drow_precision_aura=class({})
function enfos_drow_precision_aura:GetIntrinsicModifierName() return 'modifier_enfos_pve_precision' end
modifier_enfos_pve_precision=class({})
function modifier_enfos_pve_precision:IsHidden() return true end
function modifier_enfos_pve_precision:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_enfos_pve_precision:GetModifierBonusStats_Agility() return self:GetParent():GetBaseAgility()*value(self:GetAbility(),'bonus_agility_pct')/100 end
function modifier_enfos_pve_precision:GetModifierAttackRangeBonus() return value(self:GetAbility(),'bonus_range') end

enfos_lina_fiery_soul=class({})
function enfos_lina_fiery_soul:GetIntrinsicModifierName() return 'modifier_enfos_pve_fiery' end
modifier_enfos_pve_fiery=class({})
function modifier_enfos_pve_fiery:IsHidden() return true end
function modifier_enfos_pve_fiery:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_enfos_pve_fiery:OnAbilityFullyCast(e)
    if IsServer() and e.unit==self:GetParent() and not e.ability:IsItem() and not e.unit:PassivesDisabled() then
        e.unit:AddNewModifier(e.unit,self:GetAbility(),'modifier_enfos_pve_fiery_stacks',{duration=value(self:GetAbility(),'fiery_soul_stack_duration')})
    end
end
modifier_enfos_pve_fiery_stacks=class({})
function modifier_enfos_pve_fiery_stacks:OnCreated() if IsServer() then self:SetStackCount(1) end end
function modifier_enfos_pve_fiery_stacks:OnRefresh() if IsServer() then self:SetStackCount(math.min(self:GetStackCount()+1,value(self:GetAbility(),'fiery_soul_max_stacks'))) end end
function modifier_enfos_pve_fiery_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_enfos_pve_fiery_stacks:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount()*value(self:GetAbility(),'fiery_soul_attack_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount()*value(self:GetAbility(),'fiery_soul_move_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetEffectName() return 'particles/units/heroes/hero_lina/lina_fiery_soul.vpcf' end

enfos_lina_laguna_blade=class({})
function enfos_lina_laguna_blade:OnSpellStart()
    local t=self:GetCursorTarget();if t:TriggerSpellAbsorb(self) then return end
    local c=self:GetCaster();local pos=t:GetAbsOrigin();t:EmitSound('Ability.LagunaBladeImpact')
    local p=ParticleManager:CreateParticle('particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf',PATTACH_CUSTOMORIGIN,c)
    ParticleManager:SetParticleControlEnt(p,0,c,PATTACH_POINT_FOLLOW,'attach_attack1',c:GetAbsOrigin(),true)
    ParticleManager:SetParticleControlEnt(p,1,t,PATTACH_POINT_FOLLOW,'attach_hitloc',pos,true);ParticleManager:ReleaseParticleIndex(p)
    damage(self,t,value(self,'damage'))
    for _,u in ipairs(enemies(c,pos,value(self,'overflow_radius'))) do
        if u~=t then damage(self,u,value(self,'damage')*value(self,'overflow_damage_pct')/100) end
    end
end
enfos_lina_combustion=class({})
function enfos_lina_combustion:GetIntrinsicModifierName() return 'modifier_enfos_pve_combustion' end
modifier_enfos_pve_combustion=class({})
function modifier_enfos_pve_combustion:IsHidden() return true end
function modifier_enfos_pve_combustion:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_enfos_pve_combustion:GetModifierSpellAmplify_Percentage() return value(self:GetAbility(),'spell_amp') end
function modifier_enfos_pve_combustion:OnTakeDamage(e)
    local a=self:GetAbility();local c=self:GetParent()
    if IsServer() and e.attacker==c and e.inflictor and e.inflictor~=a and not e.inflictor:IsItem()
        and not c:PassivesDisabled() and e.unit:IsAlive() and e.unit:GetTeamNumber()~=c:GetTeamNumber() then
        e.unit:AddNewModifier(c,a,'modifier_enfos_pve_burn',{duration=value(a,'burn_duration')})
    end
end
modifier_enfos_pve_burn=class({})
function modifier_enfos_pve_burn:IsDebuff() return true end
function modifier_enfos_pve_burn:OnCreated() if IsServer() then self:StartIntervalThink(0.5) end end
function modifier_enfos_pve_burn:OnIntervalThink() damage(self:GetAbility(),self:GetParent(),value(self:GetAbility(),'burn_dps')*0.5,DAMAGE_TYPE_MAGICAL) end

enfos_omni_guardian_angel=class({})
function enfos_omni_guardian_angel:OnSpellStart()
    local c=self:GetCaster();c:EmitSound('Hero_Omniknight.GuardianAngel.Cast')
    local allies=FindUnitsInRadius(c:GetTeamNumber(),c:GetAbsOrigin(),nil,value(self,'radius'),DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    for _,u in ipairs(allies) do u:AddNewModifier(c,self,'modifier_enfos_pve_angel',{duration=value(self,'duration')}) end
end
modifier_enfos_pve_angel=class({})
function modifier_enfos_pve_angel:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_enfos_pve_angel:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_enfos_pve_angel:GetModifierConstantHealthRegen() return value(self:GetAbility(),'bonus_hp_regen') end
function modifier_enfos_pve_angel:GetEffectName() return 'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf' end
