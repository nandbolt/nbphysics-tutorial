/// @func	FakeSpringForceGen(anchor, k, damping);
///	@param	{Struct.Vector2}	anchor		The anchor position.
///	@param	{real}	k			The spring constant.
///	@param	{real}	damping		The rest length of the spring.
///	@desc	A force generator representing a fake, stiff spring (potentially useful
///			for collisions).
function FakeSpringForceGen(_anchor, _k=1, _damping=0) : ForceGen() constructor
{
	name = "fake spring";
	
	// Spring
	anchor = _anchor;
	k = _k;
	damping = _damping;
	
	///	@func	draw(rb);
	///	@desc	Draws the spring.
	static draw = function(_rb)
	{
		draw_set_color(c_fuchsia);
		draw_line(anchor.x, anchor.y, _rb.x, _rb.y);
		draw_set_color(c_white);
	}
	
	///	@func	updateForce(rigidBody, dt);
	///	@param	{Struct.RigidBody}	rigidBody	The rigid body the force is being applied to.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Applies the force to the body. Should be overwritten.
	static updateForce = function(_rb, _dt)
	{
		// Return if infinte mass
		if (!nbpHasFiniteMass(_rb)) return;
		
		// Calculate displacement
		var _r = new Vector2(anchor.x - _rb.x, anchor.y - _rb.y);
		
		// Calculate gamma
		// g = 0.5 * sqrt(4k - d^2)
		var _gamma = 0.5 * sqrt(4 * k - damping * damping);
		if (_gamma == 0) return;
		
		// Calculate c
		// c = (d/2g)p_0 + (1/g)p'_0
		var _a = damping / (2 * _gamma), _b = 1 / _gamma;
		var _c = new Vector2(_a * _r.x + _b * _rb.velocity.x,
			_a * _r.y + _b * _rb.velocity.y);
		
		// Calculate target position
		// p_t = [p_0cos(gt) + csin(gt)]e^(-.5dt)
		var _cos = cos(_gamma * _dt), _sin = sin(_gamma * _dt);
		var _targ = new Vector2(_r.x * _cos + _c.x * _sin,
			_r.y * _cos + _c.y * _sin);
		_targ.scale(exp(-0.5 * _dt * damping));
		
		// Calculate resulting acceleration + force
		_a = 1 / (_dt * _dt);
		var _accel = new Vector2((_targ.x - _r.x) * _a - _rb.velocity.x * _dt,
			(_targ.y - _r.y) * _a - _rb.velocity.y * _dt);
		_accel.scale(-nbpGetMass(_rb));
		nbpAddForceVector(_rb, _accel);
		
		// Delete vectors
		delete _accel;
		delete _targ;
		delete _c;
		delete _r;
	}
}