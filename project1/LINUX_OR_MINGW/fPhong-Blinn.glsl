#version 150

in vec3 fPositionMV;
in vec3 fNormalMV;
in vec2 fTexCoord;

out vec4 color;

//light
//viewspace
uniform vec4 LightPosition;

//material
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform float Shininess;

uniform sampler2D texture;

void main()
{
	// The vector to the light from the vertex    
    vec3 Lvec = LightPosition.xyz - fPositionMV;
	
    // Unit direction vectors for Blinn-Phong shading calculation
	vec3 N = normalize(fNormalMV);
    vec3 L = normalize( Lvec );   		// Direction to the light source
    vec3 E = normalize( -fPositionMV ); // Direction to the eye/camera
    vec3 H = normalize( L + E ); 		// Halfway vector

    // Compute terms in the illumination equation
    vec3 ambient = AmbientProduct + vec3(0.1, 0.1, 0.1);

	//reduce intensity with distance from light
	float dist = length(Lvec);
	float attenuation = 1.0f / dist / dist;
	
    float Kd = max( dot(L, N), 0.0 ) * attenuation;
    vec3  diffuse = Kd * DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess ) * attenuation;
    vec3  specular = Ks * SpecularProduct;
	
	color = texture2D(texture, fTexCoord) * vec4((ambient + diffuse), 1) + vec4(specular, 1);
}