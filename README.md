# lua-signals
Signals are variables.

Signals can depend on other Signals and are recomputed each time on of their depencies change.

Effects execute everytime one of their depencies change.

### Importing
If you don't use roblox, replace the PathToModule with the string. Everything else stays the same.
```lua
local Signal = require(PathToModule)
local createSignal = Signal.createSignal
local deriveSignal = Signal.deriveSignal
local effect = Signal.effect
```

### Documentation
- `local read, write = createSignal(value)`: <p> - returns a read and write function: <p> - read: returns the value of the signal <p> - write: takes a value and sets the signal to that value
- `local read = deriveSignal(function() return ... end)`: <p> - Executes the function that is passed in everytime one of its dependencies changes <p> - Returns a signal that is updated with the return value of the function everytime one of its dependencies changes <p>  -The function should be pure
- `effect(function() ... end`: <p> - Executes the function that is passed in everytime one of its dependencies changes <p> - The function should be impure as returning something from it doesn't do anything
- `local value = untrack(function() return ... end)`: <p> - Executes a function without registering dependencies <p> - Returns the value the passed in function returns or nil
- `local read = on({dep1, dep2, ...}, function() ... end)`: <p> - {dep1, ...}: A array of signal getters. Whenever one of the passed in signals changes, the function gets rerun <p> - takes a function as second parameter that gets executed whenever one of its passed in dependencies changes. Getters in the function body aren't registered as dependencies

## This seems like magic. How does each function know its dependencies?
Its complicated. I essentially translated this [article](https://dev.to/ryansolid/building-a-reactive-library-from-scratch-1i0p) into lua. I don't rebuild the dependencies on every run though, so if you had a branched derived Signal or effect, it would rexecute when those change too. Dependencies are registered when the read function for the dependency is called inside the function, so branching may manipulate the executing of effects in ways you wouldn't predict.
