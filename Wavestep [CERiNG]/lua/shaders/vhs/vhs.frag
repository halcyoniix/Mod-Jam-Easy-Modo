//from uksrt9 credits (halcyoniix)

#version 120

#define V vec2(0.,1.)
#define PI 3.14159265
#define HUGE 1E9
#define SMRES vec2(640.0,480.0)
#define saturate(i) clamp(i,0.,1.)
#define lofi(i,d) floor(i/d)*d
#define validuv(v) (abs(v.x-0.5)<0.5&&abs(v.y-0.5)<0.5)

varying vec2 imageCoord;

uniform float time;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform sampler2D sampler0;
uniform sampler2D samplerRandom;

vec2 img2tex( vec2 v ) { return v * imageSize / textureSize; }

float v2random( vec2 uv ) {
  return texture2D( samplerRandom, mod( uv, vec2( 1.0 ) ) ).x;
}

vec3 vhsTex2D( vec2 uv ) {
  if ( validuv( uv ) ) {
    return texture2D( sampler0, img2tex( uv ) ).xyz;
  }
  return vec3( 0.1, 0.1, 0.1 );
}

vec3 rgb2yiq( vec3 rgb ) {
  return mat3( 0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312 ) * rgb;
}

vec3 yiq2rgb( vec3 yiq ) {
  return mat3( 1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703 ) * yiq;
}

void main() {
  vec2 uv = imageCoord;

  vec2 uvn = uv;
  vec3 col = vec3( 0.0, 0.0, 0.0 );

  // tape wave
  uvn.x += ( v2random( vec2( uvn.y / 10.0, time / 10.0 ) / 1.0 ) - 0.5 ) / SMRES.x * 2.0;
  uvn.x += ( v2random( vec2( uvn.y, time * 10.0 ) ) - 0.5 ) / SMRES.x * 2.0;

  // tape crease
  float tcPhase = smoothstep( 0.9, 0.96, sin( uvn.y * 8.0 - time * PI * 1.2 ) );
  float tcNoise = smoothstep( 0.3, 1.0, v2random( vec2( uvn.y * 4.77, time ) ) );
  float tc = tcPhase * tcNoise;
  uvn.x = uvn.x - tc / SMRES.x * 16.0;

  // switching noise
  float snPhase = smoothstep( 0.01, 0.0, uvn.y );
  uvn.y += snPhase * 0.3;
  uvn.x += snPhase * ( ( v2random( vec2( uv.y * 100.0, time * 10.0 ) ) - 0.5 ) / SMRES.x * 24.0 );

  // fetch
  col = vhsTex2D( uvn );

  // crease noise
  float cn = tcNoise * ( 0.3 + 0.7 * tcPhase );
  if ( 0.29 < cn ) {
    vec2 uvt = ( uvn + v2random( time * vec2( 0.47, 0.39 ) ) ) * vec2( 0.25, 1.0 );
    float n0 = v2random( uvt );
    float n1 = v2random( uvt + V.yx / SMRES.x );
    if ( n1 < n0 ) {
      col += pow( vec3( n0 ), vec3( 5.0 ) );
    }
  }

  // switching color modification
  col = mix(
    col,
    col.yzx,
    snPhase * 0.4
  );

  // ac beat
  col *= 1.0 + clamp( v2random( vec2( 0.0, uv.y + time * 0.2 ) / 10.0 ) * 0.6 - 0.25, 0.0, 0.1 );

  // bloom
  for ( int x = -5; x < 2; x ++ ) {
    col.xyz += vec3(
      vhsTex2D( uvn + vec2( float( x ) - 0.0, 0.0 ) / SMRES ).x,
      vhsTex2D( uvn + vec2( float( x ) - 3.0, 0.0 ) / SMRES ).y,
      vhsTex2D( uvn + vec2( float( x ) - 6.0, 0.0 ) / SMRES ).z
    ) * 0.08;
  }
  col *= 0.5;

  // color noise, colormod
  col *= 0.9 + 0.01 * texture2D( samplerRandom, mod( uvn * vec2( .2, 1.0 ) + time * vec2( 0.97, 0.45 ), vec2( 1.0 ) ) ).xyz;
  col = saturate( col );

  // yiq
  col = rgb2yiq( col );
  col = vec3( 0.05, -0.01, 0.0 ) + vec3( 1.2, 1.0, 1.4 ) * col;
  col = yiq2rgb( col );

  gl_FragColor = vec4( col, 1.0 );
}