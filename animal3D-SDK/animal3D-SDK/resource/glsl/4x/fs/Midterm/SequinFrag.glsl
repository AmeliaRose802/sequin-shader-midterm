#version 410


uniform sampler2D uImage0;
uniform vec4 uAColor;
uniform vec4 uBColor;
uniform float uSequinRadius;
uniform float uASpecular;
uniform float uBSpecular;
uniform vec4 uLightCol;


out vec4 rtFragColor;
in vec4 coord;

vec2 numSequines = vec2(24.0, 24.0);

vec2 getCenterOffset(){
    return (1.0 / (numSequines * 2.0));
}

vec2 getRemappedCenter(vec2 currentUV){
    vec2 newUV = currentUV * numSequines; //.6 becomes 1.2 
    newUV = ceil(newUV); // 1.2 becomes 2
    newUV = newUV / numSequines; // 2 becomes 1
   
    /*
    //Get every other row of sequines 
    float test = newUV.y * numSequines.y;
    if(mod(test, 2.0) != 0.0 ){
        
        //On the second row of sequines
        sequineColor = vec4(0.0, 0.0, 1.0, 1.0);
        
        //Bucket the output for the second row. 
        //.4 becomes . 75 
        //.6 becomes .75 
        //1.2 becomes 1.25
        //.8 becomes 1.25
        float k = 1.0 / (numSequines.x * 2.0);
        float offsetX = (ceil((newUV.x + k) * numSequines.x) / numSequines.x) - k;
        
        
        newUV.x = offsetX;
    }*/
    
    
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
}