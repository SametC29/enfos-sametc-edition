--------------------------------------------------------------------------------
-- lib/rng.lua
-- Seeded, reproducible random number generator for Enfos SametC Edition
--
-- Uses a linear congruential generator (LCG) for deterministic sequences.
-- Match-seeded RNG enables reproducible Boon candidates, wave modifiers, etc.
--
-- Usage:
--   local RNG = require("lib/rng")
--   local matchRng = RNG:Create(matchSeed)
--   local value = matchRng:NextInt(1, 100)
--   local float = matchRng:NextFloat()
--   local picked = matchRng:Pick({"a", "b", "c"})
--   matchRng:Shuffle(myArray)
--
-- For non-reproducible convenience:
--   RNG:RandomInt(1, 100)   -- uses math.random
--------------------------------------------------------------------------------

if RNG == nil then
	RNG = {}
	RNG.__index = RNG
end

-- LCG constants (Numerical Recipes)
local LCG_A = 1664525
local LCG_C = 1013904223
local LCG_M = 4294967296 -- 2^32

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

--- Create a new seeded RNG instance.
-- @param seed number Integer seed value. Same seed = same sequence.
-- @return table RNG instance
function RNG:Create(seed)
	assert(seed ~= nil, "RNG:Create requires a seed")
	local instance = setmetatable({}, RNG)
	instance._state = math.floor(seed) % LCG_M
	instance._initialSeed = instance._state
	return instance
end

--------------------------------------------------------------------------------
-- Core generation
--------------------------------------------------------------------------------

--- Advance the state and return raw [0, 1) float.
function RNG:_next()
	self._state = (LCG_A * self._state + LCG_C) % LCG_M
	return self._state / LCG_M
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Get the seed this RNG was created with.
-- @return number The initial seed
function RNG:GetSeed()
	return self._initialSeed
end

--- Generate a random integer in [min, max] inclusive.
-- @param min number Lower bound
-- @param max number Upper bound
-- @return number Integer in [min, max]
function RNG:NextInt(min, max)
	assert(min <= max, "RNG:NextInt min must be <= max")
	local range = max - min + 1
	return min + math.floor(self:_next() * range)
end

--- Generate a random float in [0, 1).
-- @return number Float in [0, 1)
function RNG:NextFloat()
	return self:_next()
end

--- Pick a random element from an array.
-- @param array table Non-empty array
-- @return any A random element from the array
function RNG:Pick(array)
	assert(#array > 0, "RNG:Pick requires a non-empty array")
	return array[self:NextInt(1, #array)]
end

--- Shuffle an array in-place (Fisher-Yates).
-- @param array table Array to shuffle
-- @return table The same array, shuffled
function RNG:Shuffle(array)
	for i = #array, 2, -1 do
		local j = self:NextInt(1, i)
		array[i], array[j] = array[j], array[i]
	end
	return array
end

--- Pick N unique elements from an array without replacement.
-- @param array table Source array
-- @param n number Number of elements to pick
-- @return table Array of N picked elements
function RNG:PickN(array, n)
	assert(n <= #array, "RNG:PickN n must be <= array length")
	local copy = {}
	for i, v in ipairs(array) do
		copy[i] = v
	end
	self:Shuffle(copy)
	local result = {}
	for i = 1, n do
		result[i] = copy[i]
	end
	return result
end

--- Weighted random pick. weights[i] corresponds to items[i].
-- @param items table Array of items
-- @param weights table Array of numeric weights (positive)
-- @return any The selected item
function RNG:WeightedPick(items, weights)
	assert(#items == #weights, "RNG:WeightedPick items and weights must match")
	assert(#items > 0, "RNG:WeightedPick requires non-empty arrays")

	local total = 0
	for _, w in ipairs(weights) do
		assert(w >= 0, "RNG:WeightedPick weights must be non-negative")
		total = total + w
	end
	assert(total > 0, "RNG:WeightedPick total weight must be positive")

	local roll = self:NextFloat() * total
	local cumulative = 0
	for i, w in ipairs(weights) do
		cumulative = cumulative + w
		if roll < cumulative then
			return items[i]
		end
	end
	-- Floating point edge case: return last item
	return items[#items]
end

--------------------------------------------------------------------------------
-- Convenience non-seeded API (uses math.random)
--------------------------------------------------------------------------------

--- Non-seeded random integer. Use only for non-reproducible needs.
-- @param min number Lower bound
-- @param max number Upper bound
-- @return number Integer in [min, max]
function RNG:RandomInt(min, max)
	return math.random(min, max)
end

return RNG
