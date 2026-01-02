shader_type canvas_item;

// =============================================================================
// HONK MAGIC - Shader de Fondo con Niebla Procedural
// =============================================================================

uniform vec4 color_deep : source_color = vec4(0.059, 0.059, 0.102, 1.0);      // #0f0f1a
uniform vec4 color_mid : source_color = vec4(0.102, 0.102, 0.180, 1.0);       // #1a1a2e
uniform vec4 color_light : source_color = vec4(0.086, 0.129, 0.243, 1.0);     // #16213e
uniform vec4 color_accent : source_color = vec4(0.482, 0.173, 0.749, 0.3);    // #7b2cbf con alpha

uniform float fog_speed : hint_range(0.01, 0.5) = 0.05;
uniform float fog_scale : hint_range(1.0, 20.0) = 8.0;
uniform float fog_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float particle_density : hint_range(0.0, 100.0) = 50.0;
uniform float particle_size : hint_range(0.001, 0.02) = 0.005;
uniform float particle_glow : hint_range(0.0, 2.0) = 1.0;

// Simplex noise functions
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                        -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289_2(i);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m*m;
    m = m*m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Fractal Brownian Motion
float fbm(vec2 p, float time) {
    float value = 0.0;
    float amplitude = 0.5;
    vec2 shift = vec2(100.0);

    for (int i = 0; i < 4; i++) {
        value += amplitude * snoise(p + time * fog_speed);
        p = p * 2.0 + shift;
        amplitude *= 0.5;
    }
    return value;
}

// Hash function for particles
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Particle layer
float particles(vec2 uv, float time) {
    float result = 0.0;
    vec2 grid = floor(uv * particle_density);

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 cell = grid + vec2(float(x), float(y));
            vec2 cell_uv = fract(uv * particle_density) - vec2(float(x), float(y));

            float h = hash(cell);
            vec2 offset = vec2(
                sin(time * 0.5 + h * 6.28) * 0.3,
                cos(time * 0.3 + h * 6.28) * 0.3
            );

            float dist = length(cell_uv - 0.5 + offset);
            float size = particle_size * (0.5 + h * 0.5);
            float brightness = smoothstep(size, 0.0, dist) * h;

            result += brightness;
        }
    }

    return result * particle_glow;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;

    // Base gradient
    float gradient = uv.y;
    vec4 base_color = mix(color_deep, color_mid, gradient);
    base_color = mix(base_color, color_light, gradient * gradient);

    // Fog layers
    float fog1 = fbm(uv * fog_scale, time);
    float fog2 = fbm(uv * fog_scale * 0.5 + vec2(50.0), time * 0.7);
    float fog = (fog1 + fog2) * 0.5;
    fog = fog * 0.5 + 0.5; // Normalize to 0-1

    // Apply fog
    vec4 fog_color = mix(color_mid, color_light, fog);
    base_color = mix(base_color, fog_color, fog_intensity * fog);

    // Subtle accent color waves
    float accent_wave = sin(uv.x * 3.0 + time * 0.2) * sin(uv.y * 2.0 - time * 0.15);
    accent_wave = accent_wave * 0.5 + 0.5;
    base_color = mix(base_color, color_accent, accent_wave * 0.15);

    // Floating particles
    float p = particles(uv, time);
    vec4 particle_color = vec4(color_accent.rgb * 2.0, p);
    base_color = mix(base_color, particle_color, p * 0.5);

    // Vignette effect
    float vignette = 1.0 - length(uv - 0.5) * 0.8;
    vignette = smoothstep(0.2, 0.8, vignette);
    base_color.rgb *= vignette;

    COLOR = base_color;
}
