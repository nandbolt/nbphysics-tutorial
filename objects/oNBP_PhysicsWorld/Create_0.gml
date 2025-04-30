///	@desc	Init

/*
nbphysics v0.9
*/

/*
Holds and processes the physics world. You can generally house a physics world within any object,
but this one showcases what should be present to simulate it.
*/

// Physics
deltaTime = 1 / game_get_speed(gamespeed_fps);
simulationSpeed = 1;

// Bodies
rbObject = oNBP_RigidBody;
tObject = oNBP_Trigger;

// Contacts
maxContacts = 32;
calculateIterations = false;
contactResolver = new ContactResolver(64);
contacts = array_create(maxContacts, undefined);
for (var _i = 0; _i < maxContacts; _i++)
{
	contacts[_i] = new Contact();
}
nextContactIdx = 0;