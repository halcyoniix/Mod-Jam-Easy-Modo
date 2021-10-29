#version 120

uniform vec2 resolution;
uniform sampler2D sampler0;
uniform sampler2D sampler1;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform float pixelSize = 4.0;

varying vec2 textureCoord;
varying vec3 normal;
varying vec3 position;

vec2 scale(vec2 v)
{
	return v / textureSize * imageSize;
}

void main()
{
	vec2 uv = textureCoord.st;
    gl_FragColor = vec4(0.0);


    
    float dx = 1.0 / imageSize.x;
    float dy = 1.0 / imageSize.y;
    uv.x = (dx * pixelSize) * floor(uv.x / (dx * pixelSize));
    uv.y = (dy * pixelSize) * floor(uv.y / (dy * pixelSize));

	for (int i = 0; i < int(pixelSize); i++)
		for (int j = 0; j < int(pixelSize); j++)
			gl_FragColor += texture2D( sampler0, vec2(uv.x + dx * float(i), uv.y + dy * float(j)) );

	gl_FragColor /= pow(pixelSize, 2.0);

}