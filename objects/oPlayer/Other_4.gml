/// @desc Link Ball
with (oNBP_RigidBody)
{
	nbpAddContactGen(self.id, other.cgInst);
	nbpAddContactGen(self.id, other.cgFloor);
}