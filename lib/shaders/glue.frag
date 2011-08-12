#version 110

#include "snoise.function"
#include "pixelated_coordinate.function"

uniform vec2 offset; // Offset of the texture from the overall texture.
uniform float interference_amplitude; // Importance of interference.

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

// -----------------------------------

void main()
{
  vec2 coord1 = pixelated_coordinate(var_TexCoord + offset);

  // interference larger # means less
  float interference1 = snoise(coord1);

  float c1 = abs(cos(interference1 * interference_amplitude));

  vec4 color = texture2D(in_Texture, var_TexCoord);
  float brightness = 0.95 + 0.05 * c1;
  gl_FragColor = vec4(brightness, brightness, brightness, color.a);
}