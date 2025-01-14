; Build-time config options.

if def(DEV)
	redef D_SA equs "DungeonComplete"
	redef NO_QUICKLOAD = 1
	redef INIT_LEVEL = 19
endc

; The node the player will start in on the map screen.
if !def(FIRST_NODE)
	def FIRST_NODE equs "xVillageNode"
endc

; If enabled, causes SELECT to auto-complete the level, rather than skip a turn.
if !def(D_SA)
	def D_SA equs "EndTurn"
endc

if !def(INIT_LEVEL)
	def INIT_LEVEL = 5
endc

if !def(INIT_INVENTORY)
	def INIT_INVENTORY equs "null"
endc

if !def(NO_QUICKLOAD)
	def NO_QUICKLOAD = 0
endc

if !def(SET_ALL_FLAGS)
	def SET_ALL_FLAGS = 0
endc
