# lua-signals

### Importing
This is a roblox library. Some methods are type annotated, so using normal lua will cause errors. Simply copy the code from main.lua into a module.
```lua
local Signal = require(PathToModule)
local createSignal = Signal.createSignal
local deriveSignal = Signal.deriveSignal
local effect = Signal.effect
```

### Documentation
## State Signals and Derived Signals
- `local read, write = createSignal(value)`: <p> - returns a read and write function: <p> - read: returns the value of the signal <p> - write: takes a value and sets the signal to that value
- `local read = deriveSignal(function() return ... end)`: <p> - Executes the function that is passed in everytime one of its dependencies changes <p> - Returns a signal that is updated with the return value of the function everytime one of its dependencies changes <p>  -The function should be pure

## Roblox specific constructors
- `local read = fromProperty(instance: Instance, property: string)`: <p> - Turns a property into a Signal <p> - The Signal always holds the value of the property <p> - Changing the value of the property changes the signal too (thats why it only returns a read)
- `local read = fromAttribute(instance: Instance, attribute: string)`: <p> - Same as fromProperty but with attributes
- `local read = fromRBXScriptSignal(rbxScriptSignal: RBXScriptSignal)`: <p> - Returns a signal that holds the value the RBXScriptSignal emitted the last time

## Side Effects
- `effect(function() ... end`: <p> - Executes the function that is passed in everytime one of its dependencies changes <p> - The function should be impure as returning something from it doesn't do anything

## Utility
- `local value = untrack(function() return ... end)`: <p> - Executes a function without registering dependencies <p> - Returns the value the passed in function returns or nil
- `local read = on({dep1, dep2, ...}, function() ... end)`: <p> - {dep1, ...}: A array of signal getters. Whenever one of the passed in signals changes, the function gets rerun <p> - takes a function as second parameter that gets executed whenever one of its passed in dependencies changes. Getters in the function body aren't registered as dependencies

## This seems like magic. How does each function know its dependencies?
Its complicated. I essentially translated this [article](https://dev.to/ryansolid/building-a-reactive-library-from-scratch-1i0p) into lua. I don't rebuild the dependencies on every run though, so if you had a branched derived Signal or effect, it would rexecute when those change too. Dependencies are registered when the read function for the dependency is called inside the function, so branching may manipulate the executing of effects in ways you wouldn't predict.
