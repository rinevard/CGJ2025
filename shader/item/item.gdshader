shader_type canvas_item;

uniform float hint_alpha = 2.0;

void fragment()
{
    vec4 sprite_color = texture(TEXTURE,UV);
    sprite_color.rgb *= hint_alpha;
    COLOR = sprite_color;
} 