Shader "Unlit/VertexShaderOverview"
{
    Properties
    {
        // This is a Unity Specific shader scope where you can define properties that are going to be displayed in the inspector
        [KeywordEnum(NORMAL, UV, POSITION, WORLD_POSITION, WORLD_NORMAL)] _VisualizeMode("Visualize Mode", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Compilation directive for vertex shader
            #pragma fragment frag // Compilation directive for fragment shader
            
            #include "UnityCG.cginc"
            
            // Define input data received by the Vertex Shader
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            // Vertex To Fragment struct. Define output data for the Vertex Shader. This data is sent to the Fragment Shader after Rasterization
            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
            };

            // You have to define variable in the shader pass too
            float _VisualizeMode;
            
            v2f vert (appdata v)
            {
                // We have to fill all the data of the output structure v2f to send it to the fragment shader
                v2f o;
                // Unity provide a lot of useful functions to transform data from one space to another

                // Transform vertex position from object space to clip space
                // This is a mendatory step to get the vertex position in screen space to feed the fragment shader
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Transform vertex position from object space to world space to get the world space position of a
                // pixel in the fragment shader
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                o.normal = v.normal;
                // Convert normal from object space to world space
                // Note that the normal is a direction. So we have the "0" component to keep the vector homogeneous
                // For a position we use a one for the "w" component
                o.worldNormal = mul(unity_ObjectToWorld, float4(v.normal, 0)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 color = float3(0, 0, 0);
                // Switch beetwen the different visualization mode
                if(_VisualizeMode == 0)
                {
                    color = i.normal;
                }
                else if(_VisualizeMode == 1)
                {
                    color = float3(i.uv, 0);
                }
                else if(_VisualizeMode == 2)
                {
                    // Divide by screen size to get normalized coordinates so we could vizualize it
                    float2 pos = i.vertex.xy / _ScreenParams.xy; 
                    color.xy = pos;
                }
                else if(_VisualizeMode == 3)
                {
                    color = i.worldPos;
                }
                else if(_VisualizeMode == 4)
                {
                    color = i.worldNormal;
                }
                // Output the color
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
