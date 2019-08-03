module Logic_Controls #various reusable functions useful for checks and math

	def round_to_grid(coord) #rounds a coordinate to the nearest snappable grid point
		coord.map! do |n|
			n = n.to_f / 100
			n = (n * RATIO).round
			n = (n * 100) / RATIO
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

end