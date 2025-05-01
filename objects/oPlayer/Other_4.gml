/// @desc Link Ball
with (oBall)
{
	nbpAddForceGen(self.id, other.fgBungee);
	nbpAddForceGen(self.id, other.fgGravity);
}