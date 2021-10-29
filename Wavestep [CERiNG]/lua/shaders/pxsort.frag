// from lelya
// https://www.youtube.com/watch?v=7QGTAbU-Jrs

#version 120

uniform bool black = true;
uniform bool horizon = true;
uniform bool reverse = true;
uniform float threshold = 0.7;

varying vec4 color;
varying vec2 imageCoord;
uniform vec2 resolution;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;

vec2 img2tex( vec2 v )
{
	return v / textureSize * imageSize;
}

float gray( vec3 c )
{
	return dot(c,vec3(0.298912,0.586611,0.114478));
}

bool than( float v )
{
	return black ? threshold > v : threshold > 1.0 - v;
}

void main()
{
	vec2 uv = imageCoord;
	vec3 col = texture2D( sampler0, img2tex(uv) ).rgb;
	float luma = gray( col );

	if ( than(luma) )
	{
		vec2 dir = horizon ? vec2(1.0,0.0) : vec2(0.0,1.0);
		float len = horizon ? resolution.x : resolution.y;
		float pos = horizon ? floor(uv.x * len) : floor(uv.y * len);
		float first = 0.0;
		float last = len;

		float p = pos;
		for (int i = 0; i < int(len); ++i)
		{
			p -= 1.0;
			first = p + 1.0;
			if ( p <= -1.0 )
				break;
			vec2 uvn = (p + 0.5) / len * dir + uv * dir.yx;
			vec3 c = texture2D( sampler0, img2tex(uvn) ).rgb;
			float v = gray( c );
			if ( !than(v) )
				break;
		}

		p = pos;
		for (int i = 0; i < int(len); ++i)
		{
			p += 1.0;
			last = p - 1.0;
			if ( p >= len )
				break;
			vec2 uvn = (p + 0.5) / len * dir + uv * dir.yx;
			vec3 c = texture2D( sampler0, img2tex(uvn) ).rgb;
			float v = gray( c );
			if ( !than(v) )
				break;
		}

		col = mix(
			texture2D( sampler0, img2tex((first + 0.5) / len * dir + uv * dir.yx) ).rgb,
			texture2D( sampler0, img2tex((last  - 0.5) / len * dir + uv * dir.yx) ).rgb,
			smoothstep( first, last, reverse ? pos : len - pos )
		);
	}

	gl_FragColor = vec4( col, 1.0 ) * color;
}
