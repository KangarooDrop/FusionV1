shader_type canvas_item;
render_mode unshaded;

void fragment()
{
	float dst = sqrt(UV.x * UV.x + UV.y * UV.y);
	float alpha = step(0.6, UV).x;
//	COLOR.rgba = vec4(COLOR.rgb, 0);

	vec4 c = texture(TEXTURE, UV);
	if (UV.x > 0.5)
	{
		c.a *= 0.0;
	}
	COLOR = c;
}