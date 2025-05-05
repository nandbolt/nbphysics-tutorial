// Inherit the parent event
event_inherited();

// Movement
moveInput = new Vector2();
moveStrength = 20;

// Wake up
nbpSetAwake(self.id, true);
canSleep = false;

// Set shape
nbpSetShape(self.id, NBPShape.RECT_ROTATED);

// Set size
image_xscale = 30;
image_yscale = 15;

// Friction
damping = 0.1;

// Contact generator
cgInst = new InstContactGen();
cgFloor = new FloorContactGen(room_height - 16, 0);

grav.y = 10;