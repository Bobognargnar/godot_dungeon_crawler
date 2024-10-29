shader_type canvas_item;
float random(vec2 uv) {
	return fract(sin(dot((uv.xy),vec2(12.9898,78.233))) * 4375.5453123);
}

vec2 random_voronoi_center(vec2 index_uv,vec2 neighbor) {
	// More aligned lattice
	return vec2(0.1+0.8*random(floor(index_uv + neighbor)),
			0.0-0.1*random(floor(index_uv + neighbor)));
	// Radomize
	return vec2(random(floor(index_uv + neighbor) + vec2(0.5,0.5)),
			random(floor(index_uv + neighbor)));
}

float mini_dist(int ker, vec2 index_uv, vec2 fract_uv) {
	float minimum_dist = 1000.0;
	for (int y= -ker; y <= ker; y++) {
		for (int x= -ker; x <= ker; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random_voronoi_center(index_uv,neighbor);
			//vec2(random(floor(index_uv + neighbor) + vec2(0.5,0.5)),
			//random(floor(index_uv + neighbor)));

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);

			minimum_dist = min(minimum_dist, dist);
		}
	}
	return minimum_dist;
}

float worley(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	int xx = 1;
	int yy = 1;
	bool is_edge = false;

	minimum_dist = mini_dist(1,index_uv,fract_uv);
	minimum_dist = max(minimum_dist,0.4);

	//
	int count = 0;
	for (int y= -yy; y <= yy; y++) {
		for (int x= -xx; x <= xx; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random_voronoi_center(index_uv,neighbor);
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);

			if (abs(minimum_dist - dist) < 0.1) {
				count = count +1;
			}
			if (count > 1) {
				is_edge = true;
			}
	}}

	if (is_edge) {
		//minimum_dist = 1.0;
		minimum_dist = 1.5*minimum_dist;
		minimum_dist = min(minimum_dist,1.0);
	} else {
		minimum_dist = 0.0;
	}

	//// Center of pixels
	//if (minimum_dist<0.01) {
		//minimum_dist = 1.0;
	//}

	//return pow(minimum_dist,2.0);
	return minimum_dist;//*minimum_dist;
}

float worley_jack(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1000.0;

	int ker = 1;
	bool is_edge = true;

	minimum_dist = mini_dist(1,index_uv,fract_uv);

	for (int y= -ker; y <= ker; y++) {
		if (!is_edge) {break;}
		for (int x= -ker; x <= ker; x++) {
			vec2 neighbor = vec2(float(0),float(y));
			if (abs(mini_dist(1,index_uv,fract_uv+(neighbor))-minimum_dist)>0.1) {
				is_edge = false;
				break;
			}
			is_edge = true;
	}}

	if (is_edge) {
		minimum_dist = 0.0;
		minimum_dist = minimum_dist;
	}

	// Center of pixels
	if (minimum_dist<0.01) {
		minimum_dist = 1.0;
	}

	return pow(minimum_dist,2.0);
	return minimum_dist;//*minimum_dist;
}

void fragment() {

	vec2 grid_uv = UV;
	// Pixelate output
	int amount = 70; // Pixelation amount
	grid_uv = round(grid_uv * float(amount)) / float(amount);

	//vec2 grid_uv = UV; // This disables  the pixelations
	//vec2 uv_deriv = fwidth(grid_uv);
	//float aspect_ratio = uv_deriv.y / uv_deriv.x;
	//grid_uv.x *= aspect_ratio;


	float worley = worley(grid_uv, 3.0, 6.0);


	//worley = smoothstep(0.2, 1.0, worley);
	//worley = step(0.1, worley);

	//COLOR = vec4(vec3(worley), 1.0); // texture
	//COLOR = vec4(texture(TEXTURE, UV).rgb, worley); // transparency


	// Darken the texture color based on the Worley noise
	// Set the color with the adjusted RGB and full alpha
	vec3 texture_color = texture(TEXTURE, UV).rgb * (1.0 - 0.5 * worley);
	COLOR = vec4(texture_color, 1.0);
}