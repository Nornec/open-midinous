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
=end
#trace = TracePoint.new(:call) do |tp|
#  puts "#{tp.defined_class}##{tp.method_id} got called (#{tp.path}:#{tp.lineno})"
#end

#trace.enable
# do stuff here
CANVAS_SIZE = 3300 #regions 500px by 500px
GRID_SPACING = 50
RED   = [1,0,0,0.5]
GREEN = [0,1,0,1]
BLUE  = [0,0,1,1]

GtkRadioButtonEx #Declare the new radio button definition for added functionality
GtkCanvas        #Declare the new drawing area definition for added functionality
UI = UI_Elements.new()  #Create a new UI_Elements object
UI::build_ui

class Init_Prog
	def initialize #Build the user interface, initiate the objects in the program
		UI::midinous.signal_connect("destroy") {Gtk.main_quit}
		UI::canvas.set_size_request(CANVAS_SIZE,CANVAS_SIZE)
		UI::canvas_h_adj.set_upper(CANVAS_SIZE)
		UI::canvas_v_adj.set_upper(CANVAS_SIZE)
		UI::grid_set(CANVAS_SIZE,GRID_SPACING)
	end
	
	def grid_center #center the grid
		UI::canvas_h_adj.set_value(CANVAS_SIZE/3.1)
		UI::canvas_v_adj.set_value(CANVAS_SIZE/2.4)
	end
end
init = Init_Prog.new
init.grid_center # Setting Grid Center here ensures the background always gets drawn first
$nouspoints = []

module Logic_Controls #various reusable functions useful for checks and math
	
	def switch_tool(tool_id) #switches the active tool based on signal output
		case
			when tool_id == 1 
				puts "Select Tool"
			when tool_id == 2 
				puts "Point Placement Tool"
			when tool_id == 3 
				puts "Move Tool"
			when tool_id == 4 
				puts "Path Tool"
			else nil
		end
	end
	
	def round_to_grid(coord) #rounds a coordinate to the nearest snappable grid point
		ratio = 100 / GRID_SPACING
		n = 0
		while n < coord.length
			coord[n] = coord[n].to_f / 100
			coord[n] = (coord[n] * ratio).round
			coord[n] = (coord[n] * 100) / ratio
			n += 1
		end
		return coord
	end
	
	def check_bounds(coord,bounds) # returns true if coordinate is colliding with a point bounding box.
		if coord[0].between?(bounds[0],bounds[2]) == true &&
		   coord[1].between?(bounds[1],bounds[3]) == true
			return true
		else return false
		end
	end
	
	def pos_box(bounds) #turn a coordinate-bounded box with unmatching coordinates into one with positive coordinates
		if bounds[0] > bounds[2] #Flip the array positions if the box is drawn backwards in any direction.
			 bounds[0], bounds[2] = bounds[2], bounds[0]
		end
		if bounds[1] > bounds[3]
			bounds[1], bounds[3] = bounds[3], bounds[1]
		end
		return bounds
	end
	
	def delete_points #will have to add logic to delete paths as well
		unless $nouspoints.length == 0
			$nouspoints.length.times do |n|
				if $nouspoints[n].is_selected == true
					$nouspoints[n] = nil
				end
			end
			$nouspoints -= [nil]
		end
		#puts "Indecies for delete: #{@queue_delete}"
		#@queue_delete.length.times do |n|
		#	$nouspoints.delete_at(queue_delete[n])
		#end
		UI::canvas.queue_draw
	end
	
	def find_region(coord)
		x = coord[0]
		y = coord[1]
	end
end

module Widget_Event_Router
	extend Logic_Controls
	UI::main_tool_1.signal_connect("button-press-event") {switch_tool(1)}
	UI::main_tool_1.signal_connect("keybinding-event")   {switch_tool(1)}
	UI::main_tool_2.signal_connect("button-press-event") {switch_tool(2)}
	UI::main_tool_2.signal_connect("keybinding-event")   {switch_tool(2)}
	UI::main_tool_3.signal_connect("button-press-event") {switch_tool(3)}
	UI::main_tool_3.signal_connect("keybinding-event")   {switch_tool(3)}
	UI::main_tool_4.signal_connect("button-press-event") {switch_tool(4)}
	UI::main_tool_4.signal_connect("keybinding-event")   {switch_tool(4)}
	UI::canvas.signal_connect("delete-selected-event")   {delete_points}
end

module Key_Bindings
	UI::midinous.signal_connect("key-press-event") do |_widget, event|
		puts event.keyval
		case
			when event.keyval == 113 # Q
				UI::main_tool_1.active = true
				UI::main_tool_1.signal_emit("keybinding-event")
			when event.keyval == 119 # W
				UI::main_tool_2.active = true
				UI::main_tool_2.signal_emit("keybinding-event")			
			when event.keyval == 101 || event.keyval == 102 # E or F (colemak)
				UI::main_tool_3.active = true
				UI::main_tool_3.signal_emit("keybinding-event")			
			when event.keyval == 114 || event.keyval == 112 # R or P (colemak)
				UI::main_tool_4.active = true
				UI::main_tool_4.signal_emit("keybinding-event")
			when event.keyval == 65535 # del
				UI::canvas.signal_emit("delete-selected-event")
			else nil
		end
	end	
end

module Canvas_Events
	extend Logic_Controls
	@selection = nil
	@selecting = false
	@sel_white = [0.8,0.8,0.8,0.1] 	#colors
	@sel_blue  = [0,0.5,1,0.5]
	@pointOrigin = nil
	@pointMove = nil
	@diff      = []
	
	UI::canvas.signal_connect("button-press-event") do |_widget, event|
		#puts "button press event triggered"
		if UI::main_tool_1.active? == true
			@selection   = [event.x,event.y,event.x,event.y]
			@selecting   = true
		elsif UI::main_tool_2.active? == true
			@pointOrigin = [event.x,event.y]
		elsif UI::main_tool_3.active? == true
			@pointMove = [event.x,event.y,event.x,event.y]
		end
	end
	UI::canvas.signal_connect("motion-notify-event") do |_widget, event|
		#puts "motion notify event triggered"

		if (@selecting && @selection)
			@selection[2] = event.x
			@selection[3] = event.y
			_widget.queue_draw
		elsif (@pointOrigin)
			@pointOrigin[0] = event.x
			@pointOrigin[1] = event.y
		elsif (@pointMove)
			# difference in movement of the point, cumulative until mouse released
			@diff = round_to_grid([(event.x - @pointMove[0]) , (event.y - @pointMove[1])])
			@pointMove[2] = event.x
			@pointMove[3] = event.y
			_widget.queue_draw
		end
	end
	UI::canvas.signal_connect("button-release-event") do |_widget, event|
		#puts "button release event triggered"
		if UI::main_tool_1.active? == true
			@selection = pos_box(@selection)
			
			$nouspoints.length.times do |n|
				#If there are points in the selection
				if check_bounds($nouspoints[n].get_origin,@selection) == true
					   $nouspoints[n].selected
				
				#If the click is within the bounds of a point
				elsif check_bounds([@selection[0],@selection[1]],$nouspoints[n].get_bounds) == true 
					   $nouspoints[n].selected
				else $nouspoints[n].deselected
				end
			end
			@selection = nil
			@selecting = false
			_widget.queue_draw
		elsif UI::main_tool_2.active? == true
			_widget.queue_draw
		elsif UI::main_tool_3.active? == true
			no_move = false
			
			$nouspoints.length.times do |n| #move coordinate point check
				if $nouspoints[n].is_selected
					dest_coord = $nouspoints[n].get_origin
					dest_coord[0] += @diff[0]
					dest_coord[1] += @diff[1]
					
					$nouspoints.length.times do |g|
						if dest_coord == $nouspoints[g].get_origin &&$nouspoints[g].is_selected == false
							no_move = true #error dialog?
						end
					end
				end
			end
			
			$nouspoints.length.times do |n| #move the points if they can all move at once. One error will not allow movement.
				if no_move == false && $nouspoints[n].is_selected == true
						$nouspoints[n].set_destination(round_to_grid(@diff))
				end
			end
			@pointMove = nil
			_widget.queue_draw
		end
		
	end

	UI::canvas.signal_connect("draw") do |_widget, cr|
		if(@selection)
			#puts "draw start"
			width  = @selection[2] - @selection[0]
			height = @selection[3] - @selection[1]
			
			cr.set_source_rgba(@sel_white)
			cr.rectangle(@selection[0],@selection[1],width,height)
			cr.fill
			cr.set_source_rgba(@sel_blue)
			cr.rectangle(@selection[0],@selection[1],width,height)
			cr.set_line_width(2)
			cr.stroke
		elsif(@pointOrigin)
			#have a function here that determines whether the find function needs to run
			# by checking the current "chunk" for any objects. If nothing is there
			# then skip the search. This will improve performance given a large # of objects.
			r_origin = round_to_grid(@pointOrigin)
			exists = false
			$nouspoints.length.times do |n| #Point existence search
				if r_origin == $nouspoints[n].get_origin
					exists = true
				end
				@pointOrigin = nil
			end
			if exists == false
				$nouspoints << NousPoint.new(r_origin)
				@pointOrigin = nil
			end
		elsif(@pointMove)
			start_coord = [@pointMove[0],@pointMove[1]]
			end_coord   = [@pointMove[2],@pointMove[3]]
			start_coord = round_to_grid(start_coord)
			end_coord   = round_to_grid(end_coord)
			
			cr.move_to(start_coord[0],start_coord[1])
			cr.set_source_rgba(RED)
			cr.line_to(end_coord[0],end_coord[1])
			cr.set_line_width(2)
			cr.stroke
			cr.rounded_rectangle(end_coord[0]-10,end_coord[1]-10,20,20,2,2)
			cr.set_line_width(2)
			cr.stroke
		end
		
		#always iterate through the $nouspoints object array LAST and draw each point based on its properties.
		$nouspoints.length.times do |n| 
			$nouspoints[n].draw(cr)
		end
	end
end

class NousPoint
	@x          = 0
	@y          = 0
	@x_store    = 0
	@y_store    = 0
	@color      = []
	@ring_color = []
	@region     = -1
	
	class NousPath
		#Work on paths after points are movable
	end
	
	def initialize(origin) #where the point was initially placed
		@x = origin[0]
		@y = origin[1]
		@color          = [0.6,0.6,0.6,0.4] #if color is not modified, default it to grey
		@ring_color     = [0.6,0.6,0.6,1.0]
		@color_sel      = [1,1,1,0.4]
		@ring_color_sel = [1,1,1,1]
	end
	
	def get_origin
		return [@x,@y]
	end
	
	def is_selected
		return @selected
	end
	
	def get_bounds
		return [@x-10,@y-10,@x+10,@y+10]
	end
	
	def set_origin(origin) #sets the origin of the point explicitly
		@x = origin[0]
		@y = origin[1]
	end

	def set_destination(diff_coord) #sets a new origin for the point based on x,y coordinate differences
		@x += diff_coord[0]
		@y += diff_coord[1]
	end
	
	def modify_color(color) #modifies the color of the point, input is a 4-value array
		@color      = [color[0],color[1],color[2],color[3]-0.6]
		@ring_color = [color[0],color[1],color[2],color[3]]
	end
	
	def selected #enhances the color of the point to notate selection
		@selected = true
	end
	
	def deselected #resets the color from elevated 'selected' values
		@selected = false
	end
	
	def draw(cr) #point will always be drawn to this specification. Use a modify_* method to change.
		if @selected == true
			   cr.set_source_rgba(@color_sel)
		else cr.set_source_rgba(@color)
		end
		cr.rounded_rectangle(@x-8,@y-8,16,16,2,2) #slightly smaller rectangle adds 'relief' effect
		cr.fill
		if @selected == true
			   cr.set_source_rgba(@ring_color_sel)
		else cr.set_source_rgba(@ring_color)
		end
		cr.circle(@x,@y,1)
		cr.fill
		cr.rounded_rectangle(@x-10,@y-10,20,20,2,2)
		cr.set_line_width(2)
		cr.stroke
	end

end



Gtk.main
#trace.disable

=begin sample draw
ui::canvas.signal_connect("draw") do |_widget, cr| #_widget means current widget. cr is the cairo context created via the signal

  # create shape
  cr.move_to(400, 1000)
  cr.curve_to(100, 25, 100, 75, 150, 50)
  cr.line_to(150, 0)
  cr.line_to(50, 150)
  cr.close_path

  cr.set_source_rgba(0.5, 0.0, 0.2,0.5)
  cr.fill_preserve
  cr.set_source_rgba(0.6, 0.0, 0.2,1)
  cr.set_line_join(Cairo::LINE_JOIN_MITER)
  cr.set_line_width(2)
  cr.stroke
end
=end