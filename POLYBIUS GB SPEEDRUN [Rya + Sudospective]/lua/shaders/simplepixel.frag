#version 120

uniform sampler2D sampler0;

uniform vec2 textureSize;
uniform vec2 imageSize;
uniform vec2 textureCoord;

uniform float pixelSize = 4.0;

vec2 scale(vec2 v)
{
	return v / textureSize * imageSize;
}

void main()
{
    vec2 modul=mod(gl_FragCoord.xy,pixelSize);
	vec2 normalizedCord=scale(vec2(gl_FragCoord.xy-modul)/imageSize.xy);
	gl_FragColor=texture2D(sampler0, normalizedCord);
}
