#region Rigid Body

#region Setters/Getters
	
///	@func	nbpGetMass(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@return	{real}	The body's mass.	
///	@desc	Returns the mass of the rigid body.
function nbpGetMass(_rb)
{
	if (_rb.inverseMass == 0) return infinity;
	return 1 / _rb.inverseMass;
}
	
///	@func	nbpSetMass(rb, mass);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	mass	The new mass.	
///	@desc	Sets the mass of the rigid body.
function nbpSetMass(_rb, _mass)
{
	if (_mass == 0) throw("Set mass error. Mass can't be zero!");
	_rb.inverseMass = 1 / _mass;
}

///	@func	nbpGetWidth(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@return	{real}	The width of the body.
///	@desc	Returns the width of the body.
function nbpGetWidth(_rb)
{
	if (_rb.shape == NBPShape.RECT_ROTATED)
	{
		var _angle = _rb.image_angle;
		_rb.image_angle = 0;
		var _w = _rb.bbox_right - _rb.bbox_left;
		_rb.image_angle = _angle;
		return _w;
	}
	return _rb.bbox_right - _rb.bbox_left;
}
	
///	@func	nbpGetHeight(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@return	{real}	The width of the body.
///	@desc	Returns the width of the body.
function nbpGetHeight(_rb)
{
	if (_rb.shape == NBPShape.RECT_ROTATED)
	{
		var _angle = _rb.image_angle;
		_rb.image_angle = 0;
		var _h = _rb.bbox_bottom - _rb.bbox_top;
		_rb.image_angle = _angle;
		return _h;
	}
	return _rb.bbox_bottom - _rb.bbox_top;
}

///	@func	nbpGetRadius(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@return	{real}	The radius of the body.
///	@desc	Returns the radius of the body.
function nbpGetRadius(_rb)
{
	var _w = _rb.bbox_right - _rb.bbox_left, _h = _rb.bbox_bottom - _rb.bbox_top;
	if (_w > _h) return _h * 0.5;
	return _w * 0.5;
}

///	@func	nbpSetAngle(rb, angle);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	angle	The new angle.
///	@desc	Sets the angle of the rigid body.
function nbpSetAngle(_rb, _angle)
{
	_rb.image_angle = _angle;
	if (_rb.shape == NBPShape.RECT_ROTATED) _rb.orientation.setRotation(-_rb.image_angle);
}

///	@func	nbpSetShape(rb, shape);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	shape	The new shape.
///	@desc	Sets the shape of the rigid body.
function nbpSetShape(_rb, _shape)
{
	_rb.shape = _shape;
	switch (_shape)
	{
		case NBPShape.RECT:
			_rb.orientation.setRotation(0);
			
			// Draw
			_rb.funcDrawShape = nbpDrawRect;
			_rb.color = #ffff55;
			break;
		case NBPShape.CIRCLE:
			_rb.orientation.setRotation(0);
			
			// Draw
			_rb.funcDrawShape = nbpDrawCircle;
			_rb.color = #55ff55;
			break;
		case NBPShape.RECT_ROTATED:
			_rb.orientation.setRotation(-_rb.image_angle);
			
			// Draw
			_rb.funcDrawShape = nbpDrawRotatedRect;
			_rb.color = #ff5555;
			break;
	}
}

///	@func	nbpSetLayers(rb, isCollision, b1, b2, b3, b4, b5, b6, b7, b8);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{bool}	isCollision	If you're setting the collision bitmask or not
///	@param	{real}	b1	The first layer's bit	(generally the world/environment)
///	@param	{real}	b2	The second layer's bit	(generally the actors)
///	@param	{real}	b3	The third layer's bit	(generally the projectiles)
///	@param	{real}	b4	The fourth layer's bit
///	@param	{real}	b5	The fifth layer's bit
///	@param	{real}	b6	The sixth layer's bit
///	@param	{real}	b7	The seventh layer's bit
///	@param	{real}	b8	The eighth layer's bit
///	@desc	Sets the current collision bitmask used for detecting what the body can collide with.
function nbpSetLayers(_rb, _isCollision=false, _b1=1, _b2=0, _b3=0, _b4=0, _b5=0, _b6=0, _b7=0, _b8=0)
{
	// Set bitmask real value
	var _bitmask = _b1 + _b2 * 2 + _b3 * 4 + _b4 * 8 + _b5 * 16 + _b6 * 32 + _b7 * 64 + _b8 * 128;
	
	// Set bitmask string
	var _n = _bitmask;
	var _bitmaskString = "";
	for (var _i = 0; _i < 8; _i++)
	{
		if (_n > 0)
		{
			_bitmaskString += string(_n % 2);
			_n = _n div 2;
		}
		else _bitmaskString += "0";
	}
	
	// Set bitmask
	if (_isCollision)
	{
		// Collision check layer
		collisionBitmask = _bitmask;
		collisionBitmaskString = _bitmaskString;
	}
	else
	{
		// Lived layer
		bitmask = _bitmask;
		bitmaskString = _bitmaskString;
	}
}

///	@func	nbpSetAwake(rb, awake);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{bool}	awake	Whether or not its awake.
///	@desc	Sets the body's state to either awake or asleep.
function nbpSetAwake(_rb, _awake=true)
{
	with (_rb)
	{
		if (_awake)
		{
			// WAKE
			isAwake = true;
			
			// Add some motion to avoid immediately sleeping
			motion = NBP_SLEEP_EPSILON * 2;
		}
		else
		{
			// SLEEP
			isAwake = false;
			velocity.set();
		}
	}
}

#endregion
	
#region Properties
	
///	@func	nbpHasFiniteMass(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Returns true if the body has finite mass, false if infinite (or immoveable).
function nbpHasFiniteMass(_rb){ return _rb.inverseMass > 0; }

///	@func	nbpHasLayerCollision(collisionBitmask, bitmask);
///	@param	{Id.Instance}	collisionBitmask	The collision bitmask.
///	@param	{Id.Instance}	bitmask	The bitmask to check.
///	@desc	Returns whether or not there is a similarity within the bitmasks.
function nbpHasLayerCollision(_collisionBitmask, _bitmask)
{
	return !((_collisionBitmask & _bitmask) == 0);
}
	
#endregion
	
#region Simulation
	
///	@func	nbpClearForces(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Clears the forces acting on the body.
function nbpClearForces(_rb){ _rb.force.set(); }
	
///	@func	nbpAddForce(rb, fx, fy);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	fx	The force x-coordinate to add.	
///	@param	{real}	fy	The force y-coordinate to add.	
///	@desc	Adds the force to the net force.
function nbpAddForce(_rb, _fx, _fy)
{
	_rb.force.add(_fx, _fy);
	
	// Wake
	if (!_rb.isAwake) nbpSetAwake(_rb, true);
}
	
///	@func	nbpAddForceVector(rb, f);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.Vector2}	f	The force vector to add.	
///	@desc	Adds the force to the net force.
function nbpAddForceVector(_rb, _f)
{
	_rb.force.addVector(_f);
	
	// Wake
	if (!_rb.isAwake) nbpSetAwake(_rb, true);
}

///	@func	nbpAddForceGen(rb, fg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	fg	The force gen.
///	@desc	Adds a force generator to the rigid body.
function nbpAddForceGen(_rb, _fg)
{
	array_push(_rb.forceGens, _fg);
}

///	@func	nbpRemoveForceGen(rb, fg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	fg	The force gen.
///	@desc	Removes a force generator from the rigid body.
function nbpRemoveForceGen(_rb, _fg)
{
	// Go through force gens
	for (var _i = 0; _i < array_length(_rb.forceGens); _i++)
	{
		// If found force gen
		if (_rb.forceGens[_i] == _fg)
		{
			// Remove force gen and exit loop
			array_delete(_rb.forceGens, _i, 1);
			break;
		}
	}
}

///	@func	nbpClearForceGens(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Clears all force generators from the rigid body.
function nbpClearForceGens(_rb){ _rb.forceGens = []; }

///	@func	nbpApplyForceGens(rb, dt);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	dt	The change in time in the simulation.
///	@desc	Applies all of the registered force gens to the rigid body.
function nbpApplyForceGens(_rb, _dt)
{
	// Go through force gens
	for (var _i = 0; _i < array_length(_rb.forceGens); _i++)
	{
		var _fg = _rb.forceGens[_i];
		_fg.updateForce(_rb, _dt);
	}
}

///	@func	nbpAddContactGen(rb, cg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ContactGen}	cg	The contact gen.
///	@desc	Adds a contact generator to the rigid body.
function nbpAddContactGen(_rb, _cg)
{
	array_push(_rb.contactGens, _cg);
}

///	@func	nbpRemoveContactGen(rb, cg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ContactGen}	cg	The contact gen.
///	@desc	Removes a contact generator from the rigid body.
function nbpRemoveContactGen(_rb, _cg)
{
	// Go through contact gens
	for (var _i = 0; _i < array_length(_rb.contactGens); _i++)
	{
		// If found contact gen
		if (_rb.contactGens[_i] == _cg)
		{
			// Remove contact gen and exit loop
			array_delete(_rb.contactGens, _i, 1);
			break;
		}
	}
}

///	@func	nbpClearContactGens(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Clears all contact generators from the rigid body.
function nbpClearContactGens(_rb){ _rb.contactGens = []; }

///	@func	nbpAddTriggerGen(rb, tg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	tg	The trigger gen.
///	@desc	Adds a trigger generator to the rigid body.
function nbpAddTriggerGen(_rb, _tg)
{
	array_push(_rb.triggerGens, _tg);
}

///	@func	nbpRemoveTriggerGen(rb, tg);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	tg	The trigger gen.
///	@desc	Removes a trigger generator from the rigid body.
function nbpRemoveTriggerGen(_rb, _tg)
{
	// Go through force gens
	for (var _i = 0; _i < array_length(_rb.triggerGens); _i++)
	{
		// If found force gen
		if (_rb.triggerGens[_i] == _tg)
		{
			// Remove force gen and exit loop
			array_delete(_rb.triggerGens, _i, 1);
			break;
		}
	}
}

///	@func	nbpClearTriggerGens(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Clears all trigger generators from the rigid body.
function nbpClearTriggerGens(_rb){ _rb.triggerGens = []; }

///	@func	nbpAddTrigger(rb, trigger);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Adds a trigger reference to the rigid body.
function nbpAddTrigger(_rb, _trigger)
{
	array_push(_rb.triggers, _trigger);
}

///	@func	nbpRemoveTrigger(rb, trigger);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	trigger	The trigger.
///	@desc	Removes a trigger from the rigid body.
function nbpRemoveTrigger(_rb, _trigger)
{
	// Go through force gens
	for (var _i = 0; _i < array_length(_rb.triggers); _i++)
	{
		// If found force gen
		if (_rb.triggers[_i] == _trigger)
		{
			// Remove force gen and exit loop
			array_delete(_rb.triggers, _i, 1);
			break;
		}
	}
}

///	@func	nbpHasTrigger(rb, trigger);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Struct.ForceGen}	trigger	The trigger.
///	@return {bool}	Whether it has the trigger.
///	@desc	Checks if a trigger was in contact with the rigid body.
function nbpHasTrigger(_rb, _trigger)
{
	// Go through force gens
	for (var _i = 0; _i < array_length(_rb.triggers); _i++)
	{
		// If found force gen
		if (_rb.triggers[_i] == _trigger) return true;
	}
	return false;
}

///	@func	nbpClearTriggers(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Clears triggers referenced to the rigid body.
function nbpClearTriggers(_rb, _trigger){ _rb.triggers = []; }

///	@func	nbpUpdateTriggerGens(rb, pw, dt);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{Id.Instance}	pw	The physics world.
///	@param	{real}	dt	The change in time in the simulation.
///	@desc	Updates all of the registered trigger gens on the rigid body.
function nbpUpdateTriggerGens(_rb, _pw, _dt)
{
	// Go through trigger gens
	var _triggers = [];
	for (var _i = 0; _i < array_length(_rb.triggerGens); _i++)
	{
		var _tg = _rb.triggerGens[_i];
		var _arr = _tg.trigger(_rb, _pw, _dt);
		for (var _j = 0; _j < array_length(_arr); _j++)
		{
			// Get trigger
			var _trigger = _arr[_j];
			_trigger.triggeredThisFrame = true;
			
			// If hasn't been triggered before
			if (!nbpHasTrigger(_rb, _trigger.id))
			{
				// Add trigger and call onTriggerEnter
				nbpAddTrigger(_rb, _trigger.id);
				with (_rb)
				{
					onTriggerEnter(_trigger);
				}
			}
			
			// Add to triggers this frame
			array_push(_triggers, _trigger.id);
		}
	}
	
	// Loop through triggers last frame + new one this frame
	for (var _i = array_length(_rb.triggers) - 1; _i >= 0; _i--)
	{
		// Loop through triggers this frame
		var _triggerFound = false;
		for (var _j = 0; _j < array_length(_triggers); _j++)
		{
			// If there's a trigger in both last frame and this frame
			if (_rb.triggers[_i] == _triggers[_j])
			{
				// Found trigger
				_triggerFound = true;
				break;
			}
		}
		
		// If trigger not triggered this frame
		if (!_triggerFound)
		{
			// Remove trigger and call onTriggerExit
			with (_rb)
			{
				onTriggerExit(_rb.triggers[_i]);
			}
			array_delete(_rb.triggers, _i, 1);
		}
	}
}

///	@func	nbpIntegrate(rb, dt);
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	dt	The change in time of the simulation.
///	@desc	Updates the body forward in time in the simulation. This means turning a
///			net force -> acceleration -> velocity -> position.
function nbpIntegrate(_rb, _dt)
{
	// Make sure body is awake
	if (_rb.canSleep && !_rb.isAwake) return;
	
	// Make sure time isn't zero
	if (_dt <= 0) throw("Integration error. Delta time can't be <= 0!");
	
	// Rigid body scope
	with (_rb)
	{
		// Store previous force
		prevForce.setVector(force);
		
		// Calculate acceleration
		acceleration.setScaledVector(force, inverseMass);
		
		// Add gravity
		acceleration.addVector(grav);
		
		// Calculate velocity
		velocity.addScaledVector(acceleration, _dt);
		
		// Apply velocity damping
		velocity.scale(power(damping, _dt));
		
		// Calculate position
		x += velocity.x;
		y += velocity.y;
		
		#region Sleep
		
		// Check if can sleep
		if (canSleep)
		{
			// Calculate current motion
			var _currentMotion = velocity.dotProductVector(velocity);
		
			// Calculate bias
			var _bias = power(NBP_MOTION_BIAS, _dt);
		
			// Get the recency-weighted average motion over several frames
			motion = _bias * motion + (1 - _bias) * _currentMotion;
		
			// Check motion clamp
			if (motion > (10 * NBP_SLEEP_EPSILON)) motion = 10 * NBP_SLEEP_EPSILON;
			// Check if bedtime
			else if (motion < NBP_SLEEP_EPSILON) nbpSetAwake(self.id, false);
		}
		
		#endregion
	}
}

#endregion

#region Debug

///	@func	nbpDrawRect(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Draws the rigid body as a rectangle (using the bounding box).
function nbpDrawRect(_rb)
{
	with (_rb)
	{
		// Outlines
		if (outlines)
		{
			image_blend = c_dkgray;
			draw_set_color(c_dkgray);
			draw_self();
			draw_circle(x, y, nbpGetRadius(self.id), true);
		}
		
		// Rectangle
		draw_set_color(color);
		draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
		
		// Reset color
		draw_set_color(c_white);
	}
}

///	@func	nbpDrawRotatedRect(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Draws the rigid body as a rotated rectangle.
function nbpDrawRotatedRect(_rb)
{
	with (_rb)
	{
		// Outlines
		if (outlines)
		{
			draw_set_color(c_dkgray);
			draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
			draw_circle(x, y, nbpGetRadius(self.id), true);
		}
		
		// Rotated rectangle
		image_blend = color;
		draw_self();
		
		// Reset color
		draw_set_color(c_white);
	}
}

///	@func	nbpDrawCircle(rb);
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Draws the rigid body as a rectangle (using the bounding box).
function nbpDrawCircle(_rb)
{
	with (_rb)
	{
		// Outlines
		if (outlines)
		{
			image_blend = c_dkgray;
			draw_set_color(c_dkgray);
			draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
			draw_self();
		}
		
		// Circle
		draw_set_color(color);
		draw_circle(x, y, nbpGetRadius(self.id), true);
		
		// Reset color
		draw_set_color(c_white);
	}
}

#endregion

#endregion

#region Trigger

///	@func	nbpInitTrigger(trigger);
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Initializes the trigger for the frame.
function nbpInitTrigger(_trigger)
{
	_trigger.triggeredThisFrame = false;
}

#endregion

#region PhysicsWorld

#region Properties

///	@func	nbpGetRigidBodyCount(pw);
///	@param	{Id.Instance}	pw	The physics world.
///	@desc	Returns the amount of rigid bodies within the physics simulation.
function nbpGetRigidBodyCount(_pw){ return instance_number(_pw.rbObject); }

///	@func	nbpGetTriggerCount(pw);
///	@param	{Id.Instance}	pw	The physics world.
///	@desc	Returns the amount of triggers within the physics simulation.
function nbpGetTriggerCount(_pw){ return instance_number(_pw.tObject); }

#endregion

#region Simulation

///	@func	nbpInitNextPhysicsFrame(pw);
///	@param	{Id.Instance}	pw	The physics world.
///	@desc	Inits the world before a simulation frame.
function nbpInitNextPhysicsFrame(_pw)
{
	// Go through bodies
	with (_pw.rbObject)
	{
		// Clear forces
		nbpClearForces(self.id);
	}
}
	
///	@func	nbpRunPhysics(pw, dt);
///	@param	{Id.Instance}	pw	The physics world.
///	@para	{real}	dt	The change in time in the simulation.
///	@desc	Processes all physics within the simulation.
function nbpRunPhysics(_pw, _dt)
{
	// Reset triggers
	with (_pw.tObject)
	{
		nbpInitTrigger(self.id);
	}
	
	// Apply force generators
	with (_pw.rbObject)
	{
		nbpApplyForceGens(self.id, _dt);
	}
		
	// Integrate bodies
	with (_pw.rbObject)
	{
		nbpIntegrate(self.id, _dt);
	}
	
	// Update triggers
	with (_pw.rbObject)
	{
		nbpUpdateTriggerGens(self.id, _pw, _dt);
	}
		
	// Generate contacts
	var _usedContacts = nbpGenerateContacts(_pw);
	
	// Process contacts
	if (_usedContacts > 0)
	{
		with (_pw)
		{
			if (calculateIterations) contactResolver.setIterations(_usedContacts * 2);
			contactResolver.resolveContacts(contacts, _usedContacts, _dt);
		}
	}
}

///	@func	nbpGenerateContacts(pw);
///	@param	{Id.Instance}	pw	The physics world.
///	@return	{real}	The number of contacts.
///	@desc	Calls all contact generators and reports their contacts, returning the number of contacts.
function nbpGenerateContacts(_pw)
{
	// Init contact cursor
	var _limit = _pw.maxContacts;
	_pw.nextContactIdx = 0;
	
	// Loop through bodies
	with (_pw.rbObject)
	{
		// Reset normals
		normals = [];
		
		// Loop through registered contact generators
		for (var _i = 0; _i < array_length(contactGens); _i++)
		{
			// Check for contacts
			var _used = contactGens[_i].addContact(self.id, _pw, _limit);
			_limit -= _used;
			
			// Add to local normals
			if (_used > 0) array_push(normals, _pw.contacts[_pw.nextContactIdx].normal);
			
			// Increment index
			_pw.nextContactIdx += _used;
			
			// Return if limit reached (meaning we'll have to ignore some contacts this step)
			if (_limit <= 0) return _pw.maxContacts;
		}
	}
	
	// Return contacts used
	return _pw.maxContacts - _limit;
}
	
#endregion

#endregion