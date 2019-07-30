require "midi"
require "gtk3"
require_relative "ui"
require_relative "proc_midi"
=begin
	Logical operation is the key to Midinous.
	
	Trigger path
		Starting point with one or more instruments (midi channels) specified
			We ought to just focus on midi channel and not the specification of the instrument.
			Midinous should act as a complex controller and composition tool. The main DAW deals with what the channel is assigned to.
			We can however allow for labels of the midi channels and should represent them as different colors.
		Point(s) -> path(s) -> point(s)
		
	A "point" is a node with logical controls that tell the program what to do
	Points with multiple channels specified will be white
	A "path" is the distance measured in beats or milliseconds between two points. Paths cannot exist without points
	
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
=end
CANVAS_SIZE = 3000

ui = UI_Elements.new()  #Create a new UI_Elements object
ui::build_ui            #Build the user interface, initiate the objects in the program
ui::midinous.signal_connect("destroy") {Gtk.main_quit}

ui::canvas.set_size_request(CANVAS_SIZE,CANVAS_SIZE)
ui::grid_set(CANVAS_SIZE)

Gtk.main
