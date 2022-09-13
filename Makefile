# Set and examine the running environment
## If set, the return value of a pipeline is the value of the last (rightmost) command to 
## exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
## Note. bash will not terminate untill all commands of pipeline finished, even though 
## encounter a false.
SHELL     := $(shell which bash) -o pipefail

# Set directory path
ROOT_DIR  := $(shell pwd)
RTL       += $(shell find $(ROOT_DIR)/rtl -type f -name "*.v")
# include diretory
INC_DIR   := $(ROOT_DIR)/rtl
TOP       ?= cpu_top
TB        ?= tb_cpu

# Set simulator
SIM       ?= IVERILOG

ifeq ($(SIM), IVERILOG)
# Iverilog & VPP
IVERILOG      := iverilog
## define macro `IVERILOG` (define IVERILOG 1)
## use IEEE1800-2012
IVERILOG_OPTS := -D IVERILOG=1 -I $(INC_DIR) -g2012
VVP           := vvp
VVP_OPTS      += -$(WAVEFORMAT)
WAVEFORMAT    ?= vcd

# TODO: Other simulators

# Simulators rules
sim/%.tbi: sim/%.v $(RTL)
	$(IVERILOG) $(IVERILOG_OPTS) -o sim/$*.tbi sim/$*.v $(RTL)

sim/%: sim/%.tbi
	cd sim && $(VVP) *.tbi $(VVP_OPTS)
else
$(warning $(SIM))
endif

# Target or Commands
sim: sim/$(TB)
	@echo ""
	@echo ""
	@echo "*********Simulation is done. You can see the waveform with gtkwave.************"
	@echo ""
	@echo ""

lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME --top-module $(TOP) -I$(INC_DIR) $(RTL)

clean:
	@rm -f sim/*.tbi sim/*.$(WAVEFORMAT)

# dbg:
# Others
.DEFAULT: sim
.PHONY: sim clean dbg 
## Instruct `make` not to delete intermidiate files whenever encouter a error.
.PRECIOUS: sim/%.tbi
