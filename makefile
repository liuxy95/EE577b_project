###########################################################################
# This is a general purpose makefile to compile and run                   #
# Cadence NCSIM simulations                                               #
#                                                                         #
# To compile                                                              #
# ----------                                                              #
# %> make                                                                 #
#                                                                         #
# To run simulation in console mode                                       #
# ---------------------------------                                       #
# %> make sim                                                             #
#                                                                         #
# To run simulation in gui mode                                           #
# -----------------------------                                           #
# %> make simg                                                            #
#                                                                         #
# Directory Stucture                                                      #
# ------------------                                                      #
# This makefile assumes the following directory structure :               #
#                                                                         #
# ./        -- current directory, simulation is going to run from here    #
# ./work    -- Cadence work library to compile the design                 #
# ./design  -- holds all design verilog files                             #
# ./tb      -- holds testbench file(s)                                    #
# ./include -- files included in the verilog files using include command  #
# ./scripts -- holds tcl run scripts for simulation control               #
# ./etc     -- keep all auxiliary files in this directory                 #
#                                                                         #
###########################################################################
#                                                                          
# Setup environment variables to point the Cadence instal directories      
# and license files etc                                                      
# source ~ee577/vlsi_tools.csh                                              

# top level module
TOP = tb

# List of the design files
DESIGN_FILES = ./design/*.v

# List of the testbench files
TB_FILES = ./tb/*.v

INCLUDE_DIRECTORY = ./include

# GUI simulation script file
SIM_SCRIPT_FILE_GUI = ./scripts/runscript.tcl

# Non GUI simulation script file
SIM_SCRIPT_FILE_NO_GUI = ./scripts/runscript_nogui.tcl

# ncvlog switch 
NCVLOG_SWITCHES = \
	-64BIT \
	-STATUS \
	-MESSAGES \
	-NOCOPYRIGHT \
	-UPDATE \
	-INCDIR $(INCLUDE_DIRECTORY)

#ncelab switches
NCELAB_SWITCHES = \
	-64BIT \
	-MESSAGES \
	-NOCOPYRIGHT \
	-ACCESS +rwc \
	-NCFATAL INVSUP \
	-NCFATAL CUNOTB \
	-ERRORMAX 5 \
	-UPDATE \
	-TIMESCALE '1ns/10ps' \
	-LIBVERBOSE

# ncsim simulation switches for console simulation
NCSIM_SWITCHES_NO_GUI = \
	-64BIT \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_NO_GUI)

# ncsim switches for GUI simulations
NCSIM_SWITCHES_GUI = \
	-64BIT \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_GUI) \
	-GUI

all : elab~

# analyze all the design and testbench files
ana~ : $(DESIGN_FILES)
	for f in $(DESIGN_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	@touch ana~

# elaborate the top module
elab~ : ana~
	ncelab $(NCELAB_SWITCHES) work.$(TOP)
	@touch elab~

# run simulation without gui
sim : clean elab~
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)

# run simulation with gui
simg : clean elab~
	ncsim $(NCSIM_SWITCHES_GUI) work.$(TOP)

# clean the library to have a clean start
clean :
	@rm -rf `find . -name '*~'`
	@rm -rf work waves.shm 
	@rm -rf ncsim*
	@rm -rf *.log
	@rm -f default.svf
	@rm -rf .simvision/
	@mkdir work
	@echo 'All set for a clean start'

# create directory structure
dir :
	@rm -rf work
	@mkdir work
	@mkdir design tb include scripts netlist sdf reports
	@echo 'Directory structure for simulation is created'

# create the basic cds.lib file
cds.lib :
	@echo 'DEFINE work work' > cds.lib

# create a blank hdl.var
hdl.var :
	@echo '# Hello Cadence' > hdl.var

init : dir cds.lib hdl.var
	@touch AUTHORS
	@echo 'Initialized the directory for simulation'

submit: clean
	@rm -rf ${DESIGNNAME}.tar
	@tar cvf ${DESIGNNAME}.tar .

