#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

float2 FlowUV (float2 uv, float2 flowVector, float time) {
	// old sampling coord:  uv-time, i.e. translation
	// new: uv disturbed a little bit around the old coordinate.
	float progress = frac(time);  // to reset the distortion when disturb value greater than 1
	return uv - flowVector * time * progress;  // disturb [0,1]	
}

// interpolate the uv with some value, to fade out the unnatrual effect a bit.
float3 FlowUVW (float2 uv, float2 flowVector, float time) {
	float progress = frac(time);
	float3 uvw;
	uvw.xy = uv - flowVector * progress;
	uvw.z = 1 - abs(1 - 2 * progress);	// weight
	return uvw;
}

// use the bool flag to control the patter's time offset.
// This function use a threshold to generate two different patterns, and later we can blend them together, 
// to create a more natrual flow effect.
float3 FlowUVW (float2 uv, float2 flowVector, float time, bool flowB) {
	float phaseOffset = flowB ? 0.5 : 0;
	float progress = frac(time + phaseOffset);
	float3 uvw;
	uvw.xy = uv - flowVector * progress + phaseOffset;
	uvw.z = 1 - abs(1 - 2 * progress);
	return uvw;
}

// use jump to control the texture changing period, instead of using time directly control it.
float3 FlowUVW (float2 uv, float2 flowVector, float2 jump, float time, bool flowB) {
	float phaseOffset = flowB ? 0.5 : 0;
	float progress = frac(time + phaseOffset);
	float3 uvw;
	uvw.xy = uv - flowVector * progress + phaseOffset;
	uvw.xy += (time - progress) * jump;
	uvw.z = 1 - abs(1 - 2 * progress);
	return uvw;
}

#endif