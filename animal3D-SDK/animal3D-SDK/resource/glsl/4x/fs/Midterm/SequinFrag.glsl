#version 410


uniform sampler2D uImage0;
uniform vec4 uAColor;
uniform vec4 uBColor;
uniform vec2 uSequinNum; //This does not work for reasons I can't be assed to figure out right now so I'm using a constant instead
uniform float uASpecular;
uniform float uBSpecular;
uniform vec4 uLightCol;


out vec4 rtFragColor;
layout (location = 0) out vec4 outColor;

in vec4 coord;

vec2 numSequines = vec2(35.0, 35.0);

vec2 getCenterOffset(){
    return (1.0 / (numSequines * 2.0));
}

vec2 getRemappedCenter(vec2 currentUV){
    vec2 newUV = currentUV * numSequines; //.6 becomes 1.2 
    newUV = ceil(newUV); // 1.2 becomes 2
    newUV = newUV / numSequines; // 2 becomes 1
    
    return newUV - getCenterOffset();
}



void main()
{
	
	// Normalized pixel coordinates (from 0 to 1)
    vec2 uv = coord.xy;
    
    vec2 center = getRemappedCenter(uv);
    
	float radius = ((1.0 / numSequines.x) / 2.0);
    
   
    float checker = step(length(uv-center), radius);
 
     // Output to screen
    rtFragColor = vec4(center * checker, 0.0, 1.0);
    outColor = rtFragColor;
}