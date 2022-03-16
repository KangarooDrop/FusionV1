shader_type canvas_item;
render_mode unshaded;

uniform float mullAmt = 0.5;

void fragment()
{
	COLOR.rgba = vec4(mullAmt, mullAmt, mullAmt, mullAmt);
}
