///	@func	AnchoredLinkContactGen(anchor, rb);
///	@param	{Struct.Vector2}	anchor	The anchor position.
///	@param	{Id.Instance}	rb	The rigid body.
///	@desc	Handles contacts between bodies linked to the anchor. Only inherited contact generators will be instanced.
function AnchoredLinkContactGen(_anchor=undefined, _rb=noone) : ContactGen() constructor
{
	name = "anchored link";
	
	// Anchor + body
	anchor = _anchor;
	rb = _rb;
	
	///	@func	currentLength();
	///	@param	{real}	The link's length.
	///	@desc	Returns the current length of the link.
	static currentLength = function()
	{
		if (!is_struct(anchor) || !instance_exists(rb)) return -1;
		return point_distance(anchor.x, anchor.y, rb.x, rb.y);
	}
	
	///	@func	draw();
	///	@desc	Draws the link between the rigid bodies.
	static draw = function()
	{
		draw_set_color(c_white);
		draw_line(anchor.x, anchor.y, rb.x, rb.y);
	}
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit){ return 0; }
}