require "midi"
require "gtk3"
require_relative "./bin/init"
#require_relative "debug"

Gtk.main

#TODO
# Add "transform" as a play mode? One point changes parms after playing? Could be any number of parameters, may require a dialog.
# Set up save/load logic, remember canvas properties as well as points.
# Add "logic view" and utilize a secondary path build function and button label "Build Logic"
#   Add dialog for logic controls instead?