///	@func	AnchoredCableContactGen(rb1, rb2, maxLength);
///	@param	{Struct.Vector2}	anchor	The anchor position.
///	@param	{Id.Instance}	rb	The rigid body.
///	@param	{real}	maxLength	The max cable length.
///	@desc	Handles contacts between the anchor and the body connected via a cable.
function AnchoredCableContactGen(_anchor=undefined, _rb=noone, _maxLength=128) : AnchoredLinkContactGen(_anchor, _rb) constructor
{
	name = "anchored cable";
	
	// Properties
	maxLength = _maxLength;
	restitution = 1;
	
	///	@func	draw();
	///	@desc	Draws the link between the rigid bodies.
	static draw = function()
	{
		draw_set_color(point_distance(anchor.x, anchor.y, rb.x, rb.y) > maxLength ? c_yellow : c_aqua);
		draw_line(anchor.x, anchor.y, rb.x, rb.y);
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
		_contact.rb1 = rb;
		_contact.rb2 = noone;
			
		// Normal
		_contact.normal.set(anchor.x - rb.x, anchor.y - rb.y);
		_contact.normal.normalize();
		
		// Penetration
		_contact.penetration = _len - maxLength;
		_contact.restitution = restitution;
		
		// Return used
		return 1;
	}
}