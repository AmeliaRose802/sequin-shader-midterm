/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

// outlining article with some alternate ways (to used): https://gamedev.stackexchange.com/questions/68401/how-can-i-draw-outlines-around-3d-models

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
in vec4 passTexcoord;

																								// Sobel Edge Detection Filter
																								// GLSL Fragment Shader
																								// Original Implementation by Patrick Hebron
																								// Modified by David Bakaleinik

//Function that creates a 3x3 kernel (stored in an array), through sampling of 9 screen regions
void make_kernel(inout vec4 kernel_array[9], sampler2D image, vec2 coordinate)
{
//Calculating the dimentions of the input texture
	float width = 1.0 / textureSize(image, 0).x;
	float height = 1.0 / textureSize(image, 0).y;

	//populating the array through repeated sampling of the given sampler2D texture, offset by the dimentions of the texture
	kernel_array[0] = texture2D(image, coordinate + vec2( -width, -height));
	kernel_array[1] = texture2D(image, coordinate + vec2(0.0, -height));
	kernel_array[2] = texture2D(image, coordinate + vec2(  width, -height));
	kernel_array[3] = texture2D(image, coordinate + vec2( -width, 0.0));
	kernel_array[4] = texture2D(image, coordinate);
	kernel_array[5] = texture2D(image, coordinate + vec2(  width, 0.0));
	kernel_array[6] = texture2D(image, coordinate + vec2( -width, height));
	kernel_array[7] = texture2D(image, coordinate + vec2(0.0, height));
	kernel_array[8] = texture2D(image, coordinate + vec2(  width, height));
}

void main(void) 
{
	vec4 kernel_array[9]; //Array of 9 vec4 - potentially represents a kernel
	make_kernel( kernel_array, uImage1, passTexcoord.xy );

	//creating the horizontal and vertical gradient maps
	vec4 sobel_edge_h = kernel_array[2] + (2.0*kernel_array[5]) + kernel_array[8] - (kernel_array[0] + (2.0*kernel_array[3]) + kernel_array[6]);
  	vec4 sobel_edge_v = kernel_array[0] + (2.0*kernel_array[1]) + kernel_array[2] - (kernel_array[6] + (2.0*kernel_array[7]) + kernel_array[8]);

	//combination of the horizonal and vertical gradients to produce the final result 
	vec4 sobel_final = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));

	//getiing the on-screen image
	vec4 screen_Sample = texture(screenTexture, passTexcoord.xy);

	float outlineThickness = 10.0f;

	//final output - sobel produces a black image with edges highlighted in white, so it is reversed by sburtracting sobel.rgb from 1
	//line thickness can be adjusted using a float
	//the vec4 is then multiplied by the existing image on the screen to apply the outlines
	rtFragColor = vec4( 1.0 - sobel_final.rgb * outlineThickness, 1.0 ) * screen_Sample;

}