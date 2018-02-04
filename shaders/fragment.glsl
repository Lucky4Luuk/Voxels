uniform sampler2D chunk;
uniform vec3 cam_pos;
uniform vec3 cam_dir;
uniform float fov;
uniform float voxel_size;
uniform float chunk_size;
uniform vec2 chunk_pos;

#define PI 3.14159265359
#define SAMPLES 64

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdPlane(vec3 p)
{
  return p.y;
}

vec2 opU(vec2 a, vec2 b)
{
  if (a.x < b.x) return a;
  return b;
}

float map(vec3 pos)
{
  vec3 p = pos - vec3(chunk_pos.x, 0.0, chunk_pos.y);
  vec2 uv = floor(vec2(p.x, (p.y + p.z*chunk_size)/chunk_size))/chunk_size;
  if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0 && Texel(chunk, uv).r == 1.0)
  {
    return sdBox(floor(p/voxel_size), vec3(0.5));
  }
  return 1.0;

  /*
  vec3 p = (pos - vec3(chunk_pos.x, 0.0, chunk_pos.y));

  vec2 uv = vec2(p.x, p.y + p.z * chunk_size) / chunk_size;

  float res = 0.0;

  if (uv.x >= 0 && uv.x <= 1.0 && uv.y >= 0 && uv.y <= 1.0)
  {
    res = Texel(chunk, uv).r;
  }
  return res;
  */
}

vec4 castRay(vec3 pos, vec3 dir)
{
  vec4 col = vec4(0.0);

  float t = 0.02;

  for (int i=0; i < SAMPLES; i++)
  {
    vec3 p = pos + dir * t;

    float res = map(floor(p));

    if (res < 0.005) return vec4(vec3(1.0,0.0,0.0),1.0);

    t += res;
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

  vec4 col = castRay(ro, rd);
  return col;
}
