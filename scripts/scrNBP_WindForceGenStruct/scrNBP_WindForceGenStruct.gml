/// @func	WindForceGen(fx, fy);
///	@param	{real}	fx	The wind x-strength.
///	@param	{real}	fy	The wind y-strength.
///	@desc	A force generator representing wind.
function WindForceGen(_fx=1, _fy=0) : ForceGen() constructor
{
	name = "wind";
	
	// Gravity vector
	windForce = new Vector2(_fx, _fy);
	windStrength = windForce.magnitude();
	calibrationFactor = 4;
	
	///	@func	updateForce(rigidBody, dt);
	///	@param	{Struct.RigidBody}	rigidBody	The rigid body the force is being applied to.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Applies the force to the body. Should be overwritten.
	static updateForce = function(_rb, _dt)
	{
		// Calculate wind drag coefficients
		var _w = nbpGetWidth(_rb), _h = nbpGetHeight(_rb);
		var _wc = calibrationFactor / _w, _hc = calibrationFactor / _h;
		
		// Apply wind
		nbpAddForce(_rb, windForce.x * _h * _wc, windForce.y * _w * _hc);
	}
	
	///	@func	setWindDir(dx, dy);
	///	@param	{real}	dx	The wind's x direction.
	///	@param	{real}	dy	The wind's y direction.
	///	@desc	Set the wind direction, keeping the same speed.
	static setWindDir = function(_dx, _dy)
	{
		windForce.setScaled(_dx, _dy, windStrength);
	}
	
	///	@func	setWindStrength(windStrength);
	///	@param	{real}	windStrength	The wind's strength.
	///	@desc	Set the wind strength, keeping the same direction.
	static setWindStrength = function(_windStrength)
	{
		windStrength = _windStrength;
		windForce.setScaled(windForce.x, windForce.y, windStrength);
	}
}