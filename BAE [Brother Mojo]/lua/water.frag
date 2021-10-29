#version 120

uniform vec2 gridSize;

varying vec2 imageCoord;
uniform float time;

uniform vec2 textureSize;
uniform sampler2D sampler0;

vec2 random2f( vec2 v )
{
    return fract( sin( vec2( dot(v, vec2(7.0, 82.0) ), 
                             dot(v, vec2(42.0, 18.0) ) ) )*( 34256.2006+time * 0.01 ) );
}

float voronoi2(vec2 v)
{
    vec2 fv = floor(v);
    
    float d = 2.;
    
    // unrolled loops for performance reasons
    d = min(d, distance(fract(v), vec2(-1,-1) + random2f(fv + vec2(-1,-1))));
    d = min(d, distance(fract(v), vec2(-1,0) + random2f(fv + vec2(-1,0))));
    d = min(d, distance(fract(v), vec2(-1,1) + random2f(fv + vec2(-1,1))));
    d = min(d, distance(fract(v), vec2(0,-1) + random2f(fv + vec2(0,-1))));
    d = min(d, distance(fract(v), random2f(fv)));
    d = min(d, distance(fract(v), vec2(0,1) + random2f(fv + vec2(0,1))));
    d = min(d, distance(fract(v), vec2(1,-1) + random2f(fv + vec2(1,-1))));
    d = min(d, distance(fract(v), vec2(1,0) + random2f(fv + vec2(1,0))));
    d = min(d, distance(fract(v), vec2(1,1) + random2f(fv + vec2(1,1))));
    
   	return d;
}

void main()
{
    vec2 squareCoord = vec2( imageCoord.x, 1 - (1 - imageCoord.y) * (1 - imageCoord.y) );
    vec2 gridCoord = gridSize * squareCoord;
    vec2 upperGridCoord = gridCoord + vec2(0,0.5);
    float d = voronoi2(gridCoord);
    float d4 = d * d;
    d4 = d4 * d4;
    float d16s = d4 * d4 * squareCoord.y;
    float ud = voronoi2(upperGridCoord);
    float ud4 = ud * ud;
    ud4 = ud4 * ud4;
    
    vec2 offsetGridCoord = gridCoord + d4 * 3;
    vec2 offsetImageCoord = min(offsetGridCoord / gridSize, vec2(1,1));
    
    vec4 newColor = texture2D(sampler0, offsetImageCoord);
    newColor = newColor * (1 - 0.1 * ud4);
    newColor = (1-d16s) * newColor + d16s * vec4(1,1,1,1);
    newColor.a = 1;
    
    gl_FragColor = newColor;
}