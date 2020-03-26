#version 410


// Uniforms
uniform sampler2D uImage02;
uniform sampler2D uImage03;
uniform vec4 uAColor;
uniform vec4 uBColor;
uniform vec2 uSequinNum; 


//Lighting
uniform vec4 uLightPos [4];
uniform vec4 uLightCol [4];
uniform float uLightSz [4];
uniform float uLightSzInvSq [4];
uniform int uLightCt;
uniform double uTime;

//Passed from Vertex shader
in vec4 viewPos;
in vec4 transformedNormal;
in vec4 coord;

out vec4 rtFragColor;


//Setting varibles 
//TODO: These should all be uniforms
vec2 numSequines = vec2(50.0, 50.0); //How many sequines should be on each surface
float ambent = .4; //How much ambent light 
float specularStrength = 4.0; //Higher value means brighter specularity 
float specularSpreadModifier = .3; //Lower value is more spread
float attenConst = 0; //How much should light decrease over distance 
float sequineConcavity = 1.5;
float sequineSizeModifier = 1.0;
float normalMapStrength = .8;


//Get defuse light for the given object
vec4 getLight(vec4 lightCol, vec4 lightPos, float lightSize, vec4 normal)
{
	vec4 lightRay = lightPos - viewPos;

	vec4 n_lightRay = normalize(lightRay);

	//Implementing Attenuaton
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	float diff_coef = max(dot(normalize(normal), n_lightRay), 0.0);

	//Light size seems to be in the range of 0 to 100, but it is more useful as a number between 0 and 1
	vec4 result = diff_coef * lightCol * (lightSize/100) * atten;
	
	return result;
}

//Get the specular coeffent
float getSpecular(vec4 lightPos, float exponenet, vec2 center, vec4 normal)
{
   
	vec4 viewerDir_normalized = normalize(viewPos);
    
	//Implementing Attenuaton
	vec4 lightRay = lightPos - viewPos;

     vec4 n_lightRay = normalize(lightRay);

     vec4 reflectDir = reflect(-n_lightRay, normalize(normal));

	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	return pow(max(dot(viewerDir_normalized, reflectDir), 0.0), exponenet);
}

//Remap the UV to find the center of the circle that this coordnate is in 
vec2 getRemappedCenter(vec2 currentUV){

    //Remap x and y 
    float newY = currentUV.y * numSequines.y;
    newY = ceil(newY);
    newY = newY / numSequines.y;
    
    float newX = currentUV.x * numSequines.x;
    newX = ceil(newX);
    newX = newX / numSequines.x;
    
    
    //Get every other row of sequines 
    float test = newY * numSequines.y;
    float tester = step(mod(test, 2.0), 0.0);
    
    float k = 1.0 / (numSequines.x * 2.0);
    float offsetX = (ceil((currentUV.x + k) * numSequines.x) / numSequines.x) - k;
    newX = (offsetX * tester) + (newX * abs(1-tester));
    

    //Offset the corner position to find the center of this circle
    vec2 offset = (1.0 / (numSequines * 2.0));

    return vec2(newX, newY) - offset;
}

vec2 remapCoordToCircle(vec2 uv, vec2 center, float radius){
    vec2 lowCorner = center - radius;
    return (uv - lowCorner) * numSequines; 
}


void main()
{
    vec2 uv = coord.xy;
    
    //Find center of the circle that this pixel falls into
    vec2 center = getRemappedCenter(uv);
    
    //Get size of each sequine
	float radius = ((1.0 / numSequines.x) / 2.0) * sequineSizeModifier;
   
 
    //This normal map adds variation to the angles of each sequine
    vec4 normalMap = ((texture(uImage02, center) * 2) - 1);

    
    float side =  step(normalMap.z, .2);
    vec4 objectColor = uAColor;

    //Color the sequine diffrently based on weather it is on the A or B side
    objectColor = uAColor * side + uBColor* (1- side);
   
    //Map concave normal to size of sequine
    vec2 relCoord = remapCoordToCircle(uv, center, radius);

    //This normal adds concavity to the normals of each indivual sequine
    vec4 concaveNormal = ((texture(uImage03, relCoord.xy) * 2) - 1);

    //Modify the concavity (z value) of each indivual sequine. Negivitve values make it concave, positive convex
    concaveNormal.z *= sequineConcavity;
    
    //Modify the normal for this pixel based on the normal maps. 
    vec4 newNormal = transformedNormal +  concaveNormal + normalMap * normalMapStrength;
    
    //Calculate Lighting
 	vec4 allDefuse;	
	vec4 allSpecular;	

    //Get the sum of defuse and specular for all lights
	for(int i = 0; i < uLightCt; i++)
	{
		allDefuse += getLight(uLightCol[i], uLightPos[i], uLightSz[i], newNormal);
		allSpecular += getSpecular(uLightPos[i], uLightSz[i] * specularSpreadModifier , center, newNormal);
	}

	//Check if this pixel is within the circle
    float checker = step(length(uv-center), radius);
	
	
	//Add together all types of light for phong 
	rtFragColor = vec4(((ambent + allDefuse + allSpecular * specularStrength) * objectColor * checker).xyz, 1.0);

   // rtFragColor = allSpecular * specularStrength * checker;
}