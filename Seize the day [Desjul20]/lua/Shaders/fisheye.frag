#version 120

#define PI 3.14159265359
uniform vec2 resolution;
varying vec2 textureCoord;
uniform float beat;
uniform float time;
uniform sampler2D sampler0;
varying vec2 imageCoord;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform float amt = PI*100.0;
uniform float amount;

vec2 texCoord2imgCoord( vec2 uv )
{
  return uv / textureSize * imageSize;
}
// shoutouts to https://www.shadertoy.com/view/4s2GRR :pray:
void main()
{
	vec2 p = gl_FragCoord.xy / imageSize.x;
	float prop = imageSize.x / imageSize.y;
	vec2 m = vec2(0.5, 0.5 / prop);
	vec2 d = p - m;
	float r = sqrt(dot(d, d));

	float power = ( amount * 3.141592 / (2.0 * sqrt(dot(m, m))) ) * (amt / resolution.x - 0.5);

	float bind;
	if (power > 0.0) bind = sqrt(dot(m, m));
	else {if (prop < 1.0) bind = m.x; else bind = m.y;}

	//Weird formulas
	vec2 uv;
	if (power > 0.0)
		uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
	else if (power < 0.0)
		uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
	else uv = p;

	vec2 finalPass = vec2(uv.x,uv.y*prop);

	vec3 col = texture2D(sampler0, texCoord2imgCoord(finalPass)).xyz;
	                                                  
	gl_FragColor = vec4(col, 1.0);
	
}