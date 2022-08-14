shader_type canvas_item;
render_mode unshaded;

const float rootHalf = 0.70710678118;

const float balloon = 0.15;
const int offset = 20;

bool closeTo(float v1, float v2)
{
	return abs(v1-v2) <= 3.0;
}

bool inBounds(vec2 val)
{
	return val.x >= 0.0 && val.x <= 1.0 && val.y >= 0.0 && val.y <= 1.0;
}

void fragment()
{	
	vec2 centeredUV = SCREEN_UV - vec2(0.5, 0.5);
	float dist = length(centeredUV) / rootHalf;
	vec2 translatedUV = (SCREEN_UV - vec2(0.5, 0.5)) * (1.0 - balloon + balloon * dist) * (1.0 + balloon / 3.0) + vec2(0.5, 0.5);
	
	ivec2 screen_size = textureSize(SCREEN_TEXTURE, 0);
	vec2 screenSizeFloat = vec2(float(screen_size.x), float(screen_size.y));
	vec2 screenPos = screenSizeFloat * translatedUV;
	
	vec4 c;
	if (inBounds(translatedUV))
	{
		c = textureLod(SCREEN_TEXTURE, translatedUV, 0.0).rgba;
		if (closeTo(mod(screenPos.y, float(offset)), 0))
			c = mix(c, vec4(0, 0, 0, 1), 0.2);
	}
	else
		c = vec4(0, 0, 0, 1);
	
	COLOR = c;
}