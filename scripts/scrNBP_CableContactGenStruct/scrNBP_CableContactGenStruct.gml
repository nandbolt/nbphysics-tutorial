///	@func	CableContactGen(rb1, rb2, maxLength);
///	@param	{Id.Instance}	rb1	The first rigid body.
///	@param	{Id.Instance}	rb2	The second rigid body.
///	@param	{real}	maxLength	The max cable length.
///	@desc	Handles contacts between bodies connected via a cable.
function CableContactGen(_rb1=noone, _rb2=noone, _maxLength=128) : LinkContactGen(_rb1, _rb2) constructor
{
	name = "cable";
	
	// Properties
	maxLength = _maxLength;
	restitution = 1;
	
	///	@func	draw();
	///	@desc	Draws the link between the rigid bodies.
	static draw = function()
	{
		draw_set_color(point_distance(rb1.x, rb1.y, rb2.x, rb2.y) > maxLength ? c_yellow : c_aqua);
		draw_line(rb1.x, rb1.y, rb2.x, rb2.y);
		draw_set_color(c_white);
	}
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit)
	{
		// Get length
		var _len = currentLength();
		
		// Return if not overextended
		if (_len <= maxLength) return 0;
		
		// Get contact index
		var _contactIdx = _pw.nextContactIdx;
			
		// Get and clear contact
		var _contact = _pw.contacts[_contactIdx];
		
		// Clear contact
		_contact.clear();
		
		// Set rigid bodies
		_contact.rb1 = rb1;
		_contact.rb2 = rb2;
			
		// Normal
		_contact.normal.set(rb2.x - rb1.x, rb2.y - rb1.y);
		_contact.normal.normalize();
		
		// Penetration
		_contact.penetration = _len - maxLength;
		_contact.restitution = restitution;
		
		// Return used
		return 1;
	}
}