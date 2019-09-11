require_relative "points"

class Canvas_Control
	include Logic_Controls 
	attr_accessor :travelers, :queued_note_plays, :queued_note_stops
	attr_reader :grid_spacing, :midi_sync, :beats, :ms_per_beat, :dragging, :start_time
	def initialize

		@sel_box      = nil
		@selecting    = false
		@sel_white    = [0.8,0.8,0.8,0.1] 	#selection box colors
		@sel_blue     = [0,0.5,1,0.5]      #selection box colors
		@pointOrigin  = nil
		@pathOrigin   = nil
		@pointMove    = nil
		@dragging     = false
		@diff         = [0,0]
		@nouspoints   = []
		@travelers    = []
		@starters     = []
		@midi_sync    = 0.000
		@pathSourced  = false
		@attempt_path = false
		@ms_per_beat  = 250.000 #default tempo of 120bpm
		@beats        = 4 #number of beats in a whole note -- should be reasonably between 1 and 16
		@beat_note    = 4 #as a fraction of a whole note   -- should be between 2 and 16 via powers of 2
		@grid_spacing = 35
		@queued_note_plays = []
		@queued_note_stops = []
	end
	
	def set_tempo(tempo)
		@ms_per_beat = (1000 * (30 / tempo)) / (@beat_note / 4)
		#puts @ms_per_beat
	end
	
	def canvas_press(event)
		UI::logic_controls.focus = true
		case Active_Tool.get_tool
			when 1
				@sel_box   = [event.x,event.y,event.x,event.y]
				@selecting   = true
			when 2
				@pointOrigin = [event.x,event.y]
			when 3
				@pointMove = [event.x,event.y,event.x,event.y]
			when 4
				@pathOrigin = [event.x,event.y]
		end
	end
	
	def canvas_generic(string) #Used as a pseudo-handler between classes
		case string
		when "path" 
			if !@nouspoints.empty? && @nouspoints.find_all(&:pathable).any?
				@nouspoints = Pl.add_path(@nouspoints)
				@nouspoints, @pathSourced = Pl.cancel_path(@nouspoints)
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
			UI::play.sensitive = false
			UI::stop.sensitive = true
		end

		@nouspoints.find_all(&:traveler_start).each do |n|
			@starters << Starter.new(n)
			UI::canvas.queue_draw
			@queued_note_plays.each {|o| o.play}
			
			if !n.path_to.length.zero?
				n.path_to.each {|p| @travelers << Traveler.new(n.origin,p)}
			end
		end
		
		@stored_time = Time.now.to_f*1000
		canvas_timeout(@ms_per_beat) #Start sequence
		
	end

	def canvas_timeout(secs)
		GLib::Timeout.add(secs) do
			UI::canvas.signal_emit('travel-event') unless !@playing
			false
		end
	end
	
	def canvas_travel
		@queued_note_plays = []
		canvas_stop if !@playing || (@travelers.length == 0 && @starters.length == 0)
		@starters.each  {|s| s.travel}
		@travelers.each {|t| t.travel}
		@travelers.find_all(&:reached).each do
			|t| t.dest.path_to.each {|p| @travelers << Traveler.new(t.dest_origin,p)}
			t.reached = false
		end
		
		@queued_note_stops.each {|n| n.stop}
		@queued_note_plays.each {|n| n.play}
		@starters.reject!(&:remove)
		@travelers.reject!(&:remove)
		@queued_note_stops = []

		canvas_timeout(sync_diff(@stored_time))
		@stored_time += @ms_per_beat
		UI::canvas.queue_draw
	end

	def canvas_stop
		@playing = false
		@travelers = []
		@starters  = []
		@queued_note_plays = []
		@queued_note_stops = []
		@nouspoints.each do |n|
			n.playing = false
			Pm.note_rlse(n.channel,n.note)
		end
		UI::canvas.queue_draw
		UI::play.sensitive = true
		UI::stop.sensitive = false
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
				@ms_per_beat /= 2
			when "--"
				@ms_per_beat *= 2
			end
		end
		UI::t_sig.text = "#{@beats}/#{@beat_note}"
		UI::canvas.queue_draw
	end
	
	def canvas_drag(obj,event)
		@dragging = false
		case
			when (@selecting && @sel_box)
				@dragging = true
				@sel_box[2] = event.x
				@sel_box[3] = event.y
				obj.queue_draw
			when (@pointOrigin)
				@dragging = true
				@pointOrigin[0] = event.x
				@pointOrigin[1] = event.y
			when (@pointMove)
				@dragging = true
				# difference in movement of the point, cumulative until mouse released
				@diff = round_to_grid([(event.x - @pointMove[0]) , (event.y - @pointMove[1])])
				@pointMove[2] = event.x
				@pointMove[3] = event.y
				obj.queue_draw
		end
	end
	
	def canvas_release(obj,event)
		@dragging = false
		case Active_Tool.get_tool
			when 1
				@sel_box = pos_box(@sel_box)
				@nouspoints = Pl.select_points(@sel_box,@nouspoints)
				@sel_box = nil
				@selecting = false
				obj.queue_draw
			when 2 #Add a point where/when the tool is released
				@nouspoints = Pl.add_point(round_to_grid(@pointOrigin),@nouspoints)
				@pointOrigin = nil
				obj.queue_draw
			when 3 #move point(s) designated by the move stencil
				@nouspoints = Pl.move_points(@diff,@nouspoints)
				@pointMove = nil
				@diff = [0,0]
				obj.queue_draw
			when 4 #select singular point
				@nouspoints, @pathSourced = Pl.select_path_point(@pathOrigin,@nouspoints,@pathSourced)
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
			when(@pointMove)
				start_coord = [@pointMove[0],@pointMove[1]]
				end_coord   = [@pointMove[2],@pointMove[3]]
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
		case Active_Tool.get_tool
			when 1
				@nouspoints, @pathSourced = Pl.cancel_path(@nouspoints) 
			when 2
				@nouspoints, @pathSourced = Pl.cancel_path(@nouspoints)
			when 3
				@nouspoints, @pathSourced = Pl.cancel_path(@nouspoints)
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