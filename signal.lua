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

local function createSignal(value)
  local dependents = Set.new()

  local read = function()
    local dependent = reactiveStack[#reactiveStack]
    if dependent then dependents:add(dependent) end
    return value
  end

  local write = function(newValue)
    value = newValue
    for _, dependent in dependents:iter() do
      dependent:execute()
    end
  end

  return read, write
end

local function deriveSignal(f)
  local read, write = createSignal(nil)
  local deriveFunc = {}
  deriveFunc.execute = function()
    table.insert(reactiveStack, deriveFunc)
    write(f())
    table.remove(reactiveStack, #reactiveStack)
  end

  deriveFunc.execute()
  return read
end

local function effect(e)
  local effect = {}
  effect.execute = function()
    table.insert(reactiveStack, effect)
    e()
    table.remove(reactiveStack, #reactiveStack)
  end

  effect.execute()
end

return {
  createSignal = createSignal,
  deriveSignal = deriveSignal,
  effect = effect
}
