///	@func	InstTriggerGen();
///	@desc	Handles triggers with instances (squares, rects, circles).
function InstTriggerGen() : TriggerGen() constructor
{
	name = "instance";
	
	///	@func	trigger(rb, pw, dt);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	dt	The change in time of the simulation.
	///	@return	{array}	The triggers that were triggered (or an empty array).
	///	@desc	Returns an array of triggers the rigid body triggered. Should be overwritten.
	static trigger = function(_rb, _pw, _dt)
	{
		// Init trigger array
		var _arr = [];
		
		// Bounding box check
		with (_rb)
		{
			if (!place_meeting(x, y, _pw.tObject)) return _arr;
		}
		
		// Get triggers
		var _triggerList = ds_list_create();
		var _triggerCount = 0;
		with (_rb)
		{
			_triggerCount = instance_place_list(x, y, _pw.tObject, _triggerList, false);
		}
		
		// Loop through potential triggers
		for (var _i = 0; _i < _triggerCount; _i++)
		{
			// Get trigger
			var _trigger = _triggerList[| _i];
			
			// Return if doesn't exist or they don't share layers
			if (!instance_exists(_trigger) || !nbpHasLayerCollision(_rb.collisionBitmask, _trigger.bitmask)) continue;
			
			// Check collision
			switch (_rb.shape)
			{
				case NBPShape.RECT:
					switch (_trigger.shape)
					{
						case NBPShape.RECT:
							// RECT x RECT
							array_push(_arr, _trigger);
							break;
						case NBPShape.CIRCLE:
							// RECT x CIRCLE
							if (circleRectTrigger(_trigger, _rb)) array_push(_arr, _trigger);
							break;
						case NBPShape.RECT_ROTATED:
							// RECT x ROTATED RECT
							if (rotatedRectRectTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
					}
					break;
				case NBPShape.CIRCLE:
					switch (_trigger.shape)
					{
						case NBPShape.RECT:
							// CIRCLE x RECT
							if (circleRectTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
						case NBPShape.CIRCLE:
							// CIRCLE x CIRCLE
							if (circleCircleTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
						case NBPShape.RECT_ROTATED:
							// CIRCLE x ROTATED RECT
							if (circleRotatedRectTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
					}
					break;
				case NBPShape.RECT_ROTATED:
					switch (_trigger.shape)
					{
						case NBPShape.RECT:
							// ROTATED RECT x RECT
							if (rotatedRectRectTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
						case NBPShape.CIRCLE:
							// ROTATED RECT x CIRCLE
							if (circleRotatedRectTrigger(_trigger, _rb)) array_push(_arr, _trigger);
							break;
						case NBPShape.RECT_ROTATED:
							// ROTATED RECT x ROTATED RECT
							if (rotatedRectRectTrigger(_rb, _trigger)) array_push(_arr, _trigger);
							break;
					}
					break;
			}
		}
		
		// Destroy list
		ds_list_destroy(_triggerList);
		
		// Return array
		return _arr;
	}
	
	/// @func	circleCircleTrigger(circ1, circ2);
	///	@param	{Id.Instance}		circ1		The first circle.
	///	@param	{Id.Instance}		circ2		The second circle.
	///	@desc	Returns whether or not there was a collision between two circles (and fills out the contact data).
	static circleCircleTrigger = function(_circ1, _circ2)
	{
		// Get distances
		var _dist = point_distance(_circ1.x, _circ1.y, _circ2.x, _circ2.y);  
		var _r1 = nbpGetRadius(_circ1);
		var _r2 = nbpGetRadius(_circ2);
		if (_dist < (_r1 + _r2)) return true;
		return false;
	}
	
	/// @func	circleRectTrigger(circ, rect);
	///	@param	{Id.Instance}		circ		The circle.
	///	@param	{Id.Instance}		rect		The rectangle.
	///	@desc	Returns whether or not there was a collision between a circle and rectangle (and fills out the contact data).
	static circleRectTrigger = function(_circ, _rect)
	{
		// Get distances
		var _r = nbpGetRadius(_circ);
		var _hw = nbpGetWidth(_rect) * 0.5, _hh = nbpGetHeight(_rect) * 0.5;
		var _cdx = abs(_circ.x - _rect.x), _cdy = abs(_circ.y - _rect.y);
		
		// Rectangle check
		if (_cdx > (_hw + _r)) return false;
		if (_cdy > (_hh + _r)) return false;
		
		// If vertical side hit
		if (_cdx <= _hw) return true;
		
		// If horizontal side hit
		if (_cdy <= _hh) return true;
		
		// If corner hit
		var _cornerDistSquared = sqr(_cdx - _hw) + sqr(_cdy - _hh);
		if (_cornerDistSquared <= (_r * _r)) return true;
		return false;
	}
	
	/// @func	rotatedRectRectTrigger(rrect1, rrect2);
	///	@param	{Id.Instance}		rrect1		The first rotated rectangle.
	///	@param	{Id.Instance}		rrect2		The second rotated rectangle.
	///	@desc	Returns whether or not there was a collision between two non-rotating rectangles (and fills out the contact data).
	static rotatedRectRectTrigger = function(_rrect1, _rrect2)
	{
		// Get base dimensions
		var _hw1 = nbpGetWidth(_rrect1) * 0.5, _hh1 = nbpGetHeight(_rrect1) * 0.5;
		var _hw2 = nbpGetWidth(_rrect2) * 0.5, _hh2 = nbpGetHeight(_rrect2) * 0.5;
		
		#region Rigid Body Points
		
		// Init info
		var _points = [
			new Vector2(_hw1, _hh1),
			new Vector2(_hw1, -_hh1),
			new Vector2(-_hw1, -_hh1),
			new Vector2(-_hw1, _hh1),
		];
		
		// Convert rect points to world space
		for (var _i = 0; _i < array_length(_points); _i++)
		{
			_points[_i].multiplyMatrix22(_rrect1.orientation);
			_points[_i].add(_rrect1.x, _rrect1.y);
		}
		
		// Go through corners
		for (var _i = 0; _i < array_length(_points); _i++)
		{
			// Check if point is inside
			var _r = new Vector2(_points[_i].x - _rrect2.x, _points[_i].y - _rrect2.y);
			_r.multiplyInverseMatrix22(_rrect2.orientation);
			if (point_in_rectangle(_r.x, _r.y, -_hw2, -_hh2, _hw2, _hh2)) return true;
		}
		
		#endregion
		
		#region Trigger Points
		
		// Init info
		_points = [
			new Vector2(_hw2, _hh2),
			new Vector2(_hw2, -_hh2),
			new Vector2(-_hw2, -_hh2),
			new Vector2(-_hw2, _hh2),
		];
		
		// Convert rect points to world space
		for (var _i = 0; _i < array_length(_points); _i++)
		{
			_points[_i].multiplyMatrix22(_rrect2.orientation);
			_points[_i].add(_rrect2.x, _rrect2.y);
		}
		
		// Go through corners
		for (var _i = 0; _i < array_length(_points); _i++)
		{
			// Check if point is inside
			var _r = new Vector2(_points[_i].x - _rrect1.x, _points[_i].y - _rrect1.y);
			_r.multiplyInverseMatrix22(_rrect1.orientation);
			if (point_in_rectangle(_r.x, _r.y, -_hw1, -_hh1, _hw1, _hh1)) return true;
		}
		
		#endregion
		
		return false;
	}
	
	/// @func	circleRotatedRectTrigger(circ, rrect);
	///	@param	{Id.Instance}		circ		The circle.
	///	@param	{Id.Instance}		rrect		The rotated rectangle.
	///	@desc	Returns whether or not there was a collision between a circle and rotated rectangle (and fills out the contact data).
	static circleRotatedRectTrigger = function(_circ, _rrect)
	{
		// Get distances
		var _r = nbpGetRadius(_circ);
		var _hw = nbpGetWidth(_rrect) * 0.5, _hh = nbpGetHeight(_rrect) * 0.5;
		var _rel = new Vector2(_circ.x - _rrect.x, _circ.y - _rrect.y);
		_rel.multiplyInverseMatrix22(_rrect.orientation);
		var _closest = new Vector2(clamp(_rel.x, -_hw, _hw), clamp(_rel.y, -_hh, _hh));
		_rel.addScaledVector(_closest, -1);
		
		// No collision if further than r^2
		if (_rel.magnitudeSquared() > (_r * _r)) return false;
		return true;
	}
}