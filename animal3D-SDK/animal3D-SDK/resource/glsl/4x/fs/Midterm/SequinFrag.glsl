#version 410


uniform sampler2D uImage0;

out vec4 rtFragColor;
in vec4 coord;
in vec4 passTexcoord;

void main()
{
	
	rtFragColor = passTexcoord;
}