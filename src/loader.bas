100 rem fantaseq64 - midi sequencer loader
101 print chr$(147)
102 rem *** setup ***
103 rem init address
104 init = 49152
105 bpm = 60  
107 ppqn = 24
108 rem sets basic memsize to $0bff, freeing upper memory for event table
109 poke 55,255 : poke 56,11 : clr
110 rem
111 rem *** before running this loader: ***
112 rem load the machine code first:
113 rem   load "fantaseq64.prg",8,1
114 rem then load the midi event table:
115 rem   load "events.prg",8,1
116 rem then load and run this loader:
117 rem   load "loader.prg",8
118 rem   run
119 rem
124 rem set 6840 latch values from BPM and PPQN
125 l = int(1022727 * 60 / (bpm * ppqn) + .5) - 1
130 lh = int(l / 256) : ll = l - lh * 256
135 rem enable cr1 access, hold timer in reset, set latches
140 poke 56833,1
145 poke 56832,67
150 poke 56834,lh : poke 56835,ll
155 print "starting sequencer at ";bpm;" bpm, ";ppqn;" ppqn"
160 sys init
165 print "sequencer stopped."










