require_relative "points"

class Canvas_Control
	include Logic_Controls 
	attr_accessor :nouspoints, :travelers, :repeaters, :queued_note_plays, :queued_note_stops, :root_note
	attr_reader :grid_spacing, :midi_sync, :beats, :ms_per_tick, :dragging, :start_time, 
              :root_note, :scale_notes, :scale, :mouse_last_pos
	def initialize
		@mouse_last_pos = nil
		@sel_box      = nil
		@selecting    = false
		@sel_white    = [0.8,0.8,0.8,0.1] 	#selection box colors
		@sel_blue     = [0,0.5,1,0.5]      #selection box colors
		@point_origin = nil
		@path_origin  = nil
		@point_move   = nil
		@dragging     = false
		@diff         = [0,0]
		@nouspoints   = []
		@travelers    = []
		@starters     = []
		@repeaters    = []
		@scale        = "Chromatic"
		@root_note    = 60
		@scale_notes  = []
		set_scale(@scale,@root_note)
		@midi_sync    = 0.000
		@path_sourced = false
		@attempt_path = false
		@ms_per_tick  = 125.000 #default tempo of 120bpm
		@beats        = 4 #number of beats in a whole note -- should be reasonably between 1 and 16
		@beat_note    = 4 #as a fraction of a whole note   -- should be between 2 and 16 via powers of 2
		@grid_spacing = 35
		@queued_note_plays = []
		@queued_note_stops = []
	end

	def set_tempo(tempo)
		@ms_per_tick = (1000 * (15 / tempo)) / (@beat_note / 4)
		#puts @ms_per_tick
	end
	def set_scale(scale_text,root)

		scale = SCALES[scale_text]
		slen = scale.length
		@scale_notes = []
		@scale_notes << root
		
		c = 0
		note = root
		while note < 127
			note += scale[c]
			@scale_notes << note unless note > 127
			c = (c + 1) % slen
		end

		c = 0
		note = root
		while note > 0
			note -= scale.reverse[c]
			@scale_notes << note unless note < 0
			c = (c + 1) % slen
		end
		@scale_notes.sort!

	end
	
	def canvas_generic(string) #Used as a pseudo-handler between classes
		case string
		when "path" 
			if !@nouspoints.empty? && @nouspoints.find_all(&:pathable).any?
				@nouspoints = Pl.add_path(@nouspoints)
				@nouspoints, @path_sourced = Pl.cancel_path(@nouspoints)
				UI::canvas.queue_draw
			end
		when "prop"
			@nouspoints = Pl.modify_properties(@nouspoints)
			Pl.populate_prop(@nouspoints)
			UI::canvas.queue_draw
		end
	end
	
	def canvas_play
		
		if @nouspoints.find(&:traveler_start)
			@playing = true
			@nouspoints.find_all {|n| n.path_to.length > 1}.each {|p| p.path_to.each {|e| p.path_to_memory << e}}
			UI::play.sensitive = false
			UI::stop.sensitive = true
		end

		@nouspoints.find_all(&:traveler_start).each do |n|
			@starters << Starter.new(nil,n,nil)
			UI::canvas.queue_draw
			@queued_note_plays.each {|o| o.play}
			signal_chain(n,n.note)
		end
		@stored_time = Time.now.to_f*1000
		canvas_timeout(@ms_per_tick) #Start sequence
	end

	def canvas_timeout(secs)
		GLib::Timeout.add(secs) do
			UI::canvas.signal_emit('travel-event') unless !@playing
			false
		end
	end
	
	def canvas_travel
		@queued_note_plays = []
		canvas_stop if !@playing               || 
		               (@travelers.length == 0 && 
									  @starters.length  == 0 && 
										@repeaters.length == 0)
		@starters.each  {|s| s.travel}
		@travelers.each {|t| t.travel}
		@repeaters.each {|r| r.repeat}
		@travelers.find_all(&:reached).each do |t|
			signal_chain(t.dest,t.played_note) #Pass the last played note here. Gather the played note from the first traveler creation
			t.reached = false
		end
		
		@queued_note_stops.each {|n| n.stop}
		@queued_note_plays.each {|n| n.play}
		@starters.reject!(&:remove)
		@travelers.reject!(&:remove)
		@repeaters.reject!(&:remove)
		@queued_note_stops = []

		canvas_timeout(sync_diff(@stored_time))
		@stored_time += @ms_per_tick
		UI::canvas.queue_draw
	end
	
	def canvas_stop
		@playing = false
		@starters  = []
		@repeaters = []
		@queued_note_plays = []
		@queued_note_stops = []
		@nouspoints.find_all {|n| n.path_to.length > 1}.each {|p| p.reset_path_to}
		UI::canvas.queue_draw
		@nouspoints.each do |n|
			n.playing = false
			n.repeating = false
			Pm.note_rlse(n.channel,n.note) unless n.note.to_s.include?("+") || n.note.to_s.include?("-")
		end
		@travelers.each do |t|
			Pm.note_rlse(t.dest.channel,t.played_note) unless t.played_note == nil
		end
		@travelers = []
		UI::stop.sensitive = false
		UI::play.sensitive = true
	end
	
	def signal_chain(point,pn) #pn = played note
		case point.play_modes[0]
		when "robin"
			p = point.path_to.first
			if p
				@travelers << Traveler.new(point,p,pn)
				point.path_to.rotate!
			end
		when "split"
			point.path_to.each {|p| @travelers << Traveler.new(point,p,pn)}
		when "portal"
			point.path_to.each do |p|
				@starters << Starter.new(point,p,pn)
				UI::canvas.queue_draw
				@queued_note_plays.each {|o| o.play}
				signal_chain(p,pn)
			end
		when "random"
			p = point.path_to.sample
			if p
				@travelers << Traveler.new(point,p,pn)
				point.path_to.rotate!(rand(point.path_to.length))
			end
		end
	end
	
	def canvas_grid_change(dir)
		prev_beat_note = @beat_note
		case dir
		when "+"
			@beats += 1
			@beats = 16 if @beats > 16
		when "-"
			@beats -= 1
			@beats = 1 if @beats < 1
		when "++"
			@beat_note *= 2
			@beat_note = 16 if @beat_note > 16
		when "--"
			@beat_note /= 2
			@beat_note = 2      if @beat_note < 2
		end
		if @beat_note != prev_beat_note
			case dir
			when "++"
				@ms_per_tick /= 2
			when "--"
				@ms_per_tick *= 2
			end
		end
		UI::t_sig.text = "#{@beats}/#{@beat_note}"
		UI::canvas.queue_draw
	end
	
	def canvas_press(event)
		UI::logic_controls.focus = true
		case Active_Tool.tool_id
			when 1
				@sel_box   = [event.x,event.y,event.x,event.y]
				@selecting   = true
			when 2
				@point_origin = [event.x,event.y]
			when 3
				@point_move = [event.x,event.y,event.x,event.y]
			when 4
				@path_origin = [event.x,event.y]
		end
	end
	def canvas_drag(obj,event)
		@dragging = false
		@mouse_last_pos = [event.x,event.y]
		case
			when (@selecting && @sel_box)
				@dragging = true
				@sel_box[2] = event.x
				@sel_box[3] = event.y
				obj.queue_draw
			when (@point_origin)
				@dragging = true
				@point_origin[0] = event.x
				@point_origin[1] = event.y
			when (@point_move)
				@dragging = true
				# difference in movement of the point, cumulative until mouse released
				@diff = round_to_grid([(event.x - @point_move[0]) , (event.y - @point_move[1])])
				@point_move[2] = event.x
				@point_move[3] = event.y
				obj.queue_draw
		end
	end
	def canvas_release(obj,event)
		@dragging = false
		case Active_Tool.tool_id
			when 1
				unless !@sel_box
					@sel_box = pos_box(@sel_box)
					@nouspoints = Pl.select_points(@sel_box,@nouspoints)
					@sel_box = nil
					@selecting = false
					obj.queue_draw
				end
			when 2 #Add a point where/when the tool is released
				unless !@point_origin
					@nouspoints = Pl.add_point(round_to_grid(@point_origin),@nouspoints)
					@point_origin = nil
					obj.queue_draw
				end
			when 3 #move point(s) designated by the move stencil
				@nouspoints = Pl.move_points(@diff,@nouspoints)
				@point_move = nil
				@diff = [0,0]
				obj.queue_draw
			when 4 #select singular point
				@nouspoints, @path_sourced = Pl.select_path_point(@path_origin,@nouspoints,@path_sourced)
				obj.queue_draw
		end
	end
	
	def canvas_del
		@nouspoints = Pl.delete_points(@nouspoints)
		UI::canvas.queue_draw
	end
	
	def canvas_bg_draw(cr)
		# fill background with black
		cr.set_source_rgb(BLACK)
		cr.paint
		cr.set_source_rgb(BLUGR)
		x = @grid_spacing
		while x < CANVAS_SIZE
			y = @grid_spacing
			while y < CANVAS_SIZE
				cr.circle(x,y,1)
				cr.fill
				y += @grid_spacing
			end
			x += @grid_spacing
		end
		#Handle measure drawing via notches on paths instead of this, maybe
		cr.set_source_rgba(DGREY)
		x = @grid_spacing
		y = CANVAS_SIZE - @grid_spacing
		while x < CANVAS_SIZE
			cr.move_to(x,@grid_spacing)
			cr.line_to(x,CANVAS_SIZE-@grid_spacing)
			cr.set_line_width(1)
			cr.stroke
			x += @grid_spacing*@beats
		end
		y = @grid_spacing
		x = CANVAS_SIZE - @grid_spacing
		while y < CANVAS_SIZE
			cr.move_to(@grid_spacing,y)
			cr.line_to(CANVAS_SIZE-@grid_spacing,y)
			cr.set_line_width(1)
			cr.stroke
			y += @grid_spacing*@beats
		end
	end
	
	def canvas_draw(cr)
		canvas_bg_draw(cr)
		case #These draw events are for in-progress/temporary activities
		when(@sel_box)  
			width  = @sel_box[2] - @sel_box[0]
			height = @sel_box[3] - @sel_box[1]
			
			cr.set_source_rgba(@sel_blue)
			cr.rectangle(@sel_box[0],@sel_box[1],width,height)
			cr.set_line_width(2)
			cr.stroke
		when(@point_move)
			start_coord = [@point_move[0],@point_move[1]]
			end_coord   = [@point_move[2],@point_move[3]]
			start_coord = round_to_grid(start_coord)
			end_coord   = round_to_grid(end_coord)
			
			cr.move_to(start_coord[0],start_coord[1])
			cr.set_source_rgba(RED)
			cr.line_to(end_coord[0],end_coord[1])
			cr.set_line_width(2)
			cr.stroke
			cr.rounded_rectangle(end_coord[0]-10,end_coord[1]-10,20,20,2,2)
			cr.set_line_width(2)
			cr.stroke
		end
		
		#Set the scene if the current tool does not permit a style
		case Active_Tool.tool_id
		when 1
			@nouspoints, @path_sourced = Pl.cancel_path(@nouspoints) 
		when 2
			@nouspoints, @path_sourced = Pl.cancel_path(@nouspoints)
		when 3
			@nouspoints, @path_sourced = Pl.cancel_path(@nouspoints)
		when 4
			@nouspoints = Pl.cancel_selected(@nouspoints)
		end
	
		#Draw all the points and paths last
		#Paths are behind points, so draw them first
		@nouspoints.each        { |n| n.path_draw(cr) }
		@nouspoints.each        { |n| n.draw(cr) }
		

	end
end

CC = Canvas_Control.new