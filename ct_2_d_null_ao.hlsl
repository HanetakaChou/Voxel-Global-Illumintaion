#define REGISTER(type, slot) register(type##slot)

#pragma pack_matrix(row_major)

struct VxgiFullScreenQuadOutput
{
    float2 uv : TEXCOORD;
    float4 posProj : RAY;
    float instanceID : INSTANCEID;
};

void main(VxgiFullScreenQuadOutput quadIn, in float4 gl_FragCoord : SV_Position, out float4 o_color : SV_Target0)
{
    o_color = float4(0.0, 0.0, 0.0, 0.0);
}
