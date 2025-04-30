/// @func	BuoyancyForceGen(waterLevel, liquidDensity);
///	@param	{real}	waterLevel		The y-position of the water level.
///	@param	{real}	liquidDensity	The liquid density.
///	@desc	A force generator representing buoyancy in water.
function BuoyancyForceGen(_waterLevel, _liquidDensity=0.1) : ForceGen() constructor
{
	name = "buoyancy";
	
	// Spring
	waterLevel = _waterLevel;
	liquidDensity = _liquidDensity;
	
	///	@func	draw();
	///	@desc	Draws the spring.
	static draw = function()
	{
		draw_set_color(c_aqua);
		var _x1 = camera_get_view_x(view_camera[0]);
		var _x2 = _x1 + camera_get_view_width(view_camera[0]);
		draw_line(_x1, waterLevel, _x2, waterLevel);
		draw_set_color(c_white);
	}
	
	///	@func	updateForce(rigidBody, dt);
	///	@param	{Struct.RigidBody}	rigidBody	The rigid body the force is being applied to.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Applies the force to the body. Should be overwritten.
	static updateForce = function(_rb, _dt)
	{
		// Get submission depth
		var _depth = _rb.bbox_bottom;
		
		// Return if out of water
		if (_depth <= waterLevel) return;
		var _force = new Vector2();
		
		// Check if at max depth
		var _w = nbpGetWidth(_rb), _h = nbpGetHeight(_rb);
		var _area = _w * _h;
		if (_depth >= (waterLevel + _h))
		{
			_force.y = -liquidDensity * _area;
			nbpAddForceVector(_rb, _force);
			return;
		}
		
		// Partially submerged
		_force.y = -liquidDensity * _area * (_depth - waterLevel) / _h;
		nbpAddForceVector(_rb, _force);
	}
}