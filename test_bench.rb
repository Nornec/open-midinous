$nouspoints.length.times do |n| #move coordinate point check
	if $nouspoints[n].is_selected
		dest_coord = $nouspoints[n].get_origin
		dest_coord[0] += @diff[0]
		dest_coord[1] += @diff[1]
		
		$nouspoints.length.times do |g|
			if dest_coord == $nouspoints[g].get_origin && $nouspoints[g].is_selected == false
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

----------------------------------------------------------------------------------------

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
			
			
----------------------------------------------------------------------------------------------

