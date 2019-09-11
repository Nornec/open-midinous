class Point_Logic
	include Logic_Controls
	
	def initialize
		@prop_names = ["Note","Velocity","Duration (beats)","Channel","X-coordinate","Y-coordinate","Color","Path Mode","Signal Start"]
		@prop_names_multi = ["Note","Velocity","Duration (beats)","Channel","Color","Signal Start"]
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
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		box_origin = [box[0],box[1]] #box is an array with 4 values
		points.each do |n|
			if check_bounds(n.origin,box)
					 n.select
			elsif check_bounds(box_origin,n.bounds)
					 n.select
			else 
				n.deselect
				UI::prop_list_model.clear
				UI::prop_mod.text = ""
			end
		end
		populate_prop(points)
		return points
	end
	
	def populate_prop (points)
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		point = nil
		point = points.find(&:selected) if points.find_all(&:selected).length == 1
		if point
		  prop_vals = [point.note,
			             point.velocity,
									 point.duration,
									 point.channel,
									 point.x,
									 point.y,
									 color_to_hex(point.default_color),
									 point.path_mode,
									 point.traveler_start]
			@prop_names.each	do |v|
				iter = UI::prop_list_model.append
				iter[0] = v
				iter[1] = prop_vals[@prop_names.find_index(v)].to_s
			end
		elsif points.find_all(&:selected).length > 1
			@prop_names_multi.each do |v|
				equalizer = []
				iter = UI::prop_list_model.append
				iter[0] = v
				case v
				when "Note"
					points.find_all(&:selected).each do |p|
						equalizer << p.note
					end
				when "Velocity"
					points.find_all(&:selected).each do |p|
						equalizer << p.velocity
					end
				when "Duration (beats)"
					points.find_all(&:selected).each do |p|
						equalizer << p.duration
					end
				when "Channel"
					points.find_all(&:selected).each do |p|
						equalizer << p.channel
					end
				when "Color"
					points.find_all(&:selected).each do |p|
						equalizer << color_to_hex(p.default_color)
					end
				when "Signal Start"
					points.find_all(&:selected).each do |p|
						equalizer << p.traveler_start
					end
				end
				if equalizer.uniq.count == 1 
					iter[1] = equalizer[0].to_s
				else iter[1] = "Multiple Values"
				end
			end
		else
			UI::prop_list_model.clear
			UI::prop_mod.text = ""
		end
		
		
	end	
	def prop_list_select(selected)
		return if selected == nil
		@curr_prop = selected[0]
		if   selected[1][0] == "#"
				 UI::prop_mod.text = selected[1][1..6]
		else UI::prop_mod.text = selected[1]
		end
		UI::prop_mod.position = 0
		UI::prop_mod.grab_focus
	end
	
	def check_input(text)
		case @curr_prop
			when "Note", "Velocity"
				if text.to_i >= 1 && text.to_i <= 127
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Duration (beats)"
				if text.to_i >= 1 && text.to_i <= 1000
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Channel"
				if text.to_i >= 1 && text.to_i <= 16
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "X-coordinate", "Y-coordinate"
				if round_num_to_grid(text.to_i) >= CC.grid_spacing && 
				   round_num_to_grid(text.to_i) <= (CANVAS_SIZE - CC.grid_spacing)
				then
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Color"
				if text.match(/^[0-9A-Fa-f]{6}$/)
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Path Mode"
				if text == "horz" || text == "vert"
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Signal Start"
				if text == "true" || text == "false"
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			else UI::prop_mod_button.sensitive = false
		end
	end
	
	def modify_properties(points)
		case @curr_prop
			when "Note"
				points.find_all(&:selected).each do |p|
					p.note = UI::prop_mod.text.to_i
				end
			when "Velocity"
				points.find_all(&:selected).each do |p|
					p.velocity = UI::prop_mod.text.to_i
				end
			when "Duration (beats)"
				points.find_all(&:selected).each do |p|
					p.duration = UI::prop_mod.text.to_i
				end
			when "Channel"
				points.find_all(&:selected).each do |p|
					p.channel = UI::prop_mod.text.to_i
				end
			when "X-coordinate"
				points.find(&:selected).x = UI::prop_mod.text.to_i
			when "Y-coordinate"
				points.find(&:selected).y = UI::prop_mod.text.to_i
			when "Color"
				points.find_all(&:selected).each do |p|
					p.set_default_color(hex_to_color("##{UI::prop_mod.text}"))
				end
			when "Path Mode"
				points.find(&:selected).path_mode = UI::prop_mod.text
			when "Signal Start"
				case UI::prop_mod.text
					when "true"
						points.find_all(&:selected).each do |p|
							p.traveler_start = true
						end
					when "false"
						points.find_all(&:selected).each do |p|
							p.traveler_start = false
						end
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
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		return points
	end
	
	def move_points(diff,points)
		if move_check(diff,points)
			points.find_all(&:selected).each {|n| n.set_destination(diff) }	
			UI::prop_list_model.clear
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
	include Logic_Controls
	attr_accessor :source, :color, :path_to, :path_from, :note, :x, :y,
	              :velocity, :duration, :default_color, :path_mode, 
								:traveler_start, :channel, :playing
	attr_reader :selected, :pathable, :origin, :bounds
	
	def initialize(o) #where the point was initially placed
		@dp = [4,8,10,12,14,16,20]
		
		@x = o[0]
		@y = o[1]
		@origin = o
		@bounds = [@x-@dp[5],@y-@dp[5],@x+@dp[5],@y+@dp[5]]
		@color          = GREY #point color defaults to gray++
		@path_color     = CYAN
		@default_color  = GREY
		@note           = 60                         #all notes start at middle c
		@velocity       = 100		                     #       ``       with 100 velocity
		@channel        = 1                          #       ``       assigned to midi channel 1 (instrument 1, but we will refer to them as channels, not instruments)
		@duration       = 1                          #length of note in grid points (should be considered beats)
		@traveler_start = false
		@playing        = false
		@pathable       = false
		@selected       = false
		@source         = false
		@path_to        = [] #array of references to points that are receiving a path from this point
		@path_from      = [] #array of references to points that are sending   a path to   this point
		@path_mode      = "horz"
		@chev_offsets   = [0,0,0,0]
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
		@bounds = [@x-@dp[5],@y-@dp[5],@x+@dp[5],@y+@dp[5]]
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
		@bounds = [@x-@dp[5],@y-@dp[5],@x+@dp[5],@y+@dp[5]]
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
		if @traveler_start
			traveler_start_draw(cr)
		else
			cr.rounded_rectangle(@x-@dp[1],@y-@dp[1],@dp[5],@dp[5],2,2) #slightly smaller rectangle adds 'relief' effect
		end
		cr.fill
		
		cr.set_source_rgba(@color[0],@color[1],@color[2],1)
		cr.circle(@x,@y,1)
		cr.fill
		
		if !@selected
			if @traveler_start
				traveler_start_draw(cr)
			else
				cr.rounded_rectangle(@x-@dp[2],@y-@dp[2],@dp[6],@dp[6],2,2)
			end
		end
		if @selected
			cr.set_source_rgba(1,1,1,0.8)
			if @traveler_start			
				traveler_start_draw(cr)
			else
				cr.rounded_rectangle(@x-@dp[2],@y-@dp[2],@dp[6],@dp[6],2,2) #a slightly smaller rectangle adds 'relief' effect
			end
			selection_caret_draw(cr)
		end
		cr.set_line_width(2)
		cr.stroke
		play_draw(cr) if @playing
	end
	
	def path_draw(cr)
		if !@selected
		
			cr.set_source_rgba(@path_color[0],@path_color[1],@path_color[2],0.6)
			@path_to.each {|t| trace_path_to(cr,t)}
			cr.set_line_cap(1)    #Round
			cr.set_line_join(2)   #Miter
			cr.set_line_width(3)
			cr.stroke
			
		elsif @selected
		
			#cr.set_source_rgba(ORNGE[0],ORNGE[1],ORNGE[2],0.8)
			#@path_from.each {|s| trace_path_from(cr,s)}
			#cr.set_line_cap(1)    #Round
			#cr.set_line_join(2)   #Miter
			#cr.set_line_width(3)
			#cr.stroke
			
			cr.set_source_rgba(LGRN[0],LGRN[1],LGRN[2],0.8)
			@path_to.each   {|t| trace_path_to(cr,t)}
			cr.set_line_cap(1)    #Round
			cr.set_line_join(2)   #Miter
			cr.set_line_width(3)
			cr.stroke
			
		end
		
		@chev_offsets = [0,0,0,0]
		@path_from.each do |s| 
			input_mark_draw(cr,relative_pos(@x-s.x,@y-s.y),s)
			cr.set_source_rgba(s.color[0],s.color[1],s.color[2],1)
			cr.fill
		end

	end
	def play_draw(cr) #If a note is playing, show a visual indicator
		cr.set_source_rgb(@color[0],@color[1],@color[2])
		if @traveler_start
			traveler_start_draw(cr)
		else
			cr.rounded_rectangle(@x-@dp[2],@y-@dp[2],@dp[6],@dp[6],2,2)
		end
		cr.fill
	end
	
	def traveler_start_draw(cr) #Shape of a traveler start position
		cr.move_to(@x-@dp[0],@y-@dp[3])
		cr.line_to(@x+@dp[0],@y-@dp[3])
		cr.line_to(@x+@dp[1],@y-@dp[1])
		cr.line_to(@x+@dp[1],@y+@dp[1])
		cr.line_to(@x+@dp[0],@y+@dp[3])
		cr.line_to(@x-@dp[0],@y+@dp[3])
		cr.line_to(@x-@dp[1],@y+@dp[1])
		cr.line_to(@x-@dp[1],@y-@dp[1])
		cr.line_to(@x-@dp[0],@y-@dp[3])
	end
	def selection_caret_draw(cr) #Shape of a selection caret
		cr.move_to(@x-@dp[4],@y-@dp[4])
		cr.line_to(@x-@dp[2],@y-@dp[4])
		cr.move_to(@x-@dp[4],@y-@dp[4])
		cr.line_to(@x-@dp[4],@y-@dp[2])

		cr.move_to(@x+@dp[4],@y-@dp[4])
		cr.line_to(@x+@dp[2],@y-@dp[4])
		cr.move_to(@x+@dp[4],@y-@dp[4])
		cr.line_to(@x+@dp[4],@y-@dp[2])
					
		cr.move_to(@x-@dp[4],@y+@dp[4])
		cr.line_to(@x-@dp[2],@y+@dp[4])
		cr.move_to(@x-@dp[4],@y+@dp[4])
		cr.line_to(@x-@dp[4],@y+@dp[2])
					
		cr.move_to(@x+@dp[4],@y+@dp[4])
		cr.line_to(@x+@dp[2],@y+@dp[4])
		cr.move_to(@x+@dp[4],@y+@dp[4])
		cr.line_to(@x+@dp[4],@y+@dp[2])
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
		case s.path_mode
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
	
	def input_mark_draw(cr,rel_pos,s)
		if    s.path_mode == "horz"
			case rel_pos
			when "n","ne","nw"
				draw_chevron(cr,@chev_offsets[0],"n",self)
				@chev_offsets[0] += 5
			when "s","se","sw"
				draw_chevron(cr,@chev_offsets[1],"s",self)
				@chev_offsets[1] += 5
			when "e"
				draw_chevron(cr,@chev_offsets[2],"e",self)
				@chev_offsets[2] += 5
			when "w"
				draw_chevron(cr,@chev_offsets[3],"w",self)
				@chev_offsets[3] += 5
			end
		elsif s.path_mode == "vert"
			case rel_pos
			when "n"
				draw_chevron(cr,@chev_offsets[0],"n",self)
				@chev_offsets[0] += 5
			when "s"
				draw_chevron(cr,@chev_offsets[1],"s",self)
				@chev_offsets[1] += 5
			when "e","ne","se"
				draw_chevron(cr,@chev_offsets[2],"e",self)
				@chev_offsets[2] += 5
			when "w","nw","sw"
				draw_chevron(cr,@chev_offsets[3],"w",self)
				@chev_offsets[3] += 5
			end
		end
	end
	
end

class Traveler #A traveler handles the source note playing and creates another traveler if the destination is reached.
	attr_reader :remove, :dest, :dest_origin
	attr_accessor :reached
	def initialize(srce_origin,dest) #Traveler should play note when reaches destination. Should not need to create another traveler if it's a dead end.
		@srce_origin = srce_origin
		@dest_origin = dest.origin
		@dest        = dest
		@travel_c    = 0
		@distance    = ((@dest_origin[0] - @srce_origin[0]).abs + (@dest_origin[1] - @srce_origin[1]).abs)/CC.grid_spacing
		@reached     = false
		@remove      = false
	end

	def travel
		@travel_c += 1
		if @travel_c == @distance
			@reached = true
			@dest.playing = true
			CC.queued_note_plays << NoteSender.new(@dest.note,@dest.channel,@dest.velocity)
		elsif @travel_c == (@distance + @dest.duration)
			@dest.playing = false
			queue_removal
		end
	end
	
	def queue_removal
		CC.queued_note_stops << NoteSender.new(@dest.note,@dest.channel,0)
		@remove = true
	end
	
end

class Starter #A starter handles notes that are used as starting points for paths.
	attr_reader :remove
	def initialize(srce)
		@travel_c     = 0
		@srce         = srce
		@duration     = @srce.duration
		@remove       = false
		@srce.playing = true
		CC.queued_note_plays << NoteSender.new(@srce.note,@srce.channel,@srce.velocity)
	end
	
	def travel
		@travel_c += 1
		if @travel_c == @duration
			@srce.playing = false
			CC.queued_note_stops << NoteSender.new(@srce.note,@srce.channel,0)
			@remove = true
		end
	end
	
end

Pl = Point_Logic.new