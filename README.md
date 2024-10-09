# Unity Voronoi Water

![A sphere and two planes with various colors and patterns of stylized liquid flowing across them](./voronoi-water-example.webp)

A stylized procedural water-esque shader made in Unity using 4D voronoi noise and flowmaps. 

The project includes a shader graph, two models, three example materials each including a flow map and a three gradient LUT, and a sample scene composed of four meshes demonstrating the included materials.


## Parameters

`Displacement`

Maximum distance to project vertices along their normals. Scaled by cell, with higher cells projected farther.

`Voronoi Stretch`

Stretch factor of the noise sampling coordinate along the flow vector. Higher values create longer strokes and a less cellular appearance.

`Voronoi Scale`

Scale of 3D position used in sampling voronoi noise. Higher values result in a greater density of cells.

`Voronoi Speed`

Factor for time as the 4th dimension of the noise sample coordinates.

`Voronoi Offset`

Unscaled offset added to noise sample coordinates.

`Flow Loop Length`

Duration of the flow animation in seconds. Loops will only be noticeable when $ \text{Voronoi Speed} \times \text{Flow Loop Length} < 1$. Higher values also cause greater distortion. 

`Flow Strength`

Scale of the flow vector. Higher values increase the apparent flow speed and the level of distortion.

`Flowmap`

2D texture representing the flow across the object's surface. Sampled with UVs and converted from tangent space. Make sure to disable ***sRGB (color texture)*** in the texture's import settings. 

`GradientLUT`

1D texture lookup table for cell color. Cells with greater displacement are sampled at higher *x* coordinates.

`Space`

Coordinate space of the noise sample position.

**Object**   
Noise is unaffected by the object's position or orientation.

**World**  
All calculations are done in world space, allowing animations to be tiled across separate meshes. For complex geometry, flow directions will be increasingly distorted the farther the mesh is from the origin. Useful for terrain and other static objects with simple geometry. 

**World Sample**  
Flow vector stretching is done in object space and converted to world space before noise sampling. Noise is relative to world space position without the directional distortion seen with the **World** option, at the cost of no longer tiling across meshes.


## Process

Let $P$ be the vertex position in selected coordinate space and $F$ be the UV sampled flow vector converted from tangent space to the selected coordinate space scaled by Flow Strength.

The voronoi cell $C$ for each vertex is then found in the vertex shader by:

$C = V(0) + V(0.5)$

$V(\text{flowOffset}) = \text{voronoi4D}(S) \times |1 - 2t_f|$

Where the time value $t_f$ and the sample coordinate $S$ are given by

$t_f = frac(\frac{\text{Time}}{\text{FlowLoopLength}} + \text{flowOffset})$

$P_{\text{s}} = \text{proj}_{F}P + \text{VoronoiStretch} \times \text{oproj}_{F}P$

$S_{xyz} = \text{VoronoiScale} \times (P_{\text{s}} - t_fF) + \text{VoronoiOffset}_{xyz}$

$S_w = \text{Voronoi Speed} \times \text{Time} + \text{VoronoiOffset}_w$

$C$ is then used to displace the vertex to $P + C \times \text{Displacement} \times \text{Vertex Normal}$ and to sample the gradient LUT at $(C,0)$ in the fragment shader for albedo values.
