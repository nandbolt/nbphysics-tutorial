#region Macros

/*
The threshold for sleeping. If motion is below this value, the object is put to sleep.
*/
#macro NBP_SLEEP_EPSILON 0.1

/*
For updating the motion component for sleep-checking in a recency-weighted average.
0 bias => makes the motion equal to the new value on each update.
1 bias => ignores the new motion's value.
*/
#macro NBP_MOTION_BIAS 0.65

#endregion

#region Enums

// Physics shapes
enum NBPShape
{
	RECT,
	RECT_ROTATED,
	CIRCLE,
}

#endregion