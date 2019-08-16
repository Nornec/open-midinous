require "midi"
require "gtk3"
require_relative "init"
require_relative "proc_midi"
#require_relative "debug"

Gtk.main

=begin sample draw
UI::canvas.signal_connect("draw") do |obj, cr| #obj means current UI element. cr is the cairo context created via the signal

  # create shape
  cr.move_to(400, 1000)
  cr.curve_to(100, 25, 100, 75, 150, 50)
  cr.line_to(150, 0)
  cr.line_to(50, 150)
  cr.close_path

  cr.set_source_rgba(0.5, 0.0, 0.2,0.5)
  cr.fill_preserve
  cr.set_source_rgba(0.6, 0.0, 0.2,1)
  cr.set_line_join(Cairo::LINE_JOIN_MITER)
  cr.set_line_width(2)
  cr.stroke
end
=end