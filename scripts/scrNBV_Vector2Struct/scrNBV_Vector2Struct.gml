/*
nbvector v1.0
*/

/// @func	Vector2(x, y);
///	@param	{real}	x	The x-coordinate.
///	@param	{real}	y	The y-coordinate.
///	@desc	A 2D vector.
function Vector2(_x=0, _y=0) constructor
{
	x = _x;
	y = _y;
	
	#region Setters/Getters
	
	//	Set and get variables of the vector.
	
	///	@func	set(x, y);
	///	@param	{real}	x	The new x-coordinate.
	///	@param	{real}	y	The new y-coordinate.
	///	@desc	Sets the vector to the new coordinates, or sets it to a zero vector
	///			if no coordinates are given.
	static set = function(_x=0, _y=0)
	{
		x = _x;
		y = _y;
	}
	
	///	@func	setVector(v);
	///	@param	{Struct.Vector2}	v	The new vector.
	///	@desc	Sets the vector to the new vector.
	static setVector = function(_v)
	{
		x = _v.x;
		y = _v.y;
	}
	
	///	@func	setScaled(x, y, factor);
	///	@param	{real}	x	The new x-coordinate.
	///	@param	{real}	y	The new y-coordinate.
	///	@param	{real}	factor	The scale factor.
	///	@desc	Sets the vector to the new coordinates and multiplies it by the given
	///			factor, or sets it to a zero vector if no coordinates are given.
	static setScaled = function(_x=0, _y=0, _factor=1)
	{
		x = _x * _factor;
		y = _y * _factor;
	}
	
	///	@func	setScaledVector(v, factor);
	///	@param	{Struct.Vector2}	v	The new vector.
	///	@param	{real}	factor	The scale factor.
	///	@desc	Sets the vector to the new vector and multiplies it by the given factor.
	static setScaledVector = function(_v, _factor=1)
	{
		x = _v.x * _factor;
		y = _v.y * _factor;
	}
	
	///	@func	setAngle(angle);
	///	@param	{real}	angle	The angle to set it to.
	///	@desc	Sets the vector towards the given angle, keeping the same length or
	///			setting it to a unit vector if initially zero.
	static setAngle = function(_angle)
	{
		// Get length
		var _len = magnitude();
		if (_len == 0) _len = 1;
		
		// Set components
		x = lengthdir_x(_len, _angle);
		y = lengthdir_y(_len, _angle);
	}
	
	///	@func	getCopy();
	///	@return	{Struct.Vector2}	A copy of the vector.
	///	@desc	Returns a copy of the vector.
	static getCopy = function(){ return new Vector2(x, y); }
	
	#endregion
	
	#region Properties
	
	//	Return properties of the vector that need to be calculated.
	
	///	@func	magnitude();
	///	@return	{real}	The length of the vector.
	///	@desc	Returns the length of the vector.
	static magnitude = function(){ return sqrt(x * x + y * y); }
	
	///	@func	magnitudeSquared();
	///	@return	{real}	The squared length of the vector.
	///	@desc	Returns the squared length of the vector.
	static magnitudeSquared = function(){ return x * x + y * y; }
	
	///	@func	angle();
	///	@return	{real}	The angle of the vector (in degrees).
	///	@desc	Returns the angle of the vector in degrees following the standard
	///			unit circle (East = 0 deg, North = 90 deg).
	static angle = function(){ return point_direction(0, 0, x, y); }
	
	///	@func	toString();
	///	@return	{string}	The vector string.
	///	@desc	Returns the string representation of the vector.
	static toString = function(){ return string("({0}, {1})", x, y); }
	
	#endregion
	
	#region Applied Operations
	
	//	Applies operations to the vector.
	
	///	@func	invert();
	///	@desc	Flips the vector.
	static invert = function()
	{
		x = -x;
		y = -y;
	}
	
	///	@func	scale(factor);
	///	@param	{real}	factor	The scale factor.
	///	@desc	Grows or shrinks the vector by the given factor.
	static scale = function(_factor)
	{
		x *= _factor;
		y *= _factor;
	}
	
	///	@func	normalize();
	///	@desc	Scales the vector to a unit vector of size 1, or keeps it a zero vector.
	static normalize = function()
	{
		// Get length
		var _len = magnitude();
		
		// Divide vector by length if not zero
		if (_len > 0) scale(1 / _len);
	}
	
	///	@func	add(x, y);
	///	@param	{real}	x	The x-coordinate to add.
	///	@param	{real}	y	The y-coordinate to add.
	///	@desc	Adds the given coordinates to the vector.
	static add = function(_x, _y)
	{
		x += _x;
		y += _y;
	}
	
	///	@func	addVector(v);
	///	@param	{Struct.Vector2}	v	The vector to add.
	///	@desc	Adds the given vector to the vector.
	static addVector = function(_v)
	{
		x += _v.x;
		y += _v.y;
	}
	
	///	@func	addScaled(x, y, factor);
	///	@param	{real}	x	The x-coordinate to add.
	///	@param	{real}	y	The y-coordinate to add.
	///	@param	{real}	factor	The scale factor.
	///	@desc	Adds the given coordinates to the vector.
	static addScaled = function(_x, _y, _factor)
	{
		x += _x * _factor;
		y += _y * _factor;
	}
	
	///	@func	addScaledVector(v, factor);
	///	@param	{real}	v	The vector to add.
	///	@param	{Struct.Vector2}	factor	The scale factor.
	///	@desc	Adds the given vector to the vector.
	static addScaledVector = function(_v, _factor)
	{
		x += _v.x * _factor;
		y += _v.y * _factor;
	}
	
	///	@func	multiplyComponents(x, y);
	///	@param	{real}	x	The x-coordinate to multiply.
	///	@param	{real}	y	The y-coordinate to multiply.
	///	@desc	Multiplies the vector by the given coordinates.
	static multiplyComponents = function(_x, _y)
	{
		x *= _x;
		y *= _y;
	}
	
	///	@func	multiplyComponentsVector(v);
	///	@param	{Struct.Vector2}	v	The vector to multiply.
	///	@desc	Multiplies the vector by the given vector.
	static multiplyComponentsVector = function(_v)
	{
		x *= _v.x;
		y *= _v.y;
	}
	
	///	@func	multiplyMatrix22(m);
	///	@param	{Struct.Matrix22}	m	The matrix.
	///	@desc	Multiplies the vector by the given 2x2 matrix.
	static multiplyMatrix22 = function(_m)
	{
		set(x * _m.data[0] + y * _m.data[1], x * _m.data[2] + y * _m.data[3]);
	}
	
	///	@func	multiplyInverseMatrix22(m);
	///	@param	{Struct.Matrix22}	m	The matrix.
	///	@desc	Multiplies the vector by the given 2x2 matrix's inverse.
	static multiplyInverseMatrix22 = function(_m)
	{
		set(x * _m.data[0] + y * _m.data[2], x * _m.data[1] + y * _m.data[3]);
	}
	
	#endregion
	
	#region Output Operations
	
	//	Returns a value after the operation, usually not affecting the vector itself.
	
	///	@func	componentProduct(x, y);
	///	@param	{real}	x	The other x-coordinate.
	///	@param	{real}	y	The other y-coordinate.
	///	@return	{Struct.Vector2}	The resulting vector.
	///	@desc	Returns a vector that is the component multiplication between the vectors.
	static componentProduct = function(_x, _y){ return new Vector2(x * _x, y * _y); }
	
	///	@func	componentProductVector(v);
	///	@param	{Struct.Vector2}	v	The other vector.
	///	@return	{Struct.Vector2}	The resulting vector.
	///	@desc	Returns a vector that is the component multiplication between the vectors.
	static componentProductVector = function(_v){ return new Vector2(x * _v.x, y * _v.y); }
	
	///	@func	dotProduct(x, y);
	///	@param	{real}	x	The other x-coordinate.
	///	@param	{real}	y	The other y-coordinate.
	///	@return	{real}	The resulting product.
	///	@desc	Returns the dot product between the vectors.
	static dotProduct = function(_x, _y){ return dot_product(x, y, _x, _y); }
	
	///	@func	dotProductVector(v);
	///	@param	{Struct.Vector2}	v	The other vector.
	///	@return	{real}	The resulting product.
	///	@desc	Returns the dot product between the vectors.
	static dotProductVector = function(_v){ return dot_product(x, y, _v.x, _v.y); }
	
	///	@func	getScaled(factor);
	///	@param	{real}	factor	The scale factor.
	///	@return	{Struct.Vector2}	The resulting vector.
	///	@desc	Returns a scaled version of the vector.
	static getScaled = function(_factor){ return new Vector2(x * _factor, y * _factor); }
	
	///	@func	getSum(x, y);
	///	@param	{real}	x	The other x-coordinate.
	///	@param	{real}	y	The other y-coordinate.
	///	@return	{Struct.Vector2}	The resulting vector.
	///	@desc	Returns a vector that is the sum between the vectors.
	static getSum = function(_x, _y){ return new Vector2(x + _x, y + _y); }
	
	///	@func	getSumVector(v);
	///	@param	{Struct.Vector2}	v	The other vector.
	///	@return	{Struct.Vector2}	The resulting vector.
	///	@desc	Returns a vector that is the sum between the vectors.
	static getSumVector = function(_v){ return new Vector2(x + _v.x, y + _v.y); }
	
	#endregion
}