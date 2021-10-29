// original shader from https://www.shadertoy.com/view/wsKXRK
// edited and modified for nITG use hehe ~Kirby

#define PI 3.14159265

varying vec4 color;
varying vec2 textureCoord;
varying vec2 imageCoord;

uniform float time;
uniform float speed;
uniform float shift;

uniform float hscale;
uniform float vscale;

uniform float glowRad;

uniform vec2 resolution;
uniform vec2 textureSize;
uniform vec2 imageSize;

float vDrop(vec2 uv,float t)
{
    uv.x = uv.x*64.0;						// H-Count
    float dx = fract(uv.x);
    uv.x = floor(uv.x);
    uv.y *= 0.05;							// stretch
    float o=sin(uv.x*215.4);				// offset
    float s=cos(uv.x*33.1)*speed + .7;		// speed
    float trail = mix(95.0,35.0,s);			// trail length
    float yv = fract(uv.y + t*s + o) * trail;
    yv = 1.0/yv;
    yv = smoothstep(0.0,1.0,yv*yv);
    yv = sin(yv*PI)*(s*5.0);
    float d2 = sin(dx*PI);
    return yv*(d2*d2);
}

void main()
{
	vec2 center = vec2(hscale,vscale) * 0.5;
	
	//starfield
    vec2 p = imageCoord - (center + shift) * textureSize / imageSize;
    float d = length(p)+0.1;
	p = vec2(atan(p.x, p.y) / PI, 2.5 / d);
    float t = time*0.4;
	
    vec3 col = vec3(0.8,0.25,0.21) * vDrop(p,t); //red
    col += vec3(0.24,0.855,0.92) * vDrop(p,t+0.33); //cyan
    col += vec3(0.23, 0.92, 0.165) * vDrop(p,t+0.67); //green
    col = col*(d*d);
    
    if (col.b < 0.1) {col.b = 0.1;} //background
	
	//glow
	
	vec2 uv = imageCoord.xy;
    vec2 pos = vec2(0.5,0.5) - uv;
    //pos.y /= imageCoord.x/imageCoord.y;
    
    float dist = 1./length(pos);
    dist *= glowRad; //damping radius
    
    vec3 glow = dist * vec3(1.,1.,1.);
    glow = 1.0 - exp(-glow);
    col += glow;
	
	gl_FragColor = vec4(col, 1.0) * color;
}