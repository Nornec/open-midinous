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
		return (CC.ms_per_beat - (new_time - (stored_time + CC.ms_per_beat)))
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