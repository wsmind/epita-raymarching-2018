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

vec2 moda(vec2 pos, float frequency)
{
    float angle = atan(pos.y, pos.x);
    float period = 6.2832 / frequency;
    float newAngle = mod(angle + period * 0.5, period) - period * 0.5;
    return rotate(pos, newAngle - angle);
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
    float angle = pos.z * 0.1 + time;
    vec2 center = vec2(cos(angle), sin(angle)) * 20.0;
    return length(pos.xy - center) - radius;
}

float map(vec3 pos)
{
    //float planeDistance = min(plane(pos), ribbon(pos, 2.0));
    float ribbonDistance = ribbon(pos, 2.0);
    
    pos = mod(pos + 20.0, 40.0) - 20.0;
    
    pos.xy = rotate(pos.xy, time * 0.2);
    pos.xz = rotate(pos.xz, time * 0.7);
    
    pos.xy = moda(pos.xy, 6.0);
    pos.xz = moda(pos.xz, 4.0 + sin(time) * 10.0 + 10.0);
    //pos.x -= time * 0.5;
    
    pos.x -= 12.0 + sin(time * 0.2) * 10.0;
    
    pos.xy = rotate(pos.xy, time);
    pos.xz = rotate(pos.xz, time * 0.7);
    
    //pos.xy = rotate(pos.xy, pos.z * sin(time) * 0.4);

    return min(ribbonDistance, box(pos, vec3(1.4, 0.2, 2.0)));
}

vec3 albedo(vec3 pos)
{
    return vec3(0.8, 0.8, 0.8);
}

vec3 computeNormal(vec3 pos)
{
    vec2 eps = vec2(0.01, 0.0);
    return normalize(vec3(
        map(pos + eps.xyy) - map(pos - eps.xyy),
        map(pos + eps.yxy) - map(pos - eps.yxy),
        map(pos + eps.yyx) - map(pos - eps.yyx)
    ));
}

float computeShading(vec3 normal, vec3 lightDirection)
{
    return max(dot(normal, lightDirection), 0.0);
}

void main()
{
    vec2 uv2 = rotate(uv, sin(time * 0.6) * 0.6);
    
    vec3 pos = vec3(sin(time * 0.2) * 2.0, 0.0 + sin(time * 0.7) * 0.5, -15.0);
    vec3 dir = normalize(vec3(uv2, 1.0));

    vec3 cameraPos = pos;
    
    vec3 fogColor = mix(vec3(0.7, 0.4, 2.0), vec3(0.0, 0.0, 1.0), (uv.x + uv.y) * 0.5);
    vec3 color = fogColor;
    
    for (int i = 0; i < 128; i++)
    {
        float d = map(pos);
        if (d < 0.01)
        {
            //color = vec3(1.0); break;
            
            float lightDistance = ribbon(pos, 2.0);
            vec3 lightColor = vec3(2.0, 0.4, 0.2);
            color = albedo(pos) * 100.0 / (lightDistance * lightDistance + 1.0) * lightColor;
            
            const vec3 lightDirection = normalize(vec3(1.0, 1.0, 0.0));
            
            vec3 normal = computeNormal(pos);
            color += computeShading(normal, lightDirection) * vec3(0.9, 0.4, 5.0);
            
            float fog = exp(-distance(cameraPos, pos) * 0.01);
            color = mix(fogColor, color, fog);
            
            break;
        }
        
        pos += d * dir * 0.4;
    }
    
    color /= color + 1.0;
    color = pow(color, vec3(1.0 / 2.2));

	gl_FragColor = vec4(color, 1.0);
}
