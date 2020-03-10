
#version 410


layout (location = 0) in vec4 aPosition;

out vec4 fragCoord;

void main()
{

fragCoord = aPosition;

}