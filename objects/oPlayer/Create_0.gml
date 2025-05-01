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

// Force generators
fgBungee = new BungeeForceGen(self.id, 1, 500);
fgGravity = new GravitationalForceGen(self.id, 100000);