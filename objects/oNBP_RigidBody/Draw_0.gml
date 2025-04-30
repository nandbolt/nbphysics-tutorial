// Shape
funcDrawShape(self.id);

// Infinite mass dot
if (inverseMass == 0)
{
	draw_set_color(c_orange);
	draw_circle(x, y, 4, true);
	draw_set_color(c_white);
}

// If asleep
if (!isAwake)
{
	// Sleep dot
	draw_set_color(c_fuchsia);
	draw_circle(x, y, 2, false);
	draw_set_color(c_white);
}