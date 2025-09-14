shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back;

group_uniforms Albedo;
uniform vec4 albedo : source_color;
uniform vec3 emission: source_color;
uniform sampler2D texture_emission : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
group_uniforms;
group_uniforms AmbientOcclusion;
uniform sampler2D texture_ao : source_color,filter_linear_mipmap,repeat_enable;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);
group_uniforms;
group_uniforms Reflectivity;
uniform sampler2D texture_roughness : source_color,filter_linear_mipmap,repeat_enable,hint_roughness_gray;
uniform sampler2D texture_metallic : source_color,filter_linear_mipmap,repeat_enable;
uniform float material_specular: hint_range(0.0, 1.0);
uniform float roughness: hint_range(0.0, 1.0);
group_uniforms;
group_uniforms HeightMap;
uniform sampler2D texture_height : source_color,filter_linear_mipmap,repeat_enable;
group_uniforms;
group_uniforms Normal;
uniform sampler2D texture_normal : filter_linear,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
group_uniforms;
group_uniforms UV1;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(1.0, 1.0, 1.0);
group_uniforms;
group_uniforms HeightMapUV;
uniform vec3 hmUV_scale = vec3(1.0, 1.0, 0.08);
uniform vec3 hmUV_offset = vec3(1.0, 1.0, 1.0);
group_uniforms;


void vertex() {
	vec2 hmUV = UV * hmUV_scale.xy + hmUV_offset.xy;
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX.y -= (texture(texture_height, hmUV).g - hmUV_offset.z) * -hmUV_scale.z;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ROUGHNESS = texture(texture_roughness, UV).g * roughness;
	SPECULAR = material_specular;
	METALLIC = texture(texture_metallic, UV).g;
	NORMAL_MAP = texture(texture_normal,UV).xyz;
	NORMAL_MAP_DEPTH = normal_scale;
	EMISSION = texture(texture_emission,UV).rgb * emission.rgb;
	AO = texture(texture_ao,UV).g;
	AO_LIGHT_AFFECT = ao_light_affect;
}