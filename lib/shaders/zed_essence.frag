#version 110

#include "pixelated_coordinate.function"

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

void main()
{
  gl_FragColor = texture2D(in_Texture, pixelated_coordinate(var_TexCoord)) * var_Color;
}