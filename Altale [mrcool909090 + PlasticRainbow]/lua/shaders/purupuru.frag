//from tetaes's Late-night tower

varying vec2 imageCoord;

uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;
uniform float beat;

uniform float tsuyoi;
uniform float frequencib;

void main()
{
	
	
	vec2 uv = imageCoord / textureSize * imageSize;
	
	float w = (0.5 * imageSize.x / textureSize.x - uv.x) * (textureSize.x / textureSize.y);
    float h = (0.5 * imageSize.y / textureSize.y - uv.y);
	float distanceFromCenter = sqrt(w * w + h * h);
	
	float sinArg = distanceFromCenter * frequencib - beat * 6.0;
	float slope = cos(sinArg) ;
	vec4 color = texture2D(sampler0, uv + normalize(vec2(w, h)) * slope * tsuyoi);
	//vec4 color = texture2D(sampler0, uv + normalize(vec2(w, h)) * slope * tsuyoi);
	
	if (color.r < 0.1 && color.g < 0.1 && color.b < 0.1) {discard;}
	
	//if (beat > 36 && beat < 68){
	//	if (color.r > 0.2 && color.g > 0.2 && color.b > 0.2 && uv.x > 0.9 * imageSize.x / textureSize.x){
	//		discard;
	//	}
	//	if (color.r > 0.2 && color.g > 0.2 && color.b > 0.2 && uv.y > 0.9 * imageSize.y / textureSize.y){
	//		discard;
	//	}
	//}
	
	//if (beat > 37 && beat < 38){
	//	if ((color.r > 0.2 || color.g > 0.2 || color.b > 0.2) && uv.x > 0.49 * imageSize.x / textureSize.x && uv.x < 0.51 * imageSize.x / textureSize.x && uv.y > 0.49 * imageSize.y / textureSize.y && uv.y < 0.51 * imageSize.y / textureSize.y){
	//		discard;
	//	}
	//}
	
	gl_FragColor = color;
}