#define REGISTER(type, slot) register(type##slot)

#pragma pack_matrix(row_major)

struct VxgiFullScreenQuadOutput
{
    float2 uv : TEXCOORD;
    float4 posProj : RAY;
    float instanceID : INSTANCEID;
};

void main(VxgiFullScreenQuadOutput quadIn, in float4 gl_FragCoord : SV_Position, out float4 o_colorX : SV_Target0, out float4 o_colorY : SV_Target1, out float4 o_colorZ : SV_Target2)
{
    o_colorX = float4(0.0, 0.0, 0.0, 0.0);
    o_colorY = float4(0.0, 0.0, 0.0, 0.0);
    o_colorZ = float4(0.0, 0.0, 0.0, 0.0);
}
