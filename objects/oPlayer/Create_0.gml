// Inherit the parent event
event_inherited();

// Movement
moveInput = new Vector2();
moveStrength = 20;

// Wake up
nbpSetAwake(self.id, true);
canSleep = false;

// Set shape
nbpSetShape(self.id, NBPShape.CIRCLE);

// Friction
damping = 0.1;