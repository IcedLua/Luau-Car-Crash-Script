# Luau-Car-Crash-Script
A simple and performant car crash script for bricky/low poly Roblox cars. Do note that this script was made for my game and is NOT READY OUT OF THE BOX. If you want more performant (and more realistic!) breaking, try finding a deformation model instead of... this *thing*. This script also functions for buildings and stuff, but there is likely more performant ways to do this.

## Setting It Up
This script is NOT ready out of box because this is for MY GAME, but you can use it too :3
On line 26, update it with the path to PoolerPlus
Find PoolerPlus here on the [DevForum](https://devforum.roblox.com/t/v14-poolerplus-advanced-object-pooling/3817379) page!
```Lua
local Pooler = require("@game/ServerScriptService/Modules/PoolerPlus"):GetPool("DebrisParticlePool")
```
Then, make your collision groups, being:
* `Cars`
* `CarDebris`
* `Wheels`

It is recommended `CarDebris` and `Wheels` is set to not collide with `Cars`, but this may vary if your cars are different.
After, there are some optional tags (CollectionService) you can add to do more, which are:
* `Destructible`
* `CrumpleZone`

## License
This project is licensed under MIT. Please please please give me credit in your game.
```
MIT License

Copyright (c) 2026 Blueb-rry

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Vector Related Benchmarks
THESE BENCHMARKS ARE NOT THE DIRECT PERFORMANCE OF THIS SCRIPT. THESE BENCHMARKS ARE USED TO FIGURE OUT THE FASTEST WAY TO RUN THE SCRIPT'S LOGIC.
BOTH TESTED WITH INTEL I5 12TH GEN (Other applications open.)

*1000 Samples of 1 million runs per sample.*
Magnitude Testing:
```
    (Primatives):   [vector.magnitude(vector.create(0, 0, 0))]
    (Vectors):      [Vector3.New(0, 0, 0).Magnitude]
    (Squaring):     [x*x, y*y, z*z]
    -----------------------------------
    Primatives: 0.157149 seconds
    Vectors:    0.181784 seconds
    Squaring:   0.187247 seconds
    -----------------------------------
```

*100 Samples of 1 hundred thousand runs per sample.*
Subtraction Testing:
```
    (Manual):   [vA.x + vB.x, vA.y + vB.y, vA.z + vB.z]
    (Direct):   [vA + vB]
    ------------------------------------------
    Vector3 Manual:   0.003959s
    Vector3 Direct:   0.001978s
    ------------------------------------------
    Native Manual:    0.003956s
    Native Direct:    0.001980s
    ------------------------------------------
```