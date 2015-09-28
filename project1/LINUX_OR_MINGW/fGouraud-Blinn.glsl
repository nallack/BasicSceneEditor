#version 150

in  vec4 color;
in  vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

in vec4 fPosition;

out vec4 fColor;

uniform float texScale;
uniform sampler2D texture;

void main()
{
  fColor = color * texture2D( texture, texCoord * texScale );
  //fColor = 0.1f * vec4(fPosition.zzz, 1);
}