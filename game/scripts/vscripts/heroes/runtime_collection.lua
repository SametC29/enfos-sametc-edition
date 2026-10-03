-- Optional, best-effort diagnostics. Never required for match state.
local Collection={count=0,limit=10,pending=0}
local Config=require('heroes/runtime_collection_config')
function Collection.RecordHero(hero,entry)
    if not IsServer() or not Config.enabled or Collection.count>=Collection.limit
        or Collection.pending>=10 or hero.enfosRuntimeSnapshotAttempted then return false end
    local ranks={}
    for _,id in ipairs(entry.abilities) do
        local ability=hero:FindAbilityByName(id)
        if not ability or ability:IsNull() then return false end
        ranks[#ranks+1]=tostring(ability:GetLevel())
    end
    -- No names, account identifiers, chat, paths or raw console text.
    Collection.count=Collection.count+1
    hero.enfosRuntimeSnapshotAttempted=true
    local pending=false
    local function release()
        if pending then Collection.pending=math.max(0,Collection.pending-1);pending=false end
    end
    local ok,sent=pcall(function()
        local request=CreateHTTPRequestScriptVM('POST',Config.endpoint)
        request:SetHTTPRequestAbsoluteTimeoutMS(1500)
        request:SetHTTPRequestGetOrPostParameter('schema_version','1')
        request:SetHTTPRequestGetOrPostParameter('hero',entry.id)
        request:SetHTTPRequestGetOrPostParameter('level',tostring(hero:GetLevel()))
        request:SetHTTPRequestGetOrPostParameter('points',tostring(hero:GetAbilityPoints()))
        request:SetHTTPRequestGetOrPostParameter('ranks',table.concat(ranks,','))
        Collection.pending=Collection.pending+1;pending=true
        local result=request:Send(release)
        if not result then release() end
        return result
    end)
    if not ok or not sent then release();return false end
    return true
end
return Collection
