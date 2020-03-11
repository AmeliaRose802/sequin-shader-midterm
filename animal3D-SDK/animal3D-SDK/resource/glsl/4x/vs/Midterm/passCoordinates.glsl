#version 410

// ****TO-DO: 
//	1) declare uniform variable for MVP matrix; see demo code for hint
//	2) correctly transform input position by MVP matrix
//	3) declare texture coordinate attribute; see graphics library for location
//	4) declare atlas transform; see demo code for hint
//	5) declare texture coordinate outbound varying
//	6) correctly transform input texture coordinate by atlas matrix

layout (location = 0) in vec4 aPosition;
layout (location = 8) in vec4 aTexCoord;

uniform mat4 uMVP;

uniform mat4 uAtlas; 

out vec4 coord;
out vec4 fragPos;

void main()
{
	coord = uAtlas *  aTexCoord;
	gl_Position = uMVP * aPosition;
}
