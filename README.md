# Luau-Car-Crash-Script
A simple and performant car crash script for bricky Roblox cars. Do note that this script was made for my game and is NOT READY OUT OF THE BOX.

Find PoolerPlus here! [DevFourm](https://devforum.roblox.com/t/v14-poolerplus-advanced-object-pooling/3817379)

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