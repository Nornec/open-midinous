require_relative "points"

class Canvas_Control
	include Logic_Controls 

	def initialize
		@sel_box     = nil
		@selecting   = false
		@sel_white   = [0.8,0.8,0.8,0.1] 	#selection box colors
		@sel_blue    = [0,0.5,1,0.5]      #selection box colors
		@pointOrigin = nil
		@pointMove   = nil
		@diff        = []
		@nouspoints  = [] 
	end

	def canvas_press(event)
		case
			when Active_Tool.get_tool == 1
				@sel_box   = [event.x,event.y,event.x,event.y]
				@selecting   = true
			when Active_Tool.get_tool == 2
				@pointOrigin = [event.x,event.y]
			when Active_Tool.get_tool == 3
				@pointMove = [event.x,event.y,event.x,event.y]
		end
	end

	def canvas_drag(obj,event)
		case
			when (@selecting && @sel_box)
				@sel_box[2] = event.x
				@sel_box[3] = event.y
				obj.queue_draw
			when (@pointOrigin)
				@pointOrigin[0] = event.x
				@pointOrigin[1] = event.y
			when (@pointMove)
				# difference in movement of the point, cumulative until mouse released
				@diff = round_to_grid([(event.x - @pointMove[0]) , (event.y - @pointMove[1])])
				@pointMove[2] = event.x
				@pointMove[3] = event.y
				obj.queue_draw
		end
	end
	
	def canvas_release(obj,event)
		case
			when Active_Tool.get_tool == 1
				@sel_box = pos_box(@sel_box)
				@nouspoints = Pl.select_points(@sel_box,@nouspoints)
				@sel_box = nil
				@selecting = false
				obj.queue_draw
			when Active_Tool.get_tool == 2 #Add a point where/when the tool is released
				@nouspoints = Pl.add_point(round_to_grid(@pointOrigin),@nouspoints)
				@pointOrigin = nil
				obj.queue_draw
			when Active_Tool.get_tool == 3 #move point(s) designated by the move stencil
				@nouspoints = Pl.move_points(@diff,@nouspoints)
				@pointMove = nil
				obj.queue_draw
		end
	end
	
	def canvas_del
		@nouspoints = Pl.delete_points(@nouspoints)
		UI::canvas.queue_draw
	end
	
	def canvas_draw(obj, cr)
		case #These draw events are for in-progress/temporary activities
			when(@sel_box)  
				width  = @sel_box[2] - @sel_box[0]
				height = @sel_box[3] - @sel_box[1]
				
				cr.set_source_rgba(@sel_white)
				cr.rectangle(@sel_box[0],@sel_box[1],width,height)
				cr.fill
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

		#Draw all the points last
		@nouspoints.each { |n| n.draw(cr) }
	end
	
end

CC = Canvas_Control.new