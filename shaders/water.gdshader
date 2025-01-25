shader_type canvas_item;

// Noise textures for distortion
uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;

// Scroll speeds for the noise textures
uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);

// Screen texture for post-processing
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Distortion and transparency parameters
uniform float distortion_strength : hint_range(-1.0, 1.0) = 0.4;
uniform float transparency : hint_range(0.0, 1.0) = 0.5;

// Top light color and gradient settings
uniform vec4 top_color : source_color;
uniform float light_start : hint_range(0.0, 1.0) = 0.275;
uniform float light_end : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // Calculate animated UV coordinates for the noise textures
    vec2 animated_uv1 = UV + scroll1 * TIME;
    vec2 animated_uv2 = UV + scroll2 * TIME;

    // Sample the noise textures with the animated UV coordinates
    float depth1 = texture(noise1, animated_uv1).r;
    float depth2 = texture(noise2, animated_uv2).r;
    float depth = depth1 * depth2;

    // Distort the screen texture coordinates using the depth value
    vec2 distorted_uv = SCREEN_UV + distortion_strength * vec2(depth);
    distorted_uv = clamp(distorted_uv, vec2(0.0), vec2(1.0)); // Prevent sampling outside bounds

    // Sample the screen texture at the distorted coordinates
    vec4 screen_col = texture(SCREEN_TEXTURE, distorted_uv);

    // Calculate a light gradient effect based on depth
    float light_factor = smoothstep(light_start, light_end, depth);
    vec4 top_light = light_factor * top_color;

    // Blend the screen texture with the light effect and apply transparency
    vec4 final_color = mix(screen_col, top_light, transparency);

    // Output the final color
    COLOR = final_color;
}
