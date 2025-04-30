// Color
if (triggeredThisFrame) image_blend = #ffff55;
else image_blend = c_white;

// Shape
switch (shape)
{
	case NBPShape.RECT:
		draw_set_alpha(imageAlpha);
		draw_set_color(image_blend);
		draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
		break;
	case NBPShape.RECT_ROTATED:
		draw_self();
		break;
	case NBPShape.CIRCLE:
		draw_set_alpha(imageAlpha);
		draw_set_color(image_blend);
		draw_circle(x, y, nbpGetRadius(self.id), false);
		break;
}
draw_set_alpha(1);
draw_set_color(c_white);