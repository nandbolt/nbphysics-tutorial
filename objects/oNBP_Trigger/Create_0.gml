///	@desc	Trigger

/*
These are the triggers that can 'sense' rigid bodies, getting triggered on contact.
*/

#region Body Properties

/*
What shape the body is represented as (rectangle, rotated rectangle, circle).
Shape should be changed using nbpSetShape(rb, shape);
Default is normal rectangle.
*/
shape = NBPShape.RECT;

/*
A rotation matrix representing the body's orientation in computer coordinates (+y is down, +x is right).
When changing the angle of the rigid body, use nbpSetAngle(rb, angle) to automatically update the matrix.
*/
orientation = new Matrix22(-image_angle);

/*
Whether or not the trigger was triggered this frame. Gets reset every frame.
*/
triggeredThisFrame = false;

#endregion

#region Environmental Properties

/*
Used for collision checks, this is the layer where the body 'lives'. There are 8 potential layers, or
bits and can be set using nbpSetBitmask(rb, bits). Collisions will only occur between bodies having at
least one similar bit, or layer, with each other.
The default mask is 1 => 10000000.
*/
bitmask = 1;
bitmaskString = "10000000";		// Updates everytime the bitmask is changed. Used for reference.

/*
Used for collision checks, this is the layer the body 'checks' for collisions. There are 8 potential
layers, or bits and can be set using nbpSetBitmask(rb, bits). Collisions will only occur between bodies
having at least one similar bit, or layer, with each other.
The default mask is 1 => 10000000.
*/
collisionBitmask = 1;
collisionBitmaskString = "10000000";		// Updates everytime the bitmask is changed. Used for reference.

#endregion

// Color
triggerColor = #ffff55;
imageAlpha = 0.25;
