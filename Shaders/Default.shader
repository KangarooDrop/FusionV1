shader_type canvas_item;
render_mode unshaded;

void fragment()
{
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgba;
}
