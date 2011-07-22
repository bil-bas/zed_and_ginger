#version 130

uniform vec2 offset; // Offset of the texture from the overall texture.
uniform float time; // Current time
uniform float pixel_width; // = Image width / num pixels
uniform float pixel_height; // = Image width / num pixels
uniform float interference_amplitude; // Importance of interference.
uniform float frequency_amplitude; // Importance of frequency.

// Automatically set by Ray (actually passed from the vertex shader).
// uniform sampler2D in_Texture; // Original texture.
in vec2 var_TexCoord; // Pixel to process on this pass
in vec4 var_Color;
out vec4 var_FragColor;

// -----------------------------------
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110410 (stegu)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//

vec3 permute(vec3 x)
{
  return mod(((x*34.0)+1.0)*x, 289.0);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod(i, 289.0); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Inlined for speed: m *= taylorInvSqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// -----------------------------------

// Returns the position of this pixel, assuming it was pixelated.
vec2 pixelated_coordinate(vec2 coord)
{
  return vec2(pixel_width * floor(coord.x / pixel_width),
              pixel_height * floor(coord.y / pixel_height));
}

void main()
{
  vec2 coord1 = pixelated_coordinate(var_TexCoord + offset);
  vec2 coord2 = pixelated_coordinate(var_TexCoord + offset + vec2(50, 50));

  // frequency larger # means less
  float frequency1 = abs(cos(coord1.y + time));
  float frequency2 = abs(cos(coord2.x + time));

  // inteference larger # means less
  float interference1 = snoise(coord1);
  float interference2 = snoise(coord2);

  float c1 = abs(cos(frequency1 * frequency_amplitude + interference1 * interference_amplitude));
  float c2 = abs(cos(frequency2 * frequency_amplitude + interference2 * interference_amplitude));

  var_FragColor = vec4(0, 0.4 + (0.2 * c1) + (0.2 * c2) , 0, var_Color.a);
}