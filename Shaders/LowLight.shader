shader_type canvas_item;
render_mode unshaded;

uniform float alp = 0.3;

void fragment()
{
	vec4 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgba;
	c.r = c.r;
	c.g = max(0.0, c.g - alp);
	c.b = max(0.0, c.b - alp);
	COLOR = c;
}
