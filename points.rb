class Point_Logic
	include Logic_Controls
	
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
		box_origin = [box[0],box[1]] #box is an array with 4 values
		prop_names = ["X-coordinate","Y-coordinate","Color","Path Mode"]
		points.each do |n|
			if check_bounds(n.origin,box)
					 n.select
			elsif check_bounds(box_origin,n.bounds)
					 n.select
			else 
				n.deselect
				UI::point_list_model.clear
			end
		end
		
		if points.find_all(&:selected).length == 1
			prop_vals  = points.find(&:selected).properties
			prop_names.each	do |v|
				iter = UI::point_list_model.append
				iter[0] = v
				iter[1] = prop_vals[prop_names.find_index(v)].to_s
			end
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
		UI::point_list_model.clear
		return points
	end
	def cancel_path(points)
		points.find_all(&:pathable).each { |n| n.path_unset }
		return points, false
	end
	
	def delete_points(points)
		return if points.length.zero?
		points.find_all {|f| !f.path_to.length.zero?}.each {|n| n.path_to.reject!(&:selected)}
		points.find_all {|f| !f.path_from.length.zero?}.each {|n| n.path_from.reject!(&:selected)}
		points.reject!(&:selected)
		UI::point_list_model.clear
		return points
	end
	
	def move_points(diff,points)
		if move_check(diff,points)
			points.find_all(&:selected).each {|n| n.set_destination(diff) }			
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
	attr_accessor :source, :color, :path_to, :path_from, :properties
	attr_reader :selected, :pathable, :origin, :bounds, :x, :y
	
	def initialize(o) #where the point was initially placed
		@x = o[0]
		@y = o[1]
		@origin = o
		@bounds = [@x-10,@y-10,@x+10,@y+10]
		@color          = GREY #point color defaults to gray
		@path_color     = CYAN
		@default_color  = GREY
		@pathable       = false
		@selected       = false
		@source         = false
		@path_to        = [] #array of references to points that are receiving a path from this point
		@path_from      = [] #array of references to points that are sending   a path to   this point
		@draw_mode      = "horz"
		@properties = [@x,@y,@default_color,@draw_mode]
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
		@color = WHITE
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
		cr.rounded_rectangle(@x-10,@y-10,20,20,2,2)
		cr.set_line_width(2)
		cr.stroke	 
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
		case @draw_mode
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
		case @draw_mode
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