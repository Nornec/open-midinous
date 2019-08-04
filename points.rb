class Point_Logic
	include Logic_Controls
	def add_point(r_origin,points) #Point existence search
		unless (add_check(r_origin,points))
			points << NousPoint.new(r_origin)
		end
		return points
	end
	
	def add_check(r_origin,points)
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
		#@region = assign_region(origin)
	end
	
	def assign_region
		
	end
	
	def get_region
		return @region
	end
	
	def get_origin
		return [@x,@y]
	end
	
	def is_selected
		@selected
	end
	
	def is_not_selected
		!is_selected
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
	
	def selected   #elevate color to denote 'selected'
		@selected = true
	end
	
	def deselected #resets the color from elevated 'selected' values
		@selected = false
	end
	
	def plan_move(diff) #Plan the move to a new point using x,y relative coordinates
		dest = self.get_origin
		dest[0] += diff[0]
		dest[1] += diff[1]
		return dest
	end
	
	def draw(cr) #point will always be drawn to this specification. Use a modify_* method to change.
		if(@selected)
			   cr.set_source_rgba(@color_sel)
		else cr.set_source_rgba(@color)
		end
		cr.rounded_rectangle(@x-8,@y-8,16,16,2,2) #slightly smaller rectangle adds 'relief' effect
		cr.fill
		if(@selected)
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

Pl = Point_Logic.new