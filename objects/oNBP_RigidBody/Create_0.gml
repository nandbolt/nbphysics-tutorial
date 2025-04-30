///	@desc	Rigid Body

/*
These are the bodies that move about in the simulation and can be influenced by force and contact generators.
*/

#region Body Properties

/*
Used in acceleration calculations, acceleration = force * inverse mass
(inverseMass = 0 => infinite mass, doesn't move in collisions).
The higher the inverse mass, the 'lighter' the body
*/
inverseMass = 1;

/*
What shape the body is represented as (rectangle, rotated rectangle, circle).
Shape should be changed using nbpSetShape(rb, shape);
Default is normal rectangle.
*/
shape = NBPShape.RECT;

/*
How bouncy the object is during collisions (0 = no bounce, 1 = max bounce).
Bounce is averaged between the two bodies during collisions.
*/
bounciness = 1;

/*
A rotation matrix representing the body's orientation in computer coordinates (+y is down, +x is right).
When changing the angle of the rigid body, use nbpSetAngle(rb, angle) to automatically update the matrix.
*/
orientation = new Matrix22(-image_angle);

/*
Holds the motion of the body, used for putting the body to sleep or not.
*/
motion = 0;

/*
Rigid bodies can be put to sleep to avoid integration/collision functions.
*/
isAwake = true;

/*
Used to prevent specific bodies from being put to sleep, such as the player.
*/
canSleep = true;

#endregion

#region Environmental Properties

/*
Applies a constant force (or gravity) to the body
*/
grav = new Vector2();

/*
Applies general friction, slowing down bodies (0 = max friction, 1 = no friction)
*/
damping = 0.995;

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

/*
Holds all contact normals currently generated this frame.
*/
normals = [];

#endregion

#region Movement Vectors

velocity = new Vector2();		// Updates the position every frame, velocity = Δdistance / Δtime
acceleration = new Vector2();	// Updates the velocity every frame, acceleration = Δvelocity / Δtime
force = new Vector2();			// Used to calculate acclerations every frame, force = mass * acceleration, net force = sum of all forces
prevForce = new Vector2();		// Stores the previous force, used for bookkeeping since the force is cleared every frame

#endregion

#region Physics Generators

/*
Holds registered force generators that will be applied to the body by a physics world.
To add a force generator, use nbpAddForceGen(rb, fg).
*/
forceGens = [];

/*
Holds registered contact generators that will be applied to the body by a physics world
To add a contact generator, use nbpAddContactGen(rb, cg).
*/
contactGens = [];

/*
Holds registered trigger generators that will activate once in contact
To add a trigger generator, use nbpAddContactGen(rb, cg).
*/
triggerGens = [];

#endregion

#region Triggers

/*
Holds the triggers currently being triggered. Used to detect onTriggerExit(trigger).
*/
triggers = [];

///	@func	onTriggerEnter(trigger);
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Called once when the body enters the trigger.
onTriggerEnter = function(_trigger){}

///	@func	onTriggerExit(trigger);
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Called once when the body exits the trigger.
onTriggerExit = function(_trigger){}

#endregion

#region Debug

// Draw
color = #ffff55;	// The color of body when drawn (default color for rect is yellow)
outlines = true;	// If true, shows all of the possible shape's outlines (circle, rotated rect, rect)
funcDrawShape = nbpDrawRect;

#endregion
