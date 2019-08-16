class Point_Logic
	include Logic_Controls
	
	def initialize
		@prop_names = ["Note","Velocity","Duration (%)","X-coordinate","Y-coordinate","Color","Path Mode"]
		@curr_prop = nil
	end
	
	def add_point(r_origin,points) #Point existence search
		unless (collision_check(r_origin,points))
			points << NousPoint.new(r_origin)
		end
		return points
	end
	
	def add_path(points)
		points.find_all { |n| n.pathable && !n.source}.each do |t| 
			points.find(&:source).path_to << t
			t.path_from << points.find(&:source)
		end
		return points
	end
	
	def collision_check(r_origin,points)
			return true if points.any? { |n| r_origin == n.origin }
	end
	
	def select_points(box,points) #Select points with the select tool
		UI::point_list_model.clear
		UI::prop_mod.text = ""
		box_origin = [box[0],box[1]] #box is an array with 4 values
		points.each do |n|
			if check_bounds(n.origin,box)
					 n.select
			elsif check_bounds(box_origin,n.bounds)
					 n.select
			else 
				n.deselect
				UI::point_list_model.clear
				UI::prop_mod.text = ""
			end
		end
		populate_prop(points)
		return points
	end
	
	def populate_prop (points)
		UI::point_list_model.clear
		if points.find_all(&:selected).length == 1
		  prop_vals = [points[0].note,
			             points[0].velocity,
									 points[0].duration,
									 points[0].x,
									 points[0].y,
									 color_to_hex(points[0].default_color),
									 points[0].path_mode]
			@prop_names.each	do |v|
				iter = UI::point_list_model.append
				iter[0] = v
				iter[1] = prop_vals[@prop_names.find_index(v)].to_s
			end
		elsif points.find_all(&:selected).length > 1
			UI::point_list_model.clear
			UI::prop_mod.text = ""
		end
		return points
	end	
	def point_list_select(selected)
		return if selected == nil
		@curr_prop = selected[0]
		UI::prop_mod.text = selected[1]
	end
	
	def check_input(text)
		case @curr_prop
			when "Note", "Velocity"
				if text.to_i >= 1 && text.to_i <= 127
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Duration (%)"
				if text.to_i >= 1 && text.to_i <= 100
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "X-coordinate", "Y-coordinate"
				if round_num_to_grid(text.to_i) >= 50 && round_num_to_grid(text.to_i) <= 3250
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Color"
				if text.match(/^#[0-9A-Fa-f]{6}$/)
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Path Mode"
				if text == "horz" || text == "vert"
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			else UI::prop_mod_button.sensitive = false
		end
	end
	
	def modify_properties(points)
		case @curr_prop
			when "Note"
				points.find(&:selected).note = UI::prop_mod.text.to_i
			when "Velocity"
				points.find(&:selected).velocity = UI::prop_mod.text.to_i
			when "Duration (%)"
				points.find(&:selected).duration = UI::prop_mod.text.to_i
			when "X-coordinate"
				points.find(&:selected).x = UI::prop_mod.text.to_i
			when "Y-coordinate"
				points.find(&:selected).y = UI::prop_mod.text.to_i
			when "Color"
				points.find(&:selected).set_default_color(hex_to_color(UI::prop_mod.text))
			when "Path Mode"
				points.find(&:selected).path_mode = UI::prop_mod.text
		end
		return points
	end
	
	def select_path_point(origin,points,source_chosen)
		points.find_all {|g| check_bounds(origin,g.bounds)}.each do |n|
			case !n.pathable
				when true #If clicking where a non-pathable point is
					source_chosen = n.path_set(source_chosen)
				when false
					if n.source
						points, source_chosen = cancel_path(points)
					end
					n.path_unset
			end
		end
		return points, source_chosen
	end
	
	def cancel_selected(points)
		points.find_all(&:selected).each { |n| n.deselect }
		return points
	end
	def cancel_path(points)
		points.find_all(&:pathable).each { |n| n.path_unset }
		return points, false
	end
	
	def delete_points(points)
		points.find_all {|f| !f.path_to.length.zero?}.each   {|n| n.path_to.reject!(&:selected)}
		points.find_all {|f| !f.path_from.length.zero?}.each {|n| n.path_from.reject!(&:selected)}
		points.reject!(&:selected)
		UI::point_list_model.clear
		UI::prop_mod.text = ""
		return points
	end
	
	def move_points(diff,points)
		if move_check(diff,points)
			points.find_all(&:selected).each {|n| n.set_destination(diff) }	
			UI::point_list_model.clear
			UI::prop_mod.text = ""
			populate_prop(points)			
		end
		return points
	end
	def move_check(diff,points)
		points.find_all(&:selected).each do |n|
			dest = n.origin.map
			dest = dest.to_a
			dest.map! {|g| g += diff[dest.find_index(g)]}
			return false if points.find_all(&:not_selected).any? { |g| g.origin == dest}
		end
		return true
	end
	
end

class NousPoint
	attr_accessor :source, :color, :path_to, :path_from, :note, :x, :y,
	              :velocity, :duration, :default_color, :path_mode
	attr_reader :selected, :pathable, :origin, :bounds
	
	def initialize(o) #where the point was initially placed
		@x = o[0]
		@y = o[1]
		@origin = o
		@bounds = [@x-10,@y-10,@x+10,@y+10]
		@color          = GREY #point color defaults to gray
		@path_color     = CYAN
		@default_color  = GREY
		@note           = 60     #all notes start at middle c
		@velocity       = 100		 #       ``       with 100 velocity
		@duration       = 100    #       ``            a length 100% of the path length
		@pathable       = false
		@selected       = false
		@source         = false
		@path_to        = [] #array of references to points that are receiving a path from this point
		@path_from      = [] #array of references to points that are sending   a path to   this point
		@path_mode      = "horz"
	end

	def not_selected
		!@selected
	end
	def not_pathable
		!@pathable
	end
	
	def origin=(o) #sets the origin of the point explicitly
		@x = o[0]
		@y = o[1]
		@origin = o
		@bounds = [@x-10,@y-10,@x+10,@y+10]
	end

	def path_set(source_chosen)
		@pathable = true
		case source_chosen
			when false       #if source point was not chosen (first point clicked on path screen)
				@source = true #Path source is now chosen on this node
				@color = CYAN
				return true
			when true	       #Path source is already chosen in this operation
				@color = GREEN
		end
		return source_chosen
	end
	def path_unset
		@pathable = false
		@source = false
		@color = @default_color
	end

	def set_default_color(c)
		@color = c
		@default_color = c
	end
	def set_destination(diff) #sets a new origin for the point based on x,y coordinate differences
		@x += diff[0]
		@y += diff[1]
		@origin = [@x,@y]
		@bounds = [@x-10,@y-10,@x+10,@y+10]
	end
	def select  #elevate color to denote 'selected' and sets a flag
		@selected = true
	end
	def deselect #resets the color from elevated 'selected' values and sets a flag
		@selected = false
		@color = @default_color
	end
	
	def draw(cr)                     #point will always be drawn to this specification.
		cr.set_source_rgba(@color[0],@color[1],@color[2],0.4)
		cr.rounded_rectangle(@x-8,@y-8,16,16,2,2) #slightly smaller rectangle adds 'relief' effect
		cr.fill
		
		
		cr.set_source_rgba(@color[0],@color[1],@color[2],1)
		cr.circle(@x,@y,1)
		cr.fill
		
		if !@selected
			cr.rounded_rectangle(@x-10,@y-10,20,20,2,2)
			cr.set_line_width(2)
			cr.stroke
		end
		if @selected
			cr.set_source_rgba(1,1,1,0.8)
			cr.rounded_rectangle(@x-10,@y-10,20,20,2,2) #slightly smaller rectangle adds 'relief' effect
			cr.move_to(@x-18,@y-18)
			cr.line_to(@x-14,@y-18)
			cr.move_to(@x-18,@y-18)
			cr.line_to(@x-18,@y-14)

			cr.move_to(@x+18,@y-18)
			cr.line_to(@x+14,@y-18)
			cr.move_to(@x+18,@y-18)
			cr.line_to(@x+18,@y-14)
						
			cr.move_to(@x-18,@y+18)
			cr.line_to(@x-14,@y+18)
			cr.move_to(@x-18,@y+18)
			cr.line_to(@x-18,@y+14)
						
			cr.move_to(@x+18,@y+18)
			cr.line_to(@x+14,@y+18)
			cr.move_to(@x+18,@y+18)
			cr.line_to(@x+18,@y+14)
			cr.set_line_width(2)
			cr.stroke
		end
	end
	
	def path_draw(cr)
		cr.set_source_rgba(@path_color[0],@path_color[1],@path_color[2],0.4)
		@path_to.each   {|t| trace_path_to(cr,t)}
		cr.set_line_width(6)
		cr.stroke
		if !@selected
			@path_to.each   {|t| trace_path_to(cr,t)}
			cr.set_source_rgba(0,0,0,0.4)
			cr.set_line_width(3)
			cr.stroke
		elsif @selected
			cr.set_source_rgba(ORNGE[0],ORNGE[1],ORNGE[2],0.4)
			@path_from.each {|s| trace_path_from(cr,s)}
			cr.set_line_width(3)
			cr.stroke
			cr.set_source_rgba(@path_color[0],@path_color[1],@path_color[2],0.4) if @selected
			@path_to.each   {|t| trace_path_to(cr,t)}
			cr.set_line_width(3)
			cr.stroke
		end
	end

	def trace_path_to(cr,t)
		case @path_mode
		when "horz"
			cr.move_to(@x,@y)
			cr.line_to(t.x,@y)
			cr.line_to(t.x,t.y)
		when "vert"
			cr.move_to(@x,@y)
			cr.line_to(@x,t.y)
			cr.line_to(t.x,t.y)
		when "line"
			cr.move_to(@x,@y)
			cr.line_to(t.x,t.y)
		end
	end	
	def trace_path_from(cr,s)
		case @path_mode
		when "horz"
			cr.move_to(s.x,s.y)
			cr.line_to(@x,s.y)
			cr.line_to(@x,@y)
		when "vert"
			cr.move_to(s.x,s.y)
			cr.line_to(s.x,@y)
			cr.line_to(@x,@y)
		when "line"
			cr.move_to(s.x,s.y)
			cr.line_to(@x,@y)
		end
	end
end

Pl = Point_Logic.new