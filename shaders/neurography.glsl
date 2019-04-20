precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define M_PI 3.1415926535897932384626433832795




float my_line(vec2 p0, vec2 p1, vec2 q) {
   vec2 p0p1 = p1 - p0;
   float d = distance(p1, p0);
   vec2 v = p0p1 / d;
   float cosT = v.x;
   float sinT = v.y;
   mat2 R = mat2(cosT, -sinT, sinT, cosT);

   vec2 dq = R * (q - p0) / d;

   return 1.0 / dq.y * (atan((1.0-dq.x)/dq.y ) - atan(-dq.x/dq.y)) / d;
}


float line_seg_min_dist_sqr(vec2 v, vec2 w, vec2 p) {
  // Return minimum distance between line segment vw and point p
  vec2 vw = w - v;
  vec2 vp = p - v;
  float l2 = dot(vw, vw);  // i.e. |w-v|^2 -  avoid a sqrt
  if (l2 == 0.0) return dot(vp, vp);   // v == w case
  // Consider the line extending the segment, parameterized as v + t (w - v).
  // We find projection of point p onto the line. 
  // It falls where t = [(p-v) . (w-v)] / |w-v|^2
  // We clamp t from [0,1] to handle points outside the segment vw.
  float t = max(0.0, min(1.0, dot(vp, vw) / l2));
  vec2 projection = v + t * (vw);  // Projection falls on the segment
  vec2 d = p - projection;
  return dot(d, d);
}

vec2 curve(float t) {
   return vec2(0.1 + t, sin(t*6.0*M_PI + u_time) * 0.33 + 0.5);
}
float zoom = 2.0;
void main() {
   vec2 center = vec2(0.5,0.5);
   vec2 q = gl_FragCoord.xy / u_resolution.xy;
   q.x *= u_resolution.x / u_resolution.y;
   vec2 mouse = u_mouse / u_resolution.xy;
   mouse.x *= u_resolution.x / u_resolution.y;
   // q *= zoom;

   vec3 color = vec3(1.0);

   float val = 0.0;// my_line(center, mouse, q);
   const int n = 50;
   const float dt = 1.0 / float(n) *0.5;

   for(int i = 0; i < n; i++) {
      // vec2 p1 = vec2(float(i)*0.05, sin(u_time) * 0.5 + 0.5);
      // vec2 p2 = vec2(0.5, float(i)*0.05);
      float t1 = dt * float(i);
      float t2 = dt * float(i + 1);
      vec2 p1 = curve(t1);
      vec2 p2 = curve(t2);
      if(line_seg_min_dist_sqr(p1, p2, q) < 0.01) {
         val +=  my_line(p1, p2, q);
      }

      p1 = vec2(p1.y, p1.x);
      p2 = vec2(p2.y, p2.x);
      if(line_seg_min_dist_sqr(p1, p2, q) < 0.01) {
         val +=  my_line(p1, p2, q);
      }

   }
   float cutoff = 500.0;
   float smoothness = 20.0;
   color = vec3(smoothstep(cutoff, cutoff-smoothness, val));
   // color = vec3(my_line(q) / 1000.0);
   
   // color = vec3(st.x, st.y, abs(sin(u_time)));

   gl_FragColor = vec4(color, 1.0);
}