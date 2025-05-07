// Inherit the parent event
event_inherited();

// Wake up
nbpSetAwake(self.id, true);

// Shape
nbpSetShape(self.id, NBPShape.RECT);
damping = 0.1;