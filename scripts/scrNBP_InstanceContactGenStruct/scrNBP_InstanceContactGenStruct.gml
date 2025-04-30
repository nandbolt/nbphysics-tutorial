///	@func	InstContactGen();
///	@desc	Handles contacts between instances (squares, rects, circles).
function InstContactGen() : ContactGen() constructor
{
	name = "instance";
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit)
	{
		// Store contact count
		var _used = 0;
		
		// Check general collision
		var _placeMet = false;
		with (_rb)
		{
			_placeMet = place_meeting(x, y, _pw.rbObject);
		}
		if (_placeMet)
		{
			// Get collision list
			var _collisionList = ds_list_create();
			var _collisionCount = 0;
			with (_rb)
			{
				_collisionCount = instance_place_list(x, y, _pw.rbObject, _collisionList, false);
			}
			
			// Loop through potential collisions
			var _contactIdx = _pw.nextContactIdx;
			for (var _i = 0; _i < _collisionCount; _i++)
			{
				// Break if at the limit
				if (_used >= _limit) break;
				
				// Get instance
				var _inst = _collisionList[| _i];
			
				// Return if doesn't exist or they don't share layers
				if (!instance_exists(_inst) || !nbpHasLayerCollision(_rb.collisionBitmask, _inst.bitmask)) continue;
			
				// Return if both have infinite mass
				if (_rb.inverseMass == 0 && _inst.inverseMass == 0) continue;
			
				// Get and clear contact
				var _contact = _pw.contacts[_contactIdx];
			
				// Check collision
				switch (_rb.shape)
				{
					case NBPShape.RECT:
						switch (_inst.shape)
						{
							case NBPShape.RECT:
								// RECT x RECT
								if (rectRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.CIRCLE:
								// RECT x CIRCLE
								if (circleRectCollision(_contact, _inst, _rb))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.RECT_ROTATED:
								// RECT x ROTATED RECT
								if (rotatedRectRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
						}
						break;
					case NBPShape.CIRCLE:
						switch (_inst.shape)
						{
							case NBPShape.RECT:
								// CIRCLE x RECT
								if (circleRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.CIRCLE:
								// CIRCLE x CIRCLE
								if (circleCircleCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.RECT_ROTATED:
								// CIRCLE x ROTATED RECT
								if (circleRotatedRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
						}
						break;
					case NBPShape.RECT_ROTATED:
						switch (_inst.shape)
						{
							case NBPShape.RECT:
								// ROTATED RECT x RECT
								if (rotatedRectRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.CIRCLE:
								// ROTATED RECT x CIRCLE
								if (circleRotatedRectCollision(_contact, _inst, _rb))
								{
									_used++;
									_contactIdx++;
								}
								break;
							case NBPShape.RECT_ROTATED:
								// ROTATED RECT x ROTATED RECT
								if (rotatedRectRectCollision(_contact, _rb, _inst))
								{
									_used++;
									_contactIdx++;
								}
								break;
						}
						break;
				}
			}
			
			// Destroy list
			ds_list_destroy(_collisionList);
		}
		
		// Return contacts used
		return _used;
	}
	
	///	@func	getCollisionRestitution(rb1, rb2);
	///	@param	{Id.Instance}	rb1	The first rigid body.
	///	@param	{Id.Instance}	rb2	The first rigid body.
	///	@return	{real}	The restitution.
	///	@desc	Returns a restitution value for the collision.
	static getCollisionRestitution = function(_rb1, _rb2)
	{
		if (instance_exists(_rb2)) return (_rb1.bounciness + _rb2.bounciness) / 2;
		return _rb1.bounciness;
	}
	
	/// @func	circleCircleCollision(contact, circ1, circ2);
	///	@param	{Struct.Contact}	contact		The contact data.
	///	@param	{Id.Instance}		circ1		The first circle.
	///	@param	{Id.Instance}		circ2		The second circle.
	///	@desc	Returns whether or not there was a collision between two circles (and fills out the contact data).
	static circleCircleCollision = function(_contact, _circ1, _circ2)
	{
		// Get distances
		var _dist = point_distance(_circ1.x, _circ1.y, _circ2.x, _circ2.y);  
		var _r1 = nbpGetRadius(_circ1);
		var _r2 = nbpGetRadius(_circ2);
		if (_dist < (_r1 + _r2))
		{
			// Clear contact
			_contact.clear();
		
			// Set rigid bodies
			_contact.rb1 = _circ1;
			_contact.rb2 = _circ2;
			
			// Normal
			_contact.normal.set(_circ1.x - _circ2.x, _circ1.y - _circ2.y);
			_contact.normal.normalize();
		
			// Penetration
			_contact.penetration = (_r1 + _r2) - _dist;
			
			// Resitution
			_contact.restitution = getCollisionRestitution(_circ1, _circ2);
			return true;
		}
		return false;
	}
	
	/// @func	rectRectCollision(contact, rect1, rect2);
	///	@param	{Struct.Contact}	contact		The contact data.
	///	@param	{Id.Instance}		rect1		The first rectangle.
	///	@param	{Id.Instance}		rect2		The second rectangle.
	///	@desc	Returns whether or not there was a collision between two non-rotating rectangles (and fills out the contact data).
	static rectRectCollision = function(_contact, _rect1, _rect2)
	{
		// Clear contact
		_contact.clear();
		
		// Set rigid bodies
		_contact.rb1 = _rect1;
		_contact.rb2 = _rect2;
		
		// Get penetration depth
		var _dx = 0, _dy = 0;
		if (_rect1.x < _rect2.x) _dx = _rect2.bbox_left - _rect1.bbox_right;
		else _dx = _rect2.bbox_right - _rect1.bbox_left;
		if (_rect1.y < _rect2.y) _dy = _rect2.bbox_top - _rect1.bbox_bottom;
		else _dy = _rect2.bbox_bottom - _rect1.bbox_top;
		if (abs(_dx) > abs(_dy)) _dx = 0;
		else _dy = 0;
		
		// Set collision normal direction
		_contact.normal.set(_dx, _dy);
		
		// Set penetration
		_contact.penetration = _contact.normal.magnitude();
		
		// Normalize normal
		_contact.normal.normalize();
		
		// Resitution
		_contact.restitution = getCollisionRestitution(_rect1, _rect2);
		return true;
	}
	
	/// @func	circleRectCollision(contact, circ, rect);
	///	@param	{Struct.Contact}	contact		The contact data.
	///	@param	{Id.Instance}		circ		The circle.
	///	@param	{Id.Instance}		rect		The rectangle.
	///	@desc	Returns whether or not there was a collision between a circle and rectangle (and fills out the contact data).
	static circleRectCollision = function(_contact, _circ, _rect)
	{
		// Get distances
		var _r = nbpGetRadius(_circ);
		var _hw = nbpGetWidth(_rect) * 0.5, _hh = nbpGetHeight(_rect) * 0.5;
		var _cdx = abs(_circ.x - _rect.x), _cdy = abs(_circ.y - _rect.y);
		
		// Rectangle check
		if (_cdx > (_hw + _r)) return false;
		if (_cdy > (_hh + _r)) return false;
		
		// Clear contact
		_contact.clear();
		
		// Set rigid bodies
		_contact.rb1 = _rect;
		_contact.rb2 = _circ;
		
		// Resitution
		_contact.restitution = getCollisionRestitution(_circ, _rect);
		
		// If vertical side hit
		if (_cdx <= _hw)
		{	
			// Set collision normal direction
			var _dy = _rect.y - _circ.y;
			_contact.normal.set(0, _dy);
			_contact.normal.normalize();
			
			// Calculate penetration
			_contact.penetration = (_hh + _r) - abs(_dy);
			return true;
		}
		
		// If horizontal side hit
		if (_cdy <= _hh)
		{
			// HORIZONTAL SIDE HIT
			
			// Set collision normal direction
			var _dx = _rect.x - _circ.x;
			_contact.normal.set(_dx, 0);
			_contact.normal.normalize();
			
			// Calculate penetration
			_contact.penetration = (_hw + _r) - abs(_dx);
			return true;
		}
		
		// If corner hit
		var _cornerDistSquared = sqr(_cdx - _hw) + sqr(_cdy - _hh);
		if (_cornerDistSquared <= (_r * _r))
		{
			// Get center displacement
			var _dx = _rect.x - _circ.x, _dy = _rect.y - _circ.y;
			
			// Get corner displacement
			var _cornerX = _rect.bbox_left, _cornerY = _rect.bbox_top;
			if (_dx < 0)
			{
				_cornerX = _rect.bbox_right;
				if (_dy < 0) _cornerY = _rect.bbox_bottom;
			}
			else if (_dy < 0) _cornerY = _rect.bbox_bottom;
			_dx = _cornerX - _circ.x;
			_dy = _cornerY - _circ.y;
			
			// Calculate normal
			_contact.normal.set(_dx, _dy);
			_contact.normal.normalize();
			
			// Calculate penetration
			_contact.penetration = _r - sqrt(_dx * _dx + _dy * _dy);
			return true;
		}
		return false;
	}
	
	/// @func	rotatedRectRectCollision(contact, rrect1, rrect2);
	///	@param	{Struct.Contact}	contact		The contact data.
	///	@param	{Id.Instance}		rrect1		The first rotated rectangle.
	///	@param	{Id.Instance}		rrect2		The second rotated rectangle.
	///	@desc	Returns whether or not there was a collision between two non-rotating rectangles (and fills out the contact data).
	static rotatedRectRectCollision = function(_contact, _rrect1, _rrect2)
	{
		// Clear contact
		_contact.clear();
		
		// Set rigid bodies
		_contact.rb1 = _rrect1;
		_contact.rb2 = _rrect2;
		
		// Resitution
		_contact.restitution = getCollisionRestitution(_rrect1, _rrect2);
		
		// Get base dimensions
		var _hw1 = nbpGetWidth(_rrect1) * 0.5, _hh1 = nbpGetHeight(_rrect1) * 0.5;
		var _hw2 = nbpGetWidth(_rrect2) * 0.5, _hh2 = nbpGetHeight(_rrect2) * 0.5;
		
		// Init info
		var _bestPenetration = 99999;
		var _bestNormal = new Vector2();
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
			if (point_in_rectangle(_r.x, _r.y, -_hw2, -_hh2, _hw2, _hh2))
			{
				// Get min penetration
				var _penetration = 99999;
				var _n = new Vector2((_hw2 - abs(_r.x)) * sign(_r.x), (_hh2 - abs(_r.y)) * sign(_r.y));
				
				// Calculate point to first rect vector (r2)
				var _r2 = new Vector2(_rrect1.x - _points[_i].x, _rrect1.y - _points[_i].y);
				
				// Calculate r2 in local space
				var _r2r = _r2.getCopy();
				_r2r.multiplyInverseMatrix22(_rrect2.orientation);
				
				// Choose lowest interpenetration
				if (abs(_n.x) <= abs(_n.y) && _n.y != 0 && _r2r.dotProduct(_n.x, 0) > 0)
				{
					_n.y = 0;
					_penetration = abs(_n.x);
				}
				else
				{
					_n.x = 0;
					_penetration = abs(_n.y);
				}
					
				// Flip normal to world orientation
				_n.multiplyMatrix22(_rrect2.orientation);
					
				// Check if new best and valid normal
				if (_penetration < _bestPenetration && _penetration > 0 && _n.dotProductVector(_r2) >= 0)
				{
					// Set new normal + penetration
					_bestPenetration = _penetration;
						
					// Normalize and set best normal
					_n.normalize();
					_bestNormal.setVector(_n);
				}
			}
		}
		
		// Return if couldn't find a penetration
		if (_bestPenetration == 99999) return false;
		
		// Set contact info
		_contact.normal.setVector(_bestNormal);
		_contact.penetration = _bestPenetration;
		return true;
	}
	
	/// @func	circleRotatedRectCollision(contact, circ, rrect);
	///	@param	{Struct.Contact}	contact		The contact data.
	///	@param	{Id.Instance}		circ		The circle.
	///	@param	{Id.Instance}		rrect		The rotated rectangle.
	///	@desc	Returns whether or not there was a collision between a circle and rotated rectangle (and fills out the contact data).
	static circleRotatedRectCollision = function(_contact, _circ, _rrect)
	{
		// Get distances
		var _r = nbpGetRadius(_circ);
		var _hw = nbpGetWidth(_rrect) * 0.5, _hh = nbpGetHeight(_rrect) * 0.5;
		var _rel = new Vector2(_circ.x - _rrect.x, _circ.y - _rrect.y);
		_rel.multiplyInverseMatrix22(_rrect.orientation);
		var _closest = new Vector2(clamp(_rel.x, -_hw, _hw), clamp(_rel.y, -_hh, _hh));
		var _diff = _rel.getCopy();
		_diff.addScaledVector(_closest, -1);
		var _distSquared = _diff.magnitudeSquared();
		
		// No collision if further than r^2
		if (_distSquared > (_r * _r)) return false;
		
		// Clear contact
		_contact.clear();
		
		// Set rigid bodies
		_contact.rb1 = _circ;
		_contact.rb2 = _rrect;
		
		// Resitution
		_contact.restitution = getCollisionRestitution(_circ, _rrect);
		
		// Penetration
		var _dist = sqrt(_distSquared);
		var _penetration = 0.01;
		
		// Normalize
		if (_dist == 0) _diff.set(0, -1);
		else
		{
			_diff.normalize();
			_penetration = _r - _dist;
		}
		
		// Rotate normal back
		_diff.multiplyMatrix22(_rrect.orientation);
		_contact.normal.setVector(_diff);
		_contact.penetration = _penetration;
		return true;
	}
}