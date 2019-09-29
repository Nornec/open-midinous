class Point_Logic
	include Logic_Controls
	
	def initialize
		@prop_names       = ["Note",
										  	 "Velocity",
										  	 "Duration (beats)",
										  	 "Channel",
										  	 "Repeat",
										  	 "X-coordinate",
										  	 "Y-coordinate",
										  	 "Color",
										  	 "Path Mode",
										  	 "Signal Start",
										  	 "Play Mode"]
		@prop_names_multi = ["Note",
		                     "Velocity",
												 "Duration (beats)",
												 "Channel",
												 "Repeat",
												 "Color",
												 "Signal Start",
												 "Play Mode"]
		@prop_names_adv = []
		@prop_names_adv_multi = []
		@curr_prop = nil
		@curr_prop_adv = nil
		@mempoints = []
		@mempointsbuff = []
		@copy_pos = []
		@copy_type = nil
		@paste_count = 0
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
	
	def set_path_mode(mode)
		CC.nouspoints.find_all(&:selected).each {|n| n.path_mode = mode}
		UI::canvas.queue_draw
	end
	def set_note(inc)
		CC.nouspoints.find_all(&:selected).each do |n|
			signed = n.note
			val = n.note.to_i
			val += inc
			if val >= 0
				n.note = "+#{val}"
			else n.note = val
			end
			if !(signed.to_s.include?("+") || signed.to_s.include?("-"))
				n.note = n.note.to_i
				n.note = n.note.clamp(0,127)
			end
		end
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		populate_prop(CC.nouspoints)
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
	
	def select_all
		CC.nouspoints.each {|n| n.selected = true} unless CC.nouspoints == []
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		populate_prop(CC.nouspoints)
		UI::canvas.queue_draw
	end
	def copy_points (type)
		return if CC.nouspoints.empty?
		origins = []
		CC.nouspoints.find_all(&:selected).each {|n| origins << n.origin}
		@copy_pos = origins.min
		@copy_type = type
		@mempointsbuff = CC.nouspoints.find_all(&:selected)
	end		
	def paste_points
		return if @mempointsbuff.empty?
		UI::prop_list_model.clear
		UI::prop_mod.text = ""
		
		copy_lookup = {}

		
		# Clone the points and track old point => new point
		@mempointsbuff.each do |n|
				n.selected = false if @copy_type == "copy"
				mem_point = n.clone
				@mempoints << mem_point
				copy_lookup[n.object_id] = mem_point
		end

		# Update the point relations
		@mempoints.each do |n|
				n.path_to   = n.path_to.map   { |pt| copy_lookup[pt.object_id] }.compact
				n.path_from = n.path_from.map { |pf| copy_lookup[pf.object_id] }.compact
		end
		
		@paste_count = 0 if @copy_type == "copy"
		CC.nouspoints.reject!(&:selected) if @copy_type == "cut" && @paste_count == 0
		@paste_count += 1

		paste_pos = CC.mouse_last_pos
		diff = round_to_grid([paste_pos[0] - @copy_pos[0],paste_pos[1] - @copy_pos[1]])
		@mempoints.each {|m| m.set_destination(diff)}
		@mempoints.each {|m| CC.nouspoints << m} if paste_check(diff,@mempoints)
		@mempoints = []
		populate_prop(CC.nouspoints)
		UI::canvas.queue_draw
	end
	def paste_check(diff,memp)
		memp.each {|m| return false if CC.nouspoints.any? { |n| n.origin == m.origin}}
		return true
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
									 point.repeat_memory,
									 point.x,
									 point.y,
									 color_to_hex(point.default_color),
									 point.path_mode,
									 point.traveler_start,
									 point.play_modes[0]]
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
					points.find_all(&:selected).each {|p| equalizer << p.note}
				when "Velocity"
					points.find_all(&:selected).each {|p|	equalizer << p.velocity}
				when "Duration (beats)"
					points.find_all(&:selected).each {|p| equalizer << p.duration}
				when "Channel"
					points.find_all(&:selected).each {|p| equalizer << p.channel}
				when "Color"
					points.find_all(&:selected).each {|p| equalizer << color_to_hex(p.default_color)}
				when "Signal Start"
					points.find_all(&:selected).each {|p| equalizer << p.traveler_start}
				when "Play Mode"
					points.find_all(&:selected).each {|p| equalizer << p.play_modes[0]}
				when "Repeat"
					points.find_all(&:selected).each {|p| equalizer << p.repeat_memory}
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
		play_modes = ["robin","split","portal","random"]
		path_modes = ["horz","vert"]
		signal_states = ["true","false"]
		case @curr_prop
			when "Note"
				if (text.to_i >= 1 && text.to_i <= 127) || (text.match(/^([+]|-)[0-9]{1,2}$/))
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Velocity"
				if (text.to_i >= 1 && text.to_i <= 127)
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
				if path_modes.include? text
						 UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Signal Start"
				if signal_states.include? text
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Play Mode"
				if play_modes.include? text
					   UI::prop_mod_button.sensitive = true
				else UI::prop_mod_button.sensitive = false
				end
			when "Repeat"
				if text.to_i >= 0 && text.to_i <= 128
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
					if UI::prop_mod.text.match(/^([+]|-)[0-9]{1,2}$/)
						unless p.traveler_start == true
							p.note = UI::prop_mod.text
							p.use_rel = true
						end
					elsif (UI::prop_mod.text.to_i >= 0 &&
					       UI::prop_mod.text.to_i <= 127 &&
								!(UI::prop_mod.text.include?("+") || UI::prop_mod.text.include?("-")))
					then
						p.note = UI::prop_mod.text.to_i
						p.use_rel = false
					end
				end
			when "Velocity"
				points.find_all(&:selected).each {|p| p.velocity = UI::prop_mod.text.to_i}
			when "Duration (beats)"
				points.find_all(&:selected).each {|p| p.duration = UI::prop_mod.text.to_i}
			when "Channel"
				points.find_all(&:selected).each {|p| p.channel = UI::prop_mod.text.to_i}
			when "X-coordinate"
				points.find(&:selected).x = UI::prop_mod.text.to_i
			when "Y-coordinate"
				points.find(&:selected).y = UI::prop_mod.text.to_i
			when "Color"
				points.find_all(&:selected).each {|p| p.set_default_color(hex_to_color("##{UI::prop_mod.text}"))}
			when "Path Mode"
				points.find(&:selected).path_mode = UI::prop_mod.text
			when "Signal Start"
				case UI::prop_mod.text
				when "true"
					points.find_all(&:selected).each {|p| p.traveler_start = true}
				when "false"
					points.find_all(&:selected).each {|p| p.traveler_start = false}
				end
			when "Play Mode"
				if UI::prop_mod.text == "robin" || UI::prop_mod.text == "portal"
					points.find_all(&:selected).each {|p| p.play_modes.rotate! until p.play_modes[0] == UI::prop_mod.text}
				else
					points.find_all {|p| p.selected == true && p.path_to.length > 1}.each {|p| p.play_modes.rotate! until p.play_modes[0] == UI::prop_mod.text}
				end
			when "Repeat"
				points.find_all(&:selected).each do |p| 
					p.repeat = UI::prop_mod.text.to_i
					p.repeat_memory = UI::prop_mod.text.to_i
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
	
	def play_mode_rotate(dir)
		CC.nouspoints.find_all(&:selected).each do |n|
			if n.path_to.length <= 1
				case n.play_modes[0]
				when "robin"
					n.play_modes.rotate!(dir)	until n.play_modes[0] == "portal"
				when "portal"
					n.play_modes.rotate!(dir)	until n.play_modes[0] == "robin"
				end
			else
				n.play_modes.rotate!(dir)
			end
			UI::canvas.queue_draw
		end
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
	def delete_paths_to(points)
		points.find_all {|f| !f.path_to.length.zero? && f.selected == true}.each {|n| n.path_to.each {|b| b.path_from.reject! {|g| g == n }}}
		points.find_all {|f| !f.path_to.length.zero? && f.selected == true}.each {|n| n.path_to = []}
		UI::canvas.queue_draw
	end
	def delete_paths_from(points)
		points.find_all {|f| !f.path_from.length.zero? && f.selected == true}.each {|n| n.path_from.each {|b| b.path_to.reject! {|g| g == n }}}
		points.find_all {|f| !f.path_from.length.zero? && f.selected == true}.each {|n| n.path_from = []}
		UI::canvas.queue_draw
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
	
	def set_start
		CC.nouspoints.find_all(&:selected).each do |n| 
			if n.traveler_start == false
				n.traveler_start = true
			elsif n.traveler_start == true
				n.traveler_start = false
			end 
		end
		UI::canvas.queue_draw
		populate_prop(CC.nouspoints)
	end
	
end

class NousPoint
	include Logic_Controls
	attr_accessor :source, :color, :path_to, :path_from, :note, :x, :y,
	              :velocity, :duration, :default_color, :path_mode, 
								:traveler_start, :channel, :playing, :play_modes,
								:path_to_memory, :repeat, :repeat_memory, :repeating,
								:use_rel, :selected, :save_id
	attr_reader   :pathable, :origin, :bounds

	def initialize(o) #where the point was initially placed
		@dp = [4,8,10,12,14,16,20]
		
		@x = o[0]
		@y = o[1]
		@origin = o
		@bounds = [@x-@dp[5],@y-@dp[5],@x+@dp[5],@y+@dp[5]]
		@color           = GREY #point color defaults to gray++
		@path_color      = CYAN
		@default_color   = GREY
		@note            = 60                         #all notes start at middle c (C3), can be a note or a reference
		@velocity        = 100		                    #       ``       with 100 velocity
		@channel         = 1                          #       ``       assigned to midi channel 1 (instrument 1, but we will refer to them as channels, not instruments)
		@duration        = 1                          #length of note in grid points (should be considered beats)
		@repeat          = 0                          #Number of times the node should repeat before moving on
		@repeat_memory   = 0
		@save_id         = -1
		@play_modes      = ["robin","split","portal","random"]
		@traveler_start  = false
		@playing         = false
		@pathable        = false
		@selected        = false
		@source          = false
		@repeating       = false
		@use_rel         = false
		@path_to         = [] #array of references to points that are receiving a path from this point
		@path_to_memory  = [] #memory of @path_to so that it can be reset upon stopping.
		@path_to_rels    = []
		@path_from_rels  = []
		@path_from       = [] #array of references to points that are sending a path to this point
		@path_mode       = "horz"
		@chev_offsets    = [0,0,0,0]
	end
	
	def set_rels
		path_to.each {|pt| @path_to_rels << pt.save_id}
		path_from.each {|pf| @path_from_rels << pf.save_id}
	end
	
	def write_props(file)
		set_rels
		file.write("#{@save_id}<~>")   
		file.write("#{@origin}<~>")
		file.write("#{@note}<~>")
		file.write("#{@velocity}<~>")
		file.write("#{@channel}<~>")       
		file.write("#{@duration}<~>") 
		file.write("#{color_to_hex(@color)}<~>")		
		file.write("#{@repeat}<~>")        
		file.write("#{@play_modes}<~>")    
		file.write("#{@traveler_start}<~>")                       
		file.write("#{@use_rel}<~>")               
		file.write("#{@path_mode}<~>")
		file.write("#{@path_to_rels}")
		file.write("#{@path_from_rels}")
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
	
	def reset_path_to
		@path_to = []
		@path_to_memory.each {|p| @path_to << p}
		@path_to_memory = []
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
		case @play_modes[0]
		when "robin"
			@path_color = CYAN
			if @path_to.length > 1
				cr.move_to(@x-8,@y)
				cr.line_to(@x+6,@y-9)
				cr.set_line_width(2)
				cr.stroke
				cr.move_to(@x-8,@y)
				cr.set_dash([1,4],0)
				cr.line_to(@x+6,@y+9)
				cr.set_line_width(2)
				cr.stroke
				cr.set_dash([],0)
			else
				cr.circle(@x,@y,1)
				cr.fill
			end
		when "split"
			@path_color = CYAN
			cr.move_to(@x-8,@y)
			cr.line_to(@x+6,@y-9)
			cr.move_to(@x-8,@y)
			cr.line_to(@x+6,@y+9)
			cr.set_line_width(2)
			cr.stroke
		when "portal"
			@path_color = RED
			cr.circle(@x,@y,6)
			cr.set_line_width(2)
			cr.stroke
		when "random"
			@path_color = VLET
			cr.rectangle(@x-6,@y-2,8,8)
			cr.rectangle(@x-2,@y-6,8,8)
			cr.set_line_width(2)
			cr.stroke
		end
		
		if @repeat_memory > 0
			#cr.move_to(@x-@dp[2],@y-@dp[2]) #top left of the point graphic
			if @traveler_start
				cr.move_to(@x+3,@y-@dp[2]-2)
				cr.line_to(@x-2,-6+@y-@dp[2]-2)
				cr.line_to(@x-2,6+@y-@dp[2]-2)
				cr.line_to(@x+3,@y-@dp[2]-2)
				cr.fill
				cr.move_to(@x-3,@y+@dp[2]+2)
				cr.line_to(@x+2,-6+@y+@dp[2]+2)
				cr.line_to(@x+2,6+@y+@dp[2]+2)
				cr.line_to(@x-3,@y+@dp[2]+2)
				cr.fill
			else
				cr.move_to(@x-2,@y-@dp[2])
				cr.line_to(@x-7,-6+@y-@dp[2])
				cr.line_to(@x-7,6+@y-@dp[2])
				cr.line_to(@x-2,@y-@dp[2])
				cr.fill
				cr.move_to(@x+2,@y+@dp[2])
				cr.line_to(@x+7,-6+@y+@dp[2])
				cr.line_to(@x+7,6+@y+@dp[2])
				cr.line_to(@x+2,@y+@dp[2])
				cr.fill
			end
		end
		
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
		repeat_draw(cr) if @repeating
	end
	
	def path_draw(cr)
		if !@selected
		
			cr.set_source_rgba(@path_color[0],@path_color[1],@path_color[2],0.6)
			@path_to.each {|t| trace_path_to(cr,t)}
			
		elsif @selected
			
			cr.set_source_rgba(LGRN[0],LGRN[1],LGRN[2],0.8)
			@path_to.each   {|t| trace_path_to(cr,t)}
			cr.set_line_cap(1)    #Round
			cr.set_line_join(2)   #Miter
			cr.set_line_width(3)
			cr.stroke
			
		end
		cr.set_dash([],0)
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
	def repeat_draw(cr)
		cr.set_source_rgb(@color[0],@color[1],@color[2])
		cr.rounded_rectangle(@x-@dp[2]+3,@y-@dp[2]+3,@dp[6]-6,@dp[6]-6,2,2)
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
		
		case @play_modes[0]
		when "robin"
			cr.set_dash([5,5],0)
			if @path_to[0] == t
				cr.set_dash([],0)
			end
		when "portal"
			cr.set_dash([1,5],0)
		end
		
		rel_pos = relative_pos(t.x-@x,t.y-@y)
		case rel_pos
		when "n"
			cr.move_to(@x,@y-10)
			cr.line_to(t.x,t.y+10)
		when "s"
			cr.move_to(@x,@y+10)
			cr.line_to(t.x,t.y-10)
		when "e"
			cr.move_to(@x+10,@y)
			cr.line_to(t.x-10,t.y)
		when "w"
			cr.move_to(@x-10,@y)
			cr.line_to(t.x+10,t.y)
		end
		
		case @path_mode
		when "horz"
			case rel_pos
			when "ne"
				cr.move_to(@x+10,@y)
				cr.line_to(t.x,@y)
				cr.line_to(t.x,t.y+10)
			when "nw"
				cr.move_to(@x-10,@y)
				cr.line_to(t.x,@y)
				cr.line_to(t.x,t.y+10)
			when "se"
				cr.move_to(@x+10,@y)
				cr.line_to(t.x,@y)
				cr.line_to(t.x,t.y-10)
			when "sw"
				cr.move_to(@x-10,@y)
				cr.line_to(t.x,@y)
				cr.line_to(t.x,t.y-10)
			end
		when "vert"
			case rel_pos
			when "ne"
				cr.move_to(@x,@y-10)
				cr.line_to(@x,t.y)
				cr.line_to(t.x-10,t.y)
			when "nw"
				cr.move_to(@x,@y-10)
				cr.line_to(@x,t.y)
				cr.line_to(t.x+10,t.y)
			when "se"
				cr.move_to(@x,@y+10)
				cr.line_to(@x,t.y)
				cr.line_to(t.x-10,t.y)
			when "sw"
				cr.move_to(@x,@y+10)
				cr.line_to(@x,t.y)
				cr.line_to(t.x+10,t.y)
			end
		when "line"
			cr.move_to(@x,@y)
			cr.line_to(t.x,t.y)
		end
		cr.set_line_cap(1)    #Round
		cr.set_line_join(2)   #Miter
		cr.set_line_width(3)
		cr.stroke
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
	attr_reader :remove, :dest, :dest_origin, :last_played_note, :played_note
	attr_accessor :reached
	def initialize(srce,dest,lpn) #Traveler should play note when reaches destination. Should not need to create another traveler if it's a dead end.
		@srce        = srce
		@dest        = dest
		@srce_origin = srce.origin
		@dest_origin = dest.origin
		@repeat      = dest.repeat
		@travel_c    = 0
		@iteration   = 0
		@last_played_note = lpn
		@played_note = nil
		@distance    = ((@dest_origin[0] - @srce_origin[0]).abs + (@dest_origin[1] - @srce_origin[1]).abs)/CC.grid_spacing
		@reached     = false
		@remove      = false
	end

	def travel
		@travel_c += 1
		if @travel_c == @distance
			@dest.playing = true
			@reached = true
			play_check(@srce.use_rel,@dest.use_rel)
		elsif @travel_c == (@distance + @dest.duration) 
			@dest.playing = false
			queue_removal
		end
	end
	
	def play_check(srce_rel,dest_rel)
		if !dest_rel
			@played_note = @dest.note
			play_note
		elsif  srce_rel && dest_rel
			@played_note = @last_played_note + @dest.note.to_i
			play_relative
		elsif !srce_rel && dest_rel
			@played_note = @srce.note.to_i + @dest.note.to_i
			play_relative
		end
	end
	def play_note
		CC.queued_note_plays << NoteSender.new(@played_note,@dest.channel,@dest.velocity)
	end
	def play_relative
		#search the current scales variable and round to nearest note.
		if @dest.note.include?("+")
			@played_note = CC.scale_notes.find {|f| f >= @played_note}
		elsif @dest.note.include?("-")
			@played_note = CC.scale_notes.reverse_each.find {|f| f <= @played_note}
		end
		@played_note = @played_note.clamp(0,127)
		
		CC.queued_note_plays << NoteSender.new(@played_note,@dest.channel,@dest.velocity)
	end
	
	def queue_removal
		CC.queued_note_stops << NoteSender.new(@played_note,@dest.channel,0)
		if @repeat > 0
			CC.repeaters << Repeater.new(@dest,@repeat,@played_note)
		end
		@remove = true
	end
	
end

class Starter #A starter handles notes that are used as starting points for paths and point jumps for portals
	attr_reader :remove, :last_played_note
	def initialize(portal_srce,srce,lpn)
		@travel_c         = 0
		@srce             = srce
		@portal_srce      = portal_srce
		@duration         = srce.duration
		@remove           = false
		@repeat           = srce.repeat
		@played_note      = nil
		@last_played_note = lpn
		
		@srce.playing     = true	
		if @portal_srce != nil
			play_check(@portal_srce.use_rel,@srce.use_rel)
		else
			@played_note = @srce.note
			play_note
		end
		
	end
	
	def travel
		@travel_c += 1
		if @travel_c == @duration
			@srce.playing = false
			if @repeat > 0
				CC.repeaters << Repeater.new(@srce,@repeat,@played_note)
			end
			CC.queued_note_stops << NoteSender.new(@played_note,@srce.channel,0)
		else
			@remove = true
		end
	end

	def play_check(portal_srce_rel,srce_rel)
		if !srce_rel
			@played_note = @srce.note
			play_note
		elsif  portal_srce_rel && srce_rel
			@played_note = @last_played_note + @srce.note.to_i
			play_relative
		elsif !portal_srce_rel && srce_rel
			@played_note = @portal_srce.note.to_i + @srce.note.to_i
			play_relative
		end
	end
	def play_note
		CC.queued_note_plays << NoteSender.new(@played_note,@srce.channel,@srce.velocity)
	end
	def play_relative
		#search the current scales variable and round to nearest note.
		if @srce.note.include?("+")
			@played_note = CC.scale_notes.find {|f| f >= @played_note}
		elsif @srce.note.include?("-")
			@played_note = CC.scale_notes.reverse_each.find {|f| f <= @played_note}
		end
		@played_note = @played_note.clamp(0,127)
		
		CC.queued_note_plays << NoteSender.new(@played_note,@srce.channel,@srce.velocity)
	end	
	
end

class Repeater #A repeater handles notes that are set to repeat/arpeggiate
	attr_reader :remove
	def initialize(srce,count,played_note)
		@srce   = srce
		@dur    = srce.duration
		@timer  = count * @dur
		@played_note = played_note
		repeat
	end
	
	def repeat
		if @timer == 0
			#needs relative logic
			CC.queued_note_stops << NoteSender.new(@played_note,@srce.channel,0)
			@srce.repeating = false
			@remove = true
		end
		unless @remove == true
			@srce.repeating = true
			CC.queued_note_plays << NoteSender.new(@played_note,@srce.channel,@srce.velocity) if @timer % @dur == 0
		end
		@timer -=1
	end
	
end

Pl = Point_Logic.new