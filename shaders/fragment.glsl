uniform sampler3D chunk;
uniform vec3 cam_pos;
uniform vec3 cam_dir;
uniform float fov;
uniform float voxel_size;
uniform float chunk_size;
uniform vec2 chunk_pos;

#define PI 3.14159265359
#define SAMPLES 128

vec3 l_dir = normalize(vec3(1.0,1.0,-1.0));

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

vec2 map(vec3 pos)
{
  vec3 cp = vec3(chunk_pos.x/2.0, 0.0, chunk_pos.y);
  vec2 res = vec2(0.01,-1.0);

  vec3 vox_pos = (pos - cp * voxel_size) / voxel_size;
  vec3 uv = floor(vec3(vox_pos.x, vox_pos.y, vox_pos.z)) / chunk_size;

  if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)
  {
    float r = (Texel(chunk, uv).r * 255.0);
    if (r > 0.0)
    {
      res = vec2(sdBox(vox_pos, vec3(0.5)),r);
    }
  }

  return res;
}

float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
  float t = mint;
  for( int i=0; i<64; i++ )
  {
		float h = map( ro + rd*t ).x;
    res = min( res, 8.0*h/t );
    t += clamp( h, 0.02, 0.10 );
    if( h<0.001 || t>tmax ) break;
  }
  return clamp( res, 0.0, 1.0 );
}

vec4 castRay(vec3 pos, vec3 dir)
{
  vec4 col = vec4(0.0);

  float t = 0.02;

  for (int i=0; i < SAMPLES; i++)
  {
    vec3 p = pos + dir * t;

    vec2 res = map(p);

    if (res.x < t * 0.0005 && res.y != -1.0)
    {
      col = vec4(res.y/255.0,0.0,0.0,1.0);
      col.rgb *= softshadow(p, l_dir, 0.02, 512.0);
      return col;
    }

    t += min(res.x, 1.0);
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

  vec4 col = castRay(ro, normalize(rd));
  return col;
}
