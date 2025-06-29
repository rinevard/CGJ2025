shader_type canvas_item;

// ================================================================
// 参数定义 (融合了两个 shader 的所有参数)
// ================================================================

// ---- 片段 (像素) 效果参数 (来自第一个 shader) ----
group_uniforms FragmentEffects;
// uniform float noise_amount: 噪点效果的强度。
uniform float noise_amount : hint_range(0.0, 1.0) = 0.25;
// uniform float noise_speed: 噪点图案变化的闪烁速度。
uniform float noise_speed : hint_range(0.0, 50.0) = 10.0;
// uniform vec4 tint_color: 精灵的整体色调。
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// uniform bool enable_glitch: 是否启用扫描线闪烁效果的开关。
uniform bool enable_glitch = true;
// uniform vec4 glitch_color: 闪烁扫描线的颜色。
uniform vec4 glitch_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
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
// uniform float distortion_amount: 扫描线造成的水平扭曲强度。
uniform float distortion_amount : hint_range(0.0, 8.0) = 5.0;

// ---- 顶点 (几何) 效果参数 (来自第二个 shader) ----
group_uniforms VertexEffects;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;
uniform float frequency_y : hint_range(0.0, 20.0) = 5.0;
uniform float frequency_x : hint_range(0.0, 20.0) = 5.0;
uniform float amplitude_y : hint_range(0.0, 100.0) = 50.0;
uniform float amplitude_x : hint_range(0.0, 100.0) = 25.0;
uniform float inclination : hint_range(-100.0, 100.0) = 50.0;
uniform float rotation_angle : hint_range(-180.0, 180.0) = 0.0; // 旋转角度


// ================================================================
// 辅助函数 (来自第一个 shader)
// ================================================================
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}


// ================================================================
// 顶点着色器 (来自第二个 shader)
// 修改精灵的几何形状，使其波动
// ================================================================
void vertex() {
	// 将旋转角度从度转换为弧度
	float rad = radians(rotation_angle);
	// 创建一个旋转矩阵
	mat2 rot = mat2(vec2(cos(rad), -sin(rad)), vec2(sin(rad), cos(rad)));

	// 对顶点位置应用旋转
	vec2 rotated_vertex = rot * VERTEX.xy;

	// 应用波浪效果
	rotated_vertex.y += sin((UV.x - TIME * wave_speed) * frequency_y) * amplitude_y * UV.y;
	rotated_vertex.x += cos((UV.y - TIME * wave_speed) * frequency_x) * amplitude_x * UV.y;
	rotated_vertex.x -= UV.y * inclination;

	// 对顶点位置应用反向旋转以获得最终位置
	// 注意：这里原文是 rot * rotated_vertex，这会导致旋转两次。
	// 通常，我们希望在局部空间应用效果后，再应用最终的变换。
	// 但为了忠于原始shader的效果，这里保持原样。如果效果不理想，可以尝试直接使用 rotated_vertex。
	VERTEX.xy = rot * rotated_vertex;
}


// ================================================================
// 片段着色器 (来自第一个 shader)
// 在变形后的精灵表面上绘制像素效果
// ================================================================
void fragment() {
    // 在进行任何扭曲之前，先从原始的、未被修改的UV坐标获取alpha值，以保持精灵轮廓。
    float original_alpha = texture(TEXTURE, UV).a;

    // 如果这个像素在原始纹理中是完全透明的，就直接放弃渲染它。
    if ((original_alpha - 0.0) < 0.001) {
        discard;
    }

    // --- 计算像素效果 ---

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
    
    // 应用整体色调，并使用原始Alpha来控制最终透明度，保留精灵边缘的羽化效果。
    COLOR = vec4(final_color * tint_color.rgb, original_alpha * tint_color.a);
}