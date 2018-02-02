uniform sampler2D chunk;
uniform vec3 cam_pos;
uniform vec3 cam_dir;
uniform float fov;
uniform float voxel_size;
uniform float chunk_size;
uniform vec2 chunk_pos;

#define PI 3.14159265359
#define SAMPLES 64

int getVoxel(vec3 pos)
{
  vec3 p = pos - vec3(chunk_pos.x,0.0,chunk_pos.y);

  if (p.x > 0.0 && p.x < chunk_size && p.y > 0.0 && p.y < chunk_size && p.z > 0.0 && p.z < chunk_size)
  {
    vec2 uv = vec2(p.x, p.y + p.z * chunk_size) / chunk_size;
    if (Texel(chunk, uv).r == 1.0) return 1;
  }

  return 0;
}

vec3 castRay(vec3 pos, vec3 dir)
{
  vec3 col = vec3(0.0);

  for (int i = 0; i < SAMPLES; i++)
  {
    vec3 p = floor(pos + dir * i);

    if (getVoxel(p) == 1)
    {
      col = vec3(i / 64.0);
      break;
    }
  }

  return col;
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );

  return mat3( cu, cv, cw );
}

vec4 effect(vec4 color, sampler2D tex, vec2 tex_coords, vec2 screen_coords)
{
  vec2 fragCoord = vec2(screen_coords.x, love_ScreenSize.y - screen_coords.y);
  vec2 p = (-love_ScreenSize.xy + 2.0*fragCoord)/love_ScreenSize.y;

  vec3 ro = cam_pos;
	vec3 ta = cam_pos + cam_dir;

	// camera-to-world matrix
	mat3 ca = setCamera(ro, ta, 0.0);

  // ray direction
  vec3 rd = ca * normalize(vec3(p.xy,2.0));

  vec3 col = castRay(ro, rd);
  return vec4(col, 1.0);
}
