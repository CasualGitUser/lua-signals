# lua-signals
Signals are variables.

Signals can depend on other Signals and are recomputed each time on of their depencies change.

Effects execute everytime one of their depencies change.

### Importing
If you dont't use roblox, replace the PathToModule with the string. Everything else stays the same.
```lua
local Signal = require(PathToModule)
local createSignal = Signal.createSignal
local deriveSignal = Signal.deriveSignal
local effect = Signal.effect
```

### Setters and Getters

The createSignal function takes a value and return two values:
- read: a function that when called returns the value the signal contains
- write: a function that when called with a value sets the signal to that value

```lua
local readNum, writeNum = createSignal(3) -- Signal with the value 3
local num = readNum() -- get the current value of the signal
writeNum(5) -- readNum() now returns 5
```

### Deriving signals
Imagine excel, where cells depend on other cells. Signals are the same.
```lua
local firstName, setFirstName = createSignal("John")
local lastName, setLastName = createSignal("Doe")

local fullName = deriveSignal(function()
  return firstName() .. " " .. lastName()
end)

print("full name is: ", fullName())
```

deriveSignal takes a function that computes a value and returns a function that reads the value.
Derived signals have the following properties:
- fullName() == firstName() .. " " .. lastName() always returns true. <p> Everytime firstName or lastName changes, fullName gets recomputed.

When deriving, the function given to deriveSignal gets executed once to recompute the value for the first time.
Derived Signals shouldn't perform mutations in their function. Thats what effects are for.

### Effects

```lua
local age, setAge = createSignal(30)

effect(function()
  print(fullName() .. " is now " .. age() .. " years old")
end)
```

effect takes a function that returns something. The function gets executed everytime one of its depencies change. <p> In the example above it means that everytime fullName or age changes, the effect gets executed again. Effects also get executed once when they are created.

## This seems like magic. How does each function know its dependencies?
Its complicated. I essentially translated this [article](https://dev.to/ryansolid/building-a-reactive-library-from-scratch-1i0p) into lua. I don't rebuild the dependencies on every run though, so if you had a branched derived Signal or effect, it would rexecute when those change too. Dependencies are registered when the read function for the dependency is called inside the function, so branching may manipulate the executing of effects in ways you wouldn't predict.
