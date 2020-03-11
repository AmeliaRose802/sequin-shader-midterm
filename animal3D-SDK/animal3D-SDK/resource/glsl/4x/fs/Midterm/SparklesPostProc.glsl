#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

// outlining article with some alternate ways (to used): https://gamedev.stackexchange.com/questions/68401/how-can-i-draw-outlines-around-3d-models

//TODO: Now this is a post processing shader the uniforms are no longer getting passed in correctly
uniform vec4 uAColor;
uniform vec4 uBColor;
uniform vec2 uSequinNum; //This does not work for reasons I can't be assed to figure out right now so I'm using a constant instead
uniform float uASpecular;
uniform float uBSpecular;
uniform vec4 uLightCol;
																								//original code taken from: https://gist.github.com/Hebali/6ebfc66106459aacee6a9fac029d0115

uniform sampler2D uImage0; //Base/composite texture
uniform sampler2D uImage1; //Base object shapes (?)
uniform sampler2D uImage2; 
uniform sampler2D uImage3; 
uniform sampler2D uImage4; 
uniform sampler2D uImage5; 
uniform sampler2D uImage6;  
uniform sampler2D uImage7; //Earth map texture

//Output of the previous shader
uniform sampler2D screenTexture;

//Stuff we already have
layout (location = 0) out vec4 rtFragColor;
layout (location = 3) out vec4 texCoord;
in vec4 coord;

vec4 aColor = vec4(0.7, 0.0, 1.0, 1.0); //Temp until uniforms start working here

void main(void) 
{
	//getiing the on-screen image
	vec4 center = texture(screenTexture, coord.xy);

	float tester = 0.0;
	if(length(center.xy) > 0.0){
		tester = 1.0;
	}

	rtFragColor = aColor * tester;
}