#version 410


// uniform sampler2D uImage0;
uniform sampler2D uImage02;
uniform vec4 uAColor;
uniform vec4 uBColor;
uniform vec2 uSequinNum; //This does not work for reasons I can't be assed to figure out right now so I'm using a constant instead
uniform float uASpecular;
uniform float uBSpecular;

uniform vec4 uLightPos [4];
uniform vec4 uLightCol [4];
uniform float uLightSz [4];
uniform float uLightSzInvSq [4];
uniform double uTime;

uniform int uLightCt;

in vec4 texCoord;
in vec4 viewPos;
in vec4 transformedNormal;

out vec4 rtFragColor;

vec4 n_lightRay;


layout (location = 1) out vec4 outColor;
layout (location = 2) out vec4 outNormal;

in vec4 coord;

vec2 numSequines = vec2(30.0, 30.0);
float sequinSize = 50.0; //TODO: This should be a uniform


float ambent = .3;
float specularStrength = 5.0;

float attenConst = .001;

//Get defuse light for the given object
vec4 getLight(vec4 lightCol, vec4 lightPos, float lightSize)
{
	//This only works when you use the viewPos as the position. I have no idea why
	vec4 lightRay = lightPos - viewPos;

	n_lightRay = normalize(lightRay);

	//Implementing Attenuaton
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	float diff_coef = max(dot(normalize(transformedNormal), n_lightRay), 0.0);

	//Light size seems to be in the range of 0 to 100, but it is more useful as a number between 0 and 1
	vec4 result = diff_coef * lightCol * (lightSize/100) * atten;
	
	return result;
}

//Get the specular coeffent
float getSpecular(vec4 lightPos, float exponenet, vec2 center)
{

	vec4 viewerDir_normalized = normalize(viewPos);

	//Leaving this here to show how the math works
	//vec4 reflectDir = 2 * (dot(normalize(transformedNormal), n_lightRay)) * normalize(transformedNormal) - n_lightRay;

   // vec4 temp = transformedNormal + clamp(sin(float(uTime )), 0,.2) ;
   vec4 normalMap = ((texture(uImage02, center) * 2) - 1);
   normalMap.z *= .4;
    vec4 temp = transformedNormal + normalMap;
	vec4 reflectDir = reflect(-n_lightRay, normalize(temp));

	//Implementing Attenuaton
	vec4 lightRay = lightPos - viewPos;
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);


	return pow(max(dot(viewerDir_normalized, reflectDir), 0.0), exponenet) * atten;
}



vec2 getCenterOffset(){
    return (1.0 / (numSequines * 2.0));
}

vec2 getRemappedCenter(vec2 currentUV){
    currentUV.y += .005;
    //Bucket y 
    float newY = currentUV.y * numSequines.y;
    newY = ceil(newY);
    newY = newY / numSequines.y;
    
    float newX = currentUV.x * numSequines.x;
    newX = ceil(newX);
    newX = newX / numSequines.x;
    
    
    //Get every other row of sequines 
    float test = newY * numSequines.y;
    if(mod(test, 2.0) != 0.0 ){
        float k = 1.0 / (numSequines.x * 2.0);
        float offsetX = (ceil((currentUV.x + k) * numSequines.x) / numSequines.x) - k;
        newX = offsetX;
    }
    
    
    return vec2(newX, newY) - getCenterOffset();
}



void main()
{
	
	// Normalized pixel coordinates (from 0 to 1)
    vec2 uv = coord.xy;
    
    vec2 center = getRemappedCenter(uv);

   // numSequines = (vec2(textureSize(uImage0)) / sequinSize); //Define number of sequines based on the size of the screen so they will be consistantly

	float radius = ((1.0 / numSequines.x) / 2.0) * 1.05;
    
   
    float checker = step(length(uv-center), radius);
 

 
 	vec4 allDefuse;	
	vec4 allSpecular;	

	
	//Get the sum of defuse and specular for all lights
	for(int i = 0; i < uLightCt; i++)
	{
		allDefuse += getLight(uLightCol[i], uLightPos[i], uLightSz[i]);
		allSpecular += getSpecular(uLightPos[i], uLightSz[i]*.4, center);
	}


    vec4 objectColor = vec4(center * checker, 0.0, 1.0);
	
	//Add together all types of light for phong 
	rtFragColor = vec4(((ambent + allDefuse + specularStrength * allSpecular) * objectColor).xyz, 1.0);
   // rtFragColor = objectColor;
    outColor = rtFragColor;
}