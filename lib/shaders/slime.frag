#version 110

#include "snoise.function"
#include "pixelated_coordinate.function"

uniform vec2 offset; // Offset of the texture from the overall texture.
uniform float time; // Current time
uniform float interference_amplitude; // Importance of interference.
uniform float frequency_amplitude; // Importance of frequency.

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;
//out vec4 out_FragColor;

// -----------------------------------

void main()
{
  vec2 coord1 = pixelated_coordinate(var_TexCoord + offset);
  vec2 coord2 = pixelated_coordinate(var_TexCoord + offset + vec2(50, 50));

  // frequency larger # means less
  float frequency1 = abs(cos(coord1.y + time));
  float frequency2 = abs(cos(coord2.x + time * 1.7));

  // interference larger # means less
  float interference1 = snoise(coord1);
  float interference2 = snoise(coord2);

  float c1 = abs(cos(frequency1 * frequency_amplitude + interference1 * interference_amplitude));
  float c2 = abs(cos(frequency2 * frequency_amplitude + interference2 * interference_amplitude));

  vec4 color = texture2D(in_Texture, var_TexCoord);
  gl_FragColor = vec4(color.r, (color.g * 0.4) + (0.1 * c1) + (0.1 * c2) , color.b, color.a);
}