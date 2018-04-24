precision mediump float;

uniform float time; // seconds
varying vec2 uv;

vec2 rotate(vec2 pos, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, s, -s, c) * pos;
}

float vmax(vec3 v)
{
    return max(max(v.x, v.y), v.z);
}

float plane(vec3 pos)
{
    return pos.y;
}

float sphere(vec3 pos, float radius)
{
    return length(pos) - radius;
}

float box(vec3 pos, vec3 size)
{
    vec3 offset = abs(pos) - size;
    return length(max(offset, 0.0)) + vmax(min(offset, 0.0));
}

float roundedBox(vec3 pos, vec3 size, float radius)
{
    vec3 offset = abs(pos) - size;
    return length(max(offset, 0.0)) + vmax(min(offset, 0.0)) - radius;
}

float ribbon(vec3 pos, float radius)
{
    float angle = pos.z * 0.1;
    vec2 center = vec2(cos(angle), sin(angle)) * 10.0;
    return length(pos.xy - center) - radius;
}

float map(vec3 pos)
{
    float planeDistance = min(plane(pos), ribbon(pos, 2.0));
    
    pos = mod(pos + 5.0, 10.0) - 5.0;
    
    pos.xy = rotate(pos.xy, time);
    pos.xz = rotate(pos.xz, time * 0.7);
    
    return min(planeDistance, box(pos, vec3(2.0)));
}

vec3 albedo(vec3 pos)
{
    return vec3(0.8, 0.8, 0.8);
}

void main()
{
    vec3 pos = vec3(sin(time * 0.2) * 4.0, 5.0 + sin(time * 0.7) * 0.5, time * 4.0);
    vec3 dir = normalize(vec3(uv, 1.0));
    
    vec3 cameraPos = pos;
    
    vec3 color = vec3(0.0);
    
    for (int i = 0; i < 256; i++)
    {
        float d = map(pos);
        if (d < 0.01)
        {
            float lightDistance = ribbon(pos, 2.0);
            vec3 lightColor = vec3(2.0, 0.4, 0.2);
            color = albedo(pos) * 10.0 / (lightDistance * lightDistance + 1.0) * lightColor;
            break;
        }
        
        pos += d * dir;
    }
    
    float fog = exp(-distance(cameraPos, pos) * 0.001);
    color = mix(vec3(0.7, 0.4, 4.0), color, fog);
    
    color /= color + 1.0;
    color = pow(color, vec3(1.0 / 2.2));

	gl_FragColor = vec4(color, 1.0);
}
