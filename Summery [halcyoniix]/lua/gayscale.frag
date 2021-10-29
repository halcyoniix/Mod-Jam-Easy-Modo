#version 120
varying vec2 textureCoord;

uniform sampler2D sampler0;
uniform float beat;
uniform float dir = 1.0;

float colRotate( vec3 v, float p ) {
  return (
    v.x * ( 0.4 + 0.6 * sin( p ) ) +
    v.y * ( 0.4 + 0.6 * sin( p - 2.0 ) ) +
    v.z * ( 0.4 + 0.6 * sin( p - 4.0 ) )
  );
}

void main() {
  float p = 1.5 * textureCoord.x;
  vec4 tex = texture2D( sampler0, textureCoord );
  vec3 col = vec3(
    colRotate( tex.xyz, 0.0 + p + (beat * dir) ),
    colRotate( tex.xyz, 2.0 + p + (beat * dir) ),
    colRotate( tex.xyz, 4.0 + p + (beat * dir) )
  );
  gl_FragColor = vec4( col, 1.0 );
}