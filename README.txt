Logical operation is the key to Midinous.

Trigger path
	Starting point with one or more instruments (midi channels) specified
		We ought to just focus on midi channel and not the specification of the instrument.
		Midinous should act as a complex controller and composition tool. The main DAW deals with what the channel is assigned to.
		We can however allow for labels of the midi channels and should represent them as different colors.
	Point(s) -> path(s) -> point(s)
	
A "point" is a node with logical controls that tell the program what to do
Points with multiple channels specified will be white
A "path" is the distance measured in beats or milliseconds between two points. It also connects the logic between points Paths cannot exist without at least 2 points

A point will hold the following MIDI data
	- Instrument(channel)(s)
	- Note(s)
	- Velocity(s)
	- Length (beats or milliseconds)
	
Input triggers output:
	INPUT possible MIDI logic controls
		- Cumulative AND : Time independent (hold gathered input until all conditions are met (switching))
		- Inclusive AND  : Time dependent (only forward if specific note/instrument combo is received)
		- OR             : One condition or another condition will propagate
		- FILTER         : Can filter on note or instrument or both
		- EXCEPT         : All but one condition'
	THEN
	OUTPUT possible MIDI logic controls
		- Random       : any point as a child of the triggered point may be called (can be weighted)
		- Iterative    : points as children of the triggered point will be called in ascending order of specified sequence
		- Portal       : points at a specified surrogate (unconnected) child to be called after specified time.
		- Split        : points at all children and sends a signal to them
		- Repeat       : repeats the point n times after a specified time
Sub logic will allow for the stacking of input and output parms