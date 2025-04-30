/// @func	Matrix22();
///	@desc	A 2x2 matrix, containing two column vectors.
function Matrix22(_angle=-1)	constructor
{
	// The 2x2 matrix
	// [a b] => [a, b, c, d]
	// [c d]
	data = array_create(4);
	
	#region Setters/Getters
	
	//	Set and get variables of the matrix.
	
	///	@func	setRotation(angle);
	///	@param	{real}	angle	The angle to set the matrix to.
	///	@desc	Sets the matrix to be a rotation matrix with the corresponding angle.
	static setRotation = function(_angle)
	{
		data[0] = dcos(_angle);
		data[2] = dsin(_angle);
		data[1] = -data[2];
		data[3] = data[0];
	}
	
	///	@func	getByIndex(i, j);
	///	@param	{real}	i	The ith row (1 or 2)
	///	@param	{real}	j	The jth column (1 or 2)
	///	@desc	Returns the value at the given index of the matrix.
	static getByIndex = function(_i, _j)
	{
		// Make sure indices are valid
		_i = floor(clamp(_i, 1, 2));
		_j = floor(clamp(_i, 1, 2));
		
		// Return value
		if (_i == 1)
		{
			if (_j == 1) return data[0];
			else return data[1];
		}
		else
		{
			if (_j == 1) return data[3];
			else return data[4];
		}
	}
	
	///	@func	getDataCopy();
	///	@return	{array}	The matrix array.
	///	@desc	Returns a copy of the matrix's data array.
	static getDataCopy = function()
	{
		var _arr = [];
		array_copy(_arr, 0, data, 0, array_length(data));
		return _arr;
	}
	
	#endregion
	
	#region Events
	
	//	Called during specific events.
	
	///	@func	cleanup();
	///	@desc	Cleans up the data.
	static cleanup = function(){ data = -1; }
	
	#endregion
	
	#region Properties
	
	//	Return properties of the matrix that need to be calculated.
	
	///	@func	toString();
	///	@desc	Returns a string representation of the matrix.
	static toString = function()
	{
		return string("[{0} {1}]\n[{2} {3}]", data[0], data[1], data[2], data[3]);
	}
	
	#endregion
	
	// Set data
	if (_angle != -1) setRotation(_angle);
}