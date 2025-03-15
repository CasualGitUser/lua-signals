--set
local Set = {}
Set.__index = Set
function Set.new()
  local self = setmetatable({ list = {} }, Set)
  return self
end

function Set:add(value)
  for _, v in ipairs(self.list) do
    if v == value then return end
  end
  table.insert(self.list, value)
end

function Set:remove(value)
  for i, v in ipairs(self.list) do
    if v == value then table.remove(self.list, i) end
  end
end

function Set:iter()
  return ipairs(self.list)
end

--reactive stack
local reactiveStack = {}
--wether dependencies are currently tracked
local tracking = true

--utility func to register f on the reactive stack
local function reactiveFunc(f)
  local funcObject = {}
  funcObject.execute = function()
    table.insert(reactiveStack, funcObject)
    f()
    table.remove(reactiveStack, #reactiveStack)
  end
  return funcObject
end

--state signal
-- @param value: T
-- @returns read: () -> T
-- @returns write: (T) -> ()
local function createSignal(value)
  local dependents = Set.new()

  local read = function()
    local dependent = reactiveStack[#reactiveStack]
    if dependent and tracking then dependents:add(dependent) end
    return value
  end

  local write = function(newValue)
    value = newValue
    if not tracking then return end
    for _, dependent in dependents:iter() do
      dependent:execute()
    end
  end

  return read, write
end

--derived signals
-- @param f: () -> T
-- @returns read: () -> T
local function deriveSignal(f)
  local read, write = createSignal(nil)

  reactiveFunc(function()
    write(f())
  end):execute()

  return read
end

--effect
local function effect(e)
  reactiveFunc(function()
    e()
  end):execute()
end

--don't track dependencies of f
-- @param f: () -> T
-- @returns T
local function untrack(f)
  tracking = false
  local val = f()
  tracking = true
  return val
end

--only change when one of dependencies change
-- @param dependencies: {Getter}
-- @param f: () -> ()
local function on(dependencies, f)
  local read, write = createSignal(nil)
  reactiveFunc(function()
    for _, dependency in ipairs(dependencies) do
      dependency()
    end
    write(untrack(f))
  end):execute()

  return read
end

--exports
return {
  createSignal = createSignal,
  deriveSignal = deriveSignal,
  effect = effect,
  untrack = untrack,
  on = on
}
