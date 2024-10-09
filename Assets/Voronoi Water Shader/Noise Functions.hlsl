// Taken from Noisy-Nodes:
// https://github.com/JimmyCushnie/Noisy-Nodes/blob/1f212c268860dc1dc260bbd60d03246908508b79/NoiseShader/HLSL/Voronoi4D.hlsl

float4 voronoi_noise_randomVector(float4 UV) {
    const float4x4 m = float4x4(
        15.27, 47.63, 99.41, 89.98, 
        95.07, 38.39, 33.83, 51.06, 
        60.77, 51.15, 92.33, 97.74, 
        59.93, 42.33, 60.13, 35.72
    );

    return frac(sin(mul(UV, m)) * 143758.5453);
}

void Voronoi4D_float(float4 UV, out float Out, out float Cells) {
    float4 g = floor(UV);
    float4 f = frac(UV);
    float3 res = float3(8.0, 8.0, 8.0);
 
    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            for (int z= -1; z <= 1; z++) {
                for (int w = -1; w <= 1; w++) {
                    float4 lattice = float4(x, y, z, w);
                    float4 offset = voronoi_noise_randomVector(g + lattice);
                    float4 v = lattice + offset - f;
                    float d = dot(v, v);

                    if (d < res.x) {
                        res.y = res.x;
                        res.x = d;
                        res.z = offset.x;
                    } else if (d < res.y) {
                        res.y = d;
                    }
                }
            }
        }
    }
 
    Out = res.x;
    Cells = res.z;
}