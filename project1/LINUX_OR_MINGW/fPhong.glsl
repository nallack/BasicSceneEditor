#version 150

const int MAX_LIGHTS = 3;

in vec3 fPositionMV;
in vec3 fNormalMV;
in vec2 fTexCoord;

out vec4 color;

//camera
uniform vec4 Origin; //faster than multiplying an inversetranspose

//light * material (viewspace)
uniform int LightType[MAX_LIGHTS];
uniform vec4 LightPosition[MAX_LIGHTS];
uniform vec4 LightDirection[MAX_LIGHTS];
uniform vec3 SpotLightVars[MAX_LIGHTS]; //phi theta falloff

uniform vec3 AmbientProduct;
uniform vec3 DiffuseProduct[MAX_LIGHTS], SpecularProduct[MAX_LIGHTS];

//material
uniform float Shininess;

uniform sampler2D texture;

void main()
{
	// Compute terms in the illumination equation
    vec3 ambient = AmbientProduct;
	vec3 diffuse = vec3(0, 0, 0);
	vec3 specular = vec3(0, 0, 0);
	
	vec3 N = normalize(fNormalMV);
	vec3 E = normalize(-fPositionMV);	// Direction to the eye/camera
	
	for(int i = 0; i < MAX_LIGHTS; i++) {
		 
		//Directional Light
        if(LightType[i] == 0) {
            vec3 Lvec = (LightPosition[i] - Origin).xyz;	// The vector to the light from the vertex   
			//vec3 Lvec = LightDirection[i].xyz; //Spotlight direction
			
			vec3 L = normalize(Lvec);			// Direction to the light source
			vec3 R = reflect(-L, N);			//Perfect reflector

			float Kd = max( dot(L, N), 0.0 );
			diffuse += Kd * DiffuseProduct[i];

			float Ks = pow( max(dot(R, E), 0.0), Shininess );
			specular += Ks * SpecularProduct[i];
        }
		//Point Light
        else if(LightType[i] == 1) {
			// The vector to the light from the vertex   
			vec3 Lvec = LightPosition[i].xyz - fPositionMV;
		
			vec3 L = normalize(Lvec);			// Direction to the light source
			vec3 R = reflect(-L, N);			//Perfect reflector

			//reduce intensity with distance from light
			float dist = length(Lvec) + 1.0f;
			float attenuation = 1.0f / dist / dist;

			float Kd = max( dot(L, N), 0.0 ) * attenuation;
			diffuse += Kd * DiffuseProduct[i];

			float Ks = pow( max(dot(R, E), 0.0), Shininess ) * attenuation;
			specular += Ks * SpecularProduct[i];
        }
		//Spot Light
        else if(LightType[i] == 2) {
			// The vector to the light from the vertex   
			vec3 Lvec = LightPosition[i].xyz - fPositionMV;
			
			vec3 L = normalize(Lvec);			// Direction to the light source
			vec3 R = reflect(-L, N);			//Perfect reflector
			
			//angle between the spotlight centre and the fragment being shaded.
			float coneAngle = acos(dot(L, normalize(LightDirection[i].xyz)));
				
			if(coneAngle < SpotLightVars[i].x) {
				
				float illumination;
				if(coneAngle < SpotLightVars[i].y) illumination = 1;
				else {
					illumination =  pow((SpotLightVars[i].x - coneAngle) /
									(SpotLightVars[i].x - SpotLightVars[i].y),
									SpotLightVars[i].z);
				}
				
				float dist = length(Lvec) + 1.0f;
				float attenuation = illumination / dist / dist;

				float Kd = max( dot(L, N), 0.0 ) * attenuation;
				diffuse += Kd * DiffuseProduct[i];

				float Ks = pow( max(dot(R, E), 0.0), Shininess ) * attenuation;
				specular += Ks * SpecularProduct[i];
			}
        }
	}
	
	color = texture2D(texture, fTexCoord) * vec4((ambient + diffuse), 1) + vec4(specular, 0);
}