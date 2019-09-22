module Logic_Controls #various reusable functions useful for checks and math
	
	def set_point_speed(tempo,beats,beat_note) #Sets time between each grid point
		point_speed = (tempo/60)*CC.grid_spacing #Grid points that will be hit per second 
		return point_speed                       #(will be a fraction most of the time)
	end
	
	def round_to_grid(coord) #rounds a coordinate to the nearest snappable grid point
		coord.map! do |n|
			temp = n % CC.grid_spacing
			n -= temp if temp < (CC.grid_spacing/2)
			n = n-temp+CC.grid_spacing if temp >= (CC.grid_spacing/2)
			n
		end
		return coord
	end
	
	def sync_diff(stored_time)
		new_time = Time.now.to_f*1000
		return (CC.ms_per_tick - (new_time - (stored_time + CC.ms_per_tick)))
	end
	
	def relative_pos(xd,yd)
		x_sign = nil
		y_sign = nil
		case 
		when xd > 0
			x_sign = "+"
		when xd == 0
			x_sign = "0"
		when xd < 0
			x_sign = "-"
		end
		case
		when yd > 0
			y_sign = "+"
		when yd == 0
			y_sign = "0"
		when yd < 0
			y_sign = "-"
		end
		
		sign = [x_sign,y_sign]
		case sign
		when ["+","+"]
			return "se"
		when ["+","-"]
			return "ne"
		when ["-","-"]
			return "nw"
		when ["-","+"]
			return "sw"
		when ["+","0"]
			return "e"			
		when ["-","0"]
			return "w"
		when ["0","+"]
			return "s"
		when ["0","-"]
			return "n"
		end
	end
	
	def draw_chevron(cr,offset,dir,p)
	  x = p.x
	  y = p.y
	  case dir
	  when "n"
			cr.move_to(x,  y+12+offset)
			cr.line_to(x+5,y+17+offset)
			cr.line_to(x+5,y+21+offset)
			cr.line_to(x,  y+16+offset)
			cr.line_to(x-5,y+21+offset)
			cr.line_to(x-5,y+17+offset)
			cr.line_to(x,  y+12+offset)
	  when "s"
			cr.move_to(x,  y-12-offset)
			cr.line_to(x+5,y-17-offset)
			cr.line_to(x+5,y-21-offset)
			cr.line_to(x,  y-16-offset)
			cr.line_to(x-5,y-21-offset)
			cr.line_to(x-5,y-17-offset)
			cr.line_to(x,  y-12-offset)
		when "e"
			cr.move_to(x-12-offset,y)
			cr.line_to(x-17-offset,y+5)
			cr.line_to(x-21-offset,y+5)
			cr.line_to(x-16-offset,y)
			cr.line_to(x-21-offset,y-5)
			cr.line_to(x-17-offset,y-5)
			cr.line_to(x-12-offset,y)
		when "w"
			cr.move_to(x+12+offset,y)
			cr.line_to(x+17+offset,y+5)
			cr.line_to(x+21+offset,y+5)
			cr.line_to(x+16+offset,y)
			cr.line_to(x+21+offset,y-5)
			cr.line_to(x+17+offset,y-5)
			cr.line_to(x+12+offset,y)
		end
	end
	
	def round_num_to_grid(num)
		temp = num % CC.grid_spacing
		num -= temp if temp < (CC.grid_spacing/2)
		num -= n-temp+CC.grid_spacing if temp >= (CC.grid_spacing/2)
		return num
	end
	
	def color_to_hex(color)
		c_str = "#"
		color.each do |n|
			n = "%x" % (n*127)
			if n.length < 2
				   c_str = "#{c_str}0#{n}"
			else c_str = "#{c_str}#{n}"
			end
		end
		return c_str
	end
	
	def hex_to_color(c_hex)
		color = []
		color[0] = ((c_hex[1..2].hex).to_f/127)
		color[1] = ((c_hex[3..4].hex).to_f/127)
		color[2] = ((c_hex[5..6].hex).to_f/127) 
		return color
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

end