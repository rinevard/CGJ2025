shader_type canvas_item;

// ================================================================
// 参数定义 (和之前一样，但增加了一个扭曲强度参数)
// ================================================================

// uniform float noise_amount: 噪点效果的强度。
uniform float noise_amount : hint_range(0.0, 1.0) = 0.25;
// uniform float noise_speed: 噪点图案变化的闪烁速度。
uniform float noise_speed : hint_range(0.0, 50.0) = 10.0;
// uniform vec4 tint_color: 精灵的整体色调。
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// uniform bool enable_glitch: 是否启用扫描线闪烁效果的开关。
uniform bool enable_glitch = true;
// uniform vec4 glitch_color: 闪烁扫描线的颜色。
uniform vec4 glitch_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // 默认改为黑色，方便看清覆盖效果
// uniform float glitch_intensity: 闪烁效果的亮度或覆盖强度。
uniform float glitch_intensity : hint_range(0.0, 2.0) = 1.0;
// uniform float glitch_speed: 扫描线在闪烁区域内滚动的速度。
uniform float glitch_speed : hint_range(0.0, 20.0) = 5.0;
// uniform float glitch_size: 扫描线的密度和粗细。
uniform float glitch_size : hint_range(1.0, 100.0) = 40.0;
// uniform float glitch_band_height: 每次闪烁时，随机亮带区域的垂直高度。
uniform float glitch_band_height : hint_range(0.05, 0.5) = 0.2;
// uniform float glitch_interval: 两次闪烁效果之间的间隔时间（秒）。
uniform float glitch_interval : hint_range(0.5, 10.0) = 3.0; 
// uniform float glitch_duration: 单次闪烁效果的持续时间（秒）。
uniform float glitch_duration : hint_range(0.05, 2.0) = 0.2;

// --- 新增参数 ---
// uniform float distortion_amount: 扫描线造成的水平扭曲强度。0表示不扭曲。
uniform float distortion_amount : hint_range(0.0, 8.0) = 5.0;


float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // --- 核心改动 1: 获取原始Alpha并作为遮罩 ---
    // 在进行任何扭曲之前，先从原始的、未被修改的UV坐标获取alpha值。
    float original_alpha = texture(TEXTURE, UV).a;

    // 如果这个像素在原始纹理中是完全透明的，就直接放弃渲染它。
    // `discard`会立即终止这个像素的着色过程。
    if (original_alpha == 0.0) {
        discard;
    }

    // --- 如果代码执行到这里，说明当前像素在幽灵轮廓内，可以继续计算效果 ---

    // 1. 计算扭曲偏移量
    vec2 uv_offset = vec2(0.0);
    float scanline_strength = 0.0;

    if (enable_glitch && mod(TIME, glitch_interval) < glitch_duration) {
        float glitch_event_seed = round(TIME / glitch_interval);
        float band_y_start = random(vec2(glitch_event_seed)) * (1.0 - glitch_band_height);
        
        if (UV.y > band_y_start && UV.y < band_y_start + glitch_band_height) {
            float scanline_wave = sin((UV.y * glitch_size) + (TIME * glitch_speed));
            scanline_strength = pow(max(0.0, scanline_wave), 20.0);
            
            float distortion_noise = (random(UV.yx + vec2(TIME * 13.45)) - 0.5) * 2.0;
            uv_offset.x = scanline_strength * distortion_amount * distortion_noise;
        }
    }

    // 2. 使用带有偏移的UV坐标来采样纹理
    vec2 distorted_uv = UV + uv_offset;
    vec4 distorted_color_sample = texture(TEXTURE, distorted_uv);

    // 3. 应用颜色效果
    float snow_noise = random(UV + TIME * noise_speed);
    vec3 noisy_color = mix(distorted_color_sample.rgb, vec3(snow_noise), noise_amount);
    
    vec3 final_color = noisy_color;

    if (scanline_strength > 0.0) {
        float glitch_effect_strength = clamp(scanline_strength * glitch_intensity, 0.0, 1.0);
        final_color = mix(final_color, glitch_color.rgb, glitch_effect_strength);
    }
    
    // --- 核心改动 2: 使用原始Alpha来控制最终透明度 ---
    // 应用整体色调，并确保最终的Alpha值是我们一开始保存的原始Alpha。
    // 这可以保留幽灵边缘的半透明羽化效果。
    COLOR = vec4(final_color * tint_color.rgb, original_alpha * tint_color.a);
}