CANVAS_SIZE = 4400
PI = 3.14159265358979
RED   = [0.8,0.0,0.0]
GREEN = [0.0,0.6,0.0]
LGRN  = [0.4,0.6,0.4]
BLUE  = [0.0,0.0,0.6]
GREY  = [0.6,0.6,0.6]
WHITE = [1.0,1.0,1.0]
ORNGE = [1.0,0.5,0.5]
CYAN  = [0.0,0.5,1.0]
VLET  = [0.6,0.2,0.8]
BLACK = [0.1,0.1,0.1]
BLUGR = [0.2,0.4,0.7]
DGREY = [0.5,0.5,0.5,0.3]

SCALES = { 
"Aeolian"              => [2,1,2,2,1,2,2],
"Altered"              => [1,2,1,2,2,2,2],
"Augmented"            => [3,1,3,1,3,1],
"Blues"                => [3,2,1,1,3,2],
"Chromatic"            => [1,1,1,1,1,1,1,1,1,1,1,1],
"Dorian"               => [2,1,2,2,2,1,2],
"Flamenco"             => [1,3,1,2,1,3,1],
"Half Diminished"      => [2,1,2,1,2,2,2],
"Harmonic Major"       => [2,2,1,2,1,3,1],
"Harmonic Minor"       => [2,1,2,2,1,3,1],
"Hirajoshi"            => [4,2,1,4,1],
"Hungarian"            => [2,1,3,1,1,3,1],
"Insen"                => [1,4,2,4,2],
"Ionian"               => [2,2,1,2,2,2,1],
"Iwato"                => [1,4,1,4,2],
"Locrian"              => [1,2,2,1,2,2,2],
"Locrian Major"        => [2,2,1,1,2,2,2],
"Lydian"               => [2,2,2,1,2,2,1],
"Lydian Augmented"     => [2,2,2,2,1,2,1],
"Pentatonic Major"     => [2,2,3,2,3],
"Pentatonic Minor"     => [3,2,2,3,2],
"Melodic Minor"        => [2,1,2,2,2,2,1],
"Mixolydian"           => [2,2,1,2,2,1,2],
"Octatonic Whole"      => [2,1,2,1,2,1,2,1],
"Octatonic Half"       => [1,2,1,2,1,2,1,2],
"Persian"              => [1,3,1,1,2,3,1],
"Phrygian"             => [1,2,2,2,1,2,2],
"Prometheus"           => [2,2,2,3,1,2],
"Tritone"              => [1,3,2,1,3,2],
"Two Semitone Tritone" => [1,1,4,1,1],
"Ukrainian Dorian"     => [2,1,3,1,2,1,2],
"Whole Tone"           => [2,2,2,2,2,2]
}

=begin

Pentatonic
	"Hirajoshi"            
	"Insen"               
	"Iwato"               
	"Pentatonic Major"    
	"Pentatonic Minor"     
	"Two Semitone Tritone" 
Traditional
	"Aeolian"         
	"Dorian"          
	"Harmonic Major"  
	"Harmonic Minor"  
	"Ionian"          
	"Locrian"         
	"Lydian"          
	"Mixolydian"      
	"Phrygian"
Modified Traditional
	"Altered"             
	"Half Diminished"     
	"Locrian Major"       
	"Lydian Augmented"    
	"Melodic Minor"       
	"Ukrainian Dorian"    
Exotic
	"Augmented"           
	"Blues"  
	"Flamenco"  
	"Hungarian" 
	"Persian"        
	"Prometheus" 	
Mathematical
	"Chromatic"
	"Octatonic Whole"
	"Octatonic Half" 
	"Tritone" 
	"Whole Tone"

=end