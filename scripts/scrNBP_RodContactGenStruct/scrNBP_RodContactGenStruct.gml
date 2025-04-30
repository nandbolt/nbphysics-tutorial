///	@func	RodContactGen(rb1, rb2, length, wiggle);
///	@param	{Id.Instance}	rb1	The first rigid body.
///	@param	{Id.Instance}	rb2	The second rigid body.
///	@param	{real}	length	The rod length.
///	@param	{real}	wiggle	The wiggle room for determining collisions.
///	@desc	Handles contacts between bodies connected via a rod.
function RodContactGen(_rb1=noone, _rb2=noone, _length=128, _wiggle=1) : LinkContactGen(_rb1, _rb2) constructor
{
	name = "rod";
	
	// Properties
	length = _length;
	wiggle = _wiggle;
	restitution = 0;
	
	///	@func	draw();
	///	@desc	Draws the link between the rigid bodies.
	static draw = function()
	{
		var _r = point_distance(rb1.x, rb1.y, rb2.x, rb2.y);
		var _c = c_red;
		if (_r > (length + wiggle)) _c = c_yellow;
		if (_r < (length - wiggle)) _c = c_orange;
		draw_set_color(_c);
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
		
		// Get max/min length
		var _minLength = length - wiggle, _maxLength = length + wiggle;
		
		// Return if not overextended
		if (_len <= _maxLength && _len >= _minLength) return 0;
		
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
		
		// Handle collision type
		if (_len > _maxLength)
		{
			// COMPRESSION
			_contact.penetration = _len - _maxLength;
		}
		else
		{
			// EXTENSION
			_contact.penetration = _minLength - _len;
			_contact.normal.invert();
		}
		
		// Set restitution
		_contact.restitution = restitution;
		
		// Return used
		return 1;
	}
}