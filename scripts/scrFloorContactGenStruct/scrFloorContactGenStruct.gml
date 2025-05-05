///	@func	FloorContactGen(height, bounciness);
///	@param	{real}	height		The height of the floor (global)
///	@param	{real}	bounciness	How bouncy the floor is.
///	@desc	Simulates a floor
function FloorContactGen(_height, _bounciness=1) : ContactGen() constructor
{
	name = "floor";
	
	height = _height;
	bounciness = _bounciness;
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit)
	{
		// Didn't hit floor
		if (_rb.bbox_bottom < height) return 0;
		
		// Get contact + clear
		var _contact = _pw.contacts[_pw.nextContactIdx];
		_contact.clear();
		
		// Fillout contact data
		_contact.rb1 = _rb;
		_contact.restitution = bounciness;
		_contact.normal = new Vector2(0, -1);
		_contact.penetration = _rb.bbox_bottom - height;
		
		// Hit floor
		return 1;
	}
	
	static draw = function(){ draw_line(0, height, room_width, height); }
}