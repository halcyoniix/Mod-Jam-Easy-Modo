#version 130

uniform sampler2D sampler0;
uniform float pixelSize =  0.0001;
uniform vec2 imageSize;
uniform vec2 textureSize;

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord.xy / imageSize.xy;
    
    float plx = imageSize.x * pixelSize / 500.0 / 2;
    float ply = imageSize.y * pixelSize / 275.0 / 2;
    
    float dx = plx * (1.0 / imageSize.x);
    float dy = ply * (1.0 / imageSize.y);
    
    uv.x = dx * floor(uv.x / dx);
    uv.y = dy * floor(uv.y / dy);
    
    fragColor = texture(sampler0, img2tex(uv));
}

void main() {
    mainImage(gl_FragColor.rgba, gl_FragCoord.xy);
}