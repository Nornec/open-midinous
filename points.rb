class Point_Logic
	include Logic_Controls
	def add_point(r_origin,points) #Point existence search
		unless (collision_check(r_origin,points))
			points << NousPoint.new(r_origin)
		end
		return points
	end
	
	def add_path(source,target)
		paths << NousPoint.NousPath.new
		return paths
	end
	
	def collision_check(r_origin,points)
			return true if points.any? { |n| r_origin == n.get_origin }
	end
	
	def select_points(box,points) #Select points with the select tool
		box_origin = [box[0],box[1]]
		points.each do |n|
			if check_bounds(n.get_origin,box)
					 n.selected
			elsif check_bounds(box_origin,n.get_bounds)
					 n.selected
			else n.deselected
			end
		end
		return points
	end
	
	def select_path_point(origin,points,source_chosen)
		points.find_all {|g| check_bounds(origin,g.get_bounds)}.each do |n|
			case !n.is_pathable
				when true #If clicking where a non-pathable point is
					source_chosen = n.pathable(source_chosen)
				when false
					if n.is_path_source
						points, source_chosen = cancel_path(points)
					end
					n.depathable
			end
		end
		return points, source_chosen
	end
	
	def cancel_selected(points)
		points.find_all(&:is_selected).each { |n| n.deselected }
		return points
	end
	def cancel_path(points)
		points.find_all(&:is_pathable).each { |n| n.depathable }
		return points, false
	end
	
	def delete_points(points) #may have to add logic to delete paths as well if paths arent deleted with points.
		return if points.length.zero?
		points = points.reject(&:is_selected)
		return points
	end
	
	def move_points(diff,points)
		if move_check(diff,points)
			points.find_all(&:is_selected).each { |n| n.set_destination(round_to_grid(diff)) }
		end
		return points
	end

	def move_check(diff,points)         
		points.find_all(&:is_selected).each do |n| 
			dest = n.plan_move(diff)
			return false if points.find_all(&:is_not_selected).any? { |g| g.get_origin == dest }           
		end
		return true
	end
	
end

class NousPoint
	
	def initialize(origin) #where the point was initially placed
		@x = origin[0]
		@y = origin[1]
		@color          = GREY #point color defaults to gray
		@default_color  = GREY
		@pathable       = false
		@selected       = false
		@path_buffer    = []
		@has_path       = false
		#@region = assign_region(origin)
	end
	
	#def assign_region
	#	
	#end
	
	#def get_region
	#	return @region
	#end
	
	def get_origin
		return [@x,@y]
	end
	
	def is_selected
		@selected
	end
	
	def is_not_selected
		!is_selected
	end
	
	def is_pathable
		@pathable
	end
	
	def is_not_pathable
		!is_pathable
	end

	def get_bounds
		return [@x-10,@y-10,@x+10,@y+10]
	end
	
	def set_origin(origin) #sets the origin of the point explicitly
		@x = origin[0]
		@y = origin[1]
	end

	def pathable(source_chosen)
		@pathable = true
		case source_chosen
			when false       #if source point was not chosen (first point clicked on path screen)
				@source = true #Path source is now chosen on this node
				set_color(CYAN)
				return true
			when true	       #Path source is already chosen in this operation
				set_color(GREEN)
		end
		return source_chosen
	end
	
	def is_path_source
		@source
	end
	
	def depathable
		@pathable = false
		@source = false
		set_color(@default_color)
	end
	
	def set_destination(diff_coord) #sets a new origin for the point based on x,y coordinate differences
		@x += diff_coord[0]
		@y += diff_coord[1]
	end
	
	def set_color(color) #modifies the color of the point, input is a 4-value array
		@color = color
	end
	def set_default_color(color)
		@color = color
		@default_color = color
	end
	
	def selected   #elevate color to denote 'selected' and sets a flag
		@selected = true
		set_color(WHITE)
	end
	
	def deselected #resets the color from elevated 'selected' values and sets a flag
		@selected = false
		set_color(@default_color)
	end

	def plan_move(diff) #Plan the move to a new point using x,y relative coordinates
		dest = get_origin
		dest[0] += diff[0]
		dest[1] += diff[1]
		return dest
	end
	
	def draw(cr) #point will always be drawn to this specification. Use a modify_* method to change.
		
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

end

class NousPath

	def initialize(source,target)
		@source_origin = source
		@target_origin = target
	end
	
end

Pl = Point_Logic.new