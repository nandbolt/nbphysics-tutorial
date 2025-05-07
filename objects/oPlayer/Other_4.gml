/// @desc Link Ball

// Set water level for buoy
fgBuoyancy.waterLevel = oWater.bbox_top;

// Link generators
with (oNBP_RigidBody)
{
	nbpAddTriggerGen(self.id, other.tgInst);
}