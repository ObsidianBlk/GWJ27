shader_type canvas_item;

uniform int cell_count = 4;
uniform int cell_index = 0;

void fragment(){
	int ci = cell_index;
	if (ci >= cell_count){
		ci = cell_count - 1;
	} else if (ci < 0){
		ci = 0;
	}
	
	float uvh = 1.0/float(cell_count);
	/*float cell = floor(mod(TIME, float(cell_count * 1)) / 1.0);
	float minuvh = uvh * cell;*/
	if (UV.y >= 0.0 && UV.y < uvh){
		vec2 nuv = UV;
		nuv.y += uvh * float(ci);
		COLOR = texture(TEXTURE, nuv);
	} else {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}