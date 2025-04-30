///	@func	LinkContactGen(rb1, rb2);
///	@param	{Id.Instance}	rb1	The first rigid body.
///	@param	{Id.Instance}	rb2	The second rigid body.
///	@desc	Handles contacts between linked bodies. Only inherited contact generators will be instanced.
function LinkContactGen(_rb1=noone, _rb2=noone) : ContactGen() constructor
{
	name = "link";
	
	// Bodies
	rb1 = _rb1;
	rb2 = _rb2;
	
	///	@func	currentLength();
	///	@param	{real}	The link's length.
	///	@desc	Returns the current length of the link.
	static currentLength = function()
	{
		if (!instance_exists(rb1) || !instance_exists(rb2)) return -1;
		return point_distance(rb1.x, rb1.y, rb2.x, rb2.y);
	}
	
	///	@func	draw();
	///	@desc	Draws the link between the rigid bodies.
	static draw = function()
	{
		draw_set_color(c_white);
		draw_line(rb1.x, rb1.y, rb2.x, rb2.y);
	}
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit){ return 0; }
}