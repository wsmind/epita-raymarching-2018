precision mediump float;

uniform float time; // seconds
varying vec2 uv;

vec2 rotate(vec2 pos, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, s, -s, c) * pos;
}

float vmax(vec2 v)
{
    return max(v.x, v.y);
}

float box(vec2 pos, vec2 size)
{
    vec2 offset = abs(pos) - size;
    return length(max(offset, 0.0)) + vmax(min(offset, 0.0)) - 0.5;
}

float sphere(vec2 pos, float radius)
{
    return length(pos) - radius;
}

float plane(vec2 pos)
{
    return pos.y;
}

void main()
{
    vec2 uv2 = uv * 10.0;
   
    uv2 = rotate(uv2, time * 0.4);
   
    float d1 = plane(uv2);
    float d2 = sphere(uv2, 3.0);
    float d3 = box(uv2, vec2(3.0 + sin(time) * 1.0, 2.0));
   
    //float d = mix(d1, d2, sin(time) * 0.5 + 0.9);
    float d = d3;
   
    float c = fract(d) * exp(-d * 0.3);
    vec3 color = c * mix(vec3(1.0, 0.8, 0.2), vec3(0.4, 0.7, 0.9), step(0.0, d));
    color = mix(color, vec3(1.0, 0.0, 0.0), smoothstep(-0.1, -0.09, d) * smoothstep(0.1, 0.09, d));
    gl_FragColor = vec4(color, 1.0);
}