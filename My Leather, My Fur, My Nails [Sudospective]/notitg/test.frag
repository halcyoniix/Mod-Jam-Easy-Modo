uniform float time;
uniform vec2 resolution;
uniform vec2 imageCoord;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;


vec2 scale( vec2 v )
{
	return v / textureSize * imageSize;
}

void main()
{
	vec4 f = vec4(vec3(resolution, 0.0), 0.0);
	vec2 g = gl_FragCoord.xy;

    vec2 v = (g + g - f.xy) / f.y, k;
	
    f *= texture( sampler0, scale(g / f.xy) ) / length(f);
    for(g -= g; g.x < 6.3; g += 0.03)
	{
        f += 1e-3 / dot(
            k = v - sin(g + vec2(1.6, 0)) * fract(time * 1.0 + 4.0 * sin(g * 6.0)) * 3.0,
            k
		);
		gl_FragColor = vec4(f);
	}
}