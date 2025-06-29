shader_type canvas_item;

// 新增：旋转角度，30度为逆时针
uniform float angle_deg = 30.0;

uniform float animation_speed = 1.0;
uniform float max_effect_y = 0.6;
uniform float fade_softness : hint_range(0.0, 1.0) = 0.5;
// 效果区域顶部的最小可见度
uniform float min_alpha_top : hint_range(0.0, 1.0) = 0.4;
// 图片最底部的最小可见度
uniform float min_alpha_bottom : hint_range(0.0, 1.0) = 0.0;

// 正弦波相关
uniform float wave_frequency = 10.0;
uniform float wave_amplitude = 0.05;
uniform float wave_speed = 1.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
    
    // 如果原始像素是完全透明的，直接跳过所有计算，节省性能
    if ((original_color.a - 0.0) < 0.001) {
        discard;
    }
    
    // --- 坐标旋转 ---
    // 将角度转换为弧度
    // 要让效果逆时针旋转，我们需要对坐标系进行顺时针旋转
    float angle_rad = radians(-angle_deg);
    float s = sin(angle_rad);
    float c = cos(angle_rad);
    
    // 2D旋转矩阵
    mat2 rotation_matrix = mat2(vec2(c, -s), vec2(s, c));
    
    // 将UV坐标原点移动到中心(0.5, 0.5)，执行旋转，再移回
    vec2 centered_uv = UV - vec2(0.5);
    vec2 rotated_uv = rotation_matrix * centered_uv + vec2(0.5);
    // --- 旋转结束 ---

    // 创建动画进度
    float progress = (sin(TIME * animation_speed) + 1.0) / 2.0;

    // 使用旋转后的坐标进行计算
    // 为了代码清晰，将 base_cutoff_y 重命名为 base_cutoff
    float base_cutoff = mix(1.0 + fade_softness, max_effect_y, progress);
    
    // 波浪的扰动现在基于旋转后的 x 坐标，以保证波浪与扫描线垂直
    float wave_offset = sin(rotated_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float final_cutoff = base_cutoff + wave_offset;

    // 计算当前像素受动画影响的程度，使用旋转后的 y 坐标
    float effect_amount = smoothstep(final_cutoff - fade_softness, final_cutoff, rotated_uv.y);
    
    // 计算最小透明度
    // 当前像素在效果区域内的相对“垂直”位置 (同样使用旋转后的 y 坐标)
    float y_progress = clamp((rotated_uv.y - max_effect_y) / (1.0 - max_effect_y), 0.0, 1.0);    
    // 根据y_progress，在顶部和底部的最小透明度之间进行插值
    float dynamic_min_alpha = mix(min_alpha_top, min_alpha_bottom, y_progress);

    // 计算最终的透明度
    float target_alpha = original_color.a * dynamic_min_alpha;
    float new_alpha = mix(original_color.a, target_alpha, effect_amount);

    COLOR = vec4(original_color.rgb, new_alpha);
}