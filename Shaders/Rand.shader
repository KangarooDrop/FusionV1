shader_type canvas_item;
render_mode unshaded;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment()
{
	float l0 = rand(UV);
	float l1 = rand(UV * l0);
	float l2 = rand(UV * l1);
	float l3 = rand(UV * l2);
	
	COLOR.rgba = vec4(l0, l1, l2, l3);
}
