/// @desc Run Physics

/*
Here I manually set dt to be the 'perfect' time between frames. However, if you want a more accurate
time between frames you can use delta_time / 1000000. Note, however that switching in/out of the game
window will count as delta time, so you may want to cap it to prevent objects going through things.
*/
var _dt = deltaTime * simulationSpeed;

/*
Runs all of the physics, applying all of the accumulated forces, then resolving contacts after.
This is run in Step so you can add forces in Begin Step and have things follow physics
bodies in End Step.
*/
nbpRunPhysics(self.id, _dt);

/*
Clears all of the forces for the next frame. It's called after the physics simulation to allow
forces to be added from generally anywhere rather than within a certain window.
*/
nbpInitNextPhysicsFrame(self.id);