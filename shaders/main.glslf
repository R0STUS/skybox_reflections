layout (location = 0) out vec4 f_color;
layout (location = 1) out vec4 f_position;
layout (location = 2) out vec4 f_normal;
layout (location = 3) out vec4 f_emission;

in float a_distance;
in float a_fog;
in vec2 a_texCoord;
in vec3 a_dir;
in vec3 a_normal;
in vec3 a_position;
in vec3 a_realnormal;
in vec3 a_skyLight;
in vec4 a_modelpos;
in vec4 a_torchLight;
in float a_emission;

uniform sampler2D u_texture0;
uniform samplerCube u_skybox;
uniform vec3 u_sunDir;
uniform vec3 u_lightDir;

// flags
uniform bool u_alphaClip;
uniform bool u_debugLights;
uniform bool u_debugNormals;

#include <shadows>

float forceSign(float x) {
    return x >= 0.0 ? 1.0 : -1.0;
}

vec3 reflect_skybox(vec3 normal, vec3 camDir, samplerCube skybox) {
    vec3 viewDir = camDir;
    vec3 reflected = reflect(viewDir, -normal);
    vec3 col = texture(skybox, reflected).rgb;
    return (col - 0.25) * 1.5 + 0.25;
}

void main() {
    vec4 texColor = texture(u_texture0, a_texCoord);
    float alpha = texColor.a;
    if (u_alphaClip) {
        if (alpha < 0.2f)
            discard;
        alpha = 1.0;
    } else {
        if (alpha < 0.002f)
            discard;
    }
    if (u_debugLights)
        texColor.rgb = u_debugNormals ? (a_normal * 0.5 + 0.5) : vec3(1.0);
    else if (u_debugNormals) {
        texColor.rgb *= a_normal * 0.5 + 0.5;
    }
    f_color = texColor;
    f_color.rgb *= min(vec3(1.0), a_torchLight.rgb + a_skyLight);
#ifndef ADVANCED_RENDER
    vec3 fogColor = texture(u_skybox, a_dir).rgb;
    f_color = mix(f_color, vec4(fogColor, 1.0), a_fog);
#endif
    f_color.a = alpha;
    f_position = vec4(a_position, 1.0);
    f_normal = vec4(a_normal, 1.0);
    f_emission = vec4(vec3(a_emission), 1.0);
    if (!u_alphaClip)
        f_color.rgb = mix(f_color.rgb, reflect_skybox(a_realnormal, a_dir, u_skybox), a_skyLight);
}
