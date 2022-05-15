shader_type canvas_item;
render_mode unshaded;

uniform int blur_amount = 1;

void fragment()
{
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	vec4 totals = vec4(0, 0, 0, 0);
	
	for(int x = -blur_amount; x <= blur_amount; ++x)
	{
		for(int y = -blur_amount; y <= blur_amount; ++y)
		{
			totals += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x) / float(screen_size.x), float(y) / float(screen_size.y)), 0.0).rgba;
		}
	}
	
	totals = totals / float((2 * blur_amount + 1)*(2 * blur_amount + 1));
	
	COLOR = totals;
}
