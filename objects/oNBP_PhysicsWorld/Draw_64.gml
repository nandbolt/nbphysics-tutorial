/// @desc Debug Info

/*
(Optional) You can set the object to not be visible or delete this event if you don't
want to see debug info.
*/

// Setup
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _x = 8, _y = 24, _ySpacing = 16;
		
// Text
draw_text(_x, _y, "Physics World");
_y += _ySpacing;
draw_text(_x, _y, string("rigid bodies: {0}", nbpGetRigidBodyCount(self.id)));
_y += _ySpacing;
draw_text(_x, _y, string("triggers: {0}", nbpGetTriggerCount(self.id)));
_y += _ySpacing;
draw_text(_x, _y, string("contact iters used: {0}", contactResolver.getIterationsUsed()));
_y += _ySpacing;