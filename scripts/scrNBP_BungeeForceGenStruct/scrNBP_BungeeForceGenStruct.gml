/// @func	BungeeForceGen(rb, k, restLength);
///	@param	{real}	rb			The rigid body.
///	@param	{real}	k			The spring constant.
///	@param	{real}	restLength	The rest length of the bungee cord.
///	@desc	A force generator representing a bungee cord.
function BungeeForceGen(_rb, _k=1, _restLength=128) : ForceGen() constructor
{
	name = "bungee";
	
	// Spring
	rb = _rb;
	k = _k;
	restLength = _restLength;
	
	///	@func	draw(rb);
	///	@desc	Draws the spring.
	static draw = function(_rb)
	{
		draw_set_color(point_distance(rb.x, rb.y, _rb.x, _rb.y) > restLength ? c_yellow : c_blue);
		draw_line(rb.x, rb.y, _rb.x, _rb.y);
		draw_set_color(c_white);
	}
	
	///	@func	updateForce(rigidBody, dt);
	///	@param	{Struct.RigidBody}	rigidBody	The rigid body the force is being applied to.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Applies the force to the body. Should be overwritten.
	static updateForce = function(_rb, _dt)
	{
		// Calculate force direction
		var _force = new Vector2(rb.x - _rb.x, rb.y - _rb.y);
		
		// Return if cord is compressed
		var _len = _force.magnitude();
		if (_len <= restLength) return;
		
		// Calculate magnitude
		var _dir = sign(_len - restLength);
		_len = abs(_len - restLength);
		_len *= k;
		
		// Apply final force
		_force.normalize();
		_force.scale(_len * _dir);
		nbpAddForceVector(_rb, _force);
	}
}