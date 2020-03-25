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
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare additional texture uniforms
//	2) implement screen function with 4 inputs
//	3) use screen function to sample input textures

uniform sampler2D uImage00; // Bright/Blur 1/2
uniform sampler2D uImage01; // Bright/Blur 1/4
uniform sampler2D uImage02; // Bright/Blur 1/8
uniform sampler2D uImage03; //Composite 
uniform sampler2D uImage04; //Gray gradient thing
uniform sampler2D uImage05; // ???
uniform sampler2D uImage06; //Shadow map or smth 
uniform sampler2D uImage07; //Earth map texture


layout (location = 0) out vec4 rtFragColor;
in vec4 passTexcoord;

vec4 screen(sampler2D a, sampler2D b, sampler2D c, sampler2D d)
{
vec4 output_bight = vec4(0.0);

output_bight = 1 - (1 - texture(a, passTexcoord.xy))*(1 - texture(b, passTexcoord.xy))*(1-texture(c, passTexcoord.xy))*(1- texture(d, passTexcoord.xy));

return output_bight;
}

void main()
{
	rtFragColor = screen(uImage00, uImage01, uImage02, uImage03);
	//rtFragColor = texture(uImage02, passTexcoord.xy);
}