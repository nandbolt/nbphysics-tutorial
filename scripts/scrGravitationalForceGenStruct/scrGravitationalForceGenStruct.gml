/// @func	GravitationalForceGen();
///	@desc	Simulates the gravitational force (F=G(m1*m2)/r^2).
function GravitationalForceGen(_rb, _g=1) : ForceGen() constructor
{
	name = "grav force gen";
	
	rb = _rb;
	g = _g;
	
	///	@func	updateForce(rb, dt);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Applies the force to the body. Should be overwritten.
	static updateForce = function(_rb, _dt)
	{
		// Return if any of the rigid bodies have infinite mass
		if (rb.inverseMass == 0 || _rb.inverseMass == 0) return;
		
		// Init force
		var _force = new Vector2(rb.x - _rb.x, rb.y - _rb.y);
		var _r = _force.magnitude();
		_force.normalize();
		var _m1 = nbpGetMass(rb), _m2 = nbpGetMass(_rb);
		
		// Calculate force magnitude
		var _forceStrength = g * (_m1 * _m2) / (_r * _r);
		_force.scale(_forceStrength);
		
		// Apply final force
		nbpAddForceVector(_rb, _force);
	}
}