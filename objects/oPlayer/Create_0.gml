// Inherit the parent event
event_inherited();

// Movement
moveInput = new Vector2();
moveStrength = 20;

// Wake up
nbpSetAwake(self.id, true);
canSleep = false;

// Set shape
nbpSetShape(self.id, NBPShape.RECT);

// Set size
image_xscale = 30;
image_yscale = 15;

// Friction
damping = 0.1;

// Generators
tgInst = new InstTriggerGen();
fgBuoyancy = new BuoyancyForceGen(0, 0.01);

///	@func	onTriggerEnter(trigger);
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Called once when the body enters the trigger.
onTriggerEnter = function(_trigger)
{
	if (_trigger.object_index == oWater)
	{
		nbpAddForceGen(self.id, fgBuoyancy);
	}
}

///	@func	onTriggerExit(trigger);
///	@param	{Id.Instance}	trigger	The trigger.
///	@desc	Called once when the body exits the trigger.
onTriggerExit = function(_trigger)
{
	if (_trigger.object_index == oWater)
	{
		nbpRemoveForceGen(self.id, fgBuoyancy);
	}
}

grav.y = 10;