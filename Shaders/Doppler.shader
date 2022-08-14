shader_type canvas_item;
render_mode unshaded;

const float PI = 3.1415926538;
const float rootHalf = 0.70710678118;

const float changeRate = 1.0;
const float changeMag = 1.0;

void fragment()
{
	vec2 centeredUV = SCREEN_UV - vec2(0.5, 0.5);
	float offset = centeredUV.x * 2.0 * 10.0;
	float angle = 0.0;
	
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	vec2 screenSizeFloat = vec2(float(screen_size.x), float(screen_size.y));
	
	vec2 offVec = vec2(offset * cos(angle), offset * sin(angle));
	
	vec2 p1 = SCREEN_UV + offVec / screenSizeFloat;
	vec2 p2 = SCREEN_UV - offVec / screenSizeFloat;
	
	vec4 c1;
	vec4 c2;
	
	if (p1.x < 0.0 || p1.x > 1.0)
		c1 = vec4(1, 1, 1, 1);
	else
		c1 = textureLod(SCREEN_TEXTURE, p1, 0.0);
		c1.r = 1.0;
	
	if (p2.x < 0.0 || p2.x > 1.0)
		c2 = vec4(1, 1, 1, 1);
	else
		c2 = textureLod(SCREEN_TEXTURE, p2, 0.0);
		c2.b = 1.0;
	
	
	vec4 col = mix(c1, c2, 0.5);
	
	COLOR = col;
}
