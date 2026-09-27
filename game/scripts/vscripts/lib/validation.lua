local Validation = {}
function Validation.Finite(value)
    local n = tonumber(value)
    return n and n == n and n > -math.huge and n < math.huge and n or nil
end
function Validation.Amount(value)
    local n = Validation.Finite(value)
    if not n or n <= 0 or n > 100000000 then return nil end
    return math.floor(n)
end
return Validation
