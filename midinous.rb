require "midi"
require "gtk3"
require_relative "init"
require_relative "debug"

Gtk.main

#TODO
# Add "transform" as a play mode? One point changes parms after playing? Could be any number of parameters, may require a dialog.
# Set up save/load logic, should only have to save the Nouspoints array and current scale somehow
# Add "logic view" and utilize a secondary path build function and button label "Build Logic"
#   Add dialog for logic controls instead?