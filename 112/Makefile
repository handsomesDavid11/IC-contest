ROOT_DIR           =$(PWD)
BUILD              =build
BUILD_DIR          =$(ROOT_DIR)/$(BUILD)
SRC_DIR            =$(ROOT_DIR)/src
SIM_DIR            =$(ROOT_DIR)/sim
SYN_DIR            =$(ROOT_DIR)/syn
APR_DIR            =$(ROOT_DIR)/icc
SCRIPT_DIR         =$(ROOT_DIR)/script
REPORT_DIR         =$(ROOT_DIR)/report
NC_DIR             =$(ROOT_DIR)/conf
PATTERN 		   =
ifeq ($(P),1)
PATTERN  := +P1
else ifeq ($(P),2)
PATTERN  := +P2
else ifeq ($(P),3)
PATTERN  := +P3
else ifeq ($(P),4)
PATTERN  := +P4
else ifeq ($(P),5)
PATTERN  := +P5
else ifeq ($(P),6)
PATTERN  := +P6
endif

# Need to modify
TB_TOP             =tb.sv
TOP                =LASER
SYN_TCL  		   =dc_syn
SRC=$(shell ls $(SRC_DIR)/*.v)
TB_SRC=$(shell ls $(SIM_DIR)/*.pattern)


# For IC contest
CBDK_DIR         =/usr/cad/lib/CBDK_IC_Contest_v2.5/Verilog
CORE_CELL        =tsmc13_neg.v

.PHONY: default init syn_init icc_init 
.PHONY: gen_def gen_hex cp_tb_src check
.PHONY: rtl nw syn autosyn synthesize clean

# Show available all command
default:
	@echo "clean       => Clean previous build"
	@echo "rtl         => Run RTL simulation"
	@echo "nw          => Run nWave"
	@echo "synthesize  => Run synthesize in interactive mode"
	@echo "autosyn     => Run synthesize in background"
	@echo "syn         => Run gate-level simulation"
	@echo "check       => Run superlint"

$(BUILD):
	mkdir -p $(BUILD)

# Create folders
init: clean
	mkdir -p $(BUILD_DIR) $(SYN_DIR) $(REPORT_DIR)

# Syn directory init
syn_init:
	mkdir -p $(SYN_DIR);

icc_init:
	mkdir -p $(APR_DIR)/design_data; \
	mkdir -p $(APR_DIR)/run; \
	mkdir -p $(APR_DIR)/verify/drc; \
	mkdir -p $(APR_DIR)/verify/lvs;

cp_tb_src:
	cd $(BUILD_DIR); \
	cp $(TB_SRC) .;

# Check HDL syntax
check:
	jg -superlint $(SCRIPT_DIR)/superlint.tcl &

# Run RTL simulation
rtl: $(BUILD) cp_tb_src
	cd $(BUILD_DIR); \
	ncverilog $(SIM_DIR)/$(TB_TOP) $(SRC) \
	+incdir+$(SRC_DIR) \
	+nc64bit \
	+access+r \
	+define+USECOLOR \
	+define+FSDB_FILE=\"$(TOP).fsdb\"

# View waveform using nWave
nw: $(BUILD)
	cp $(NC_DIR)/rtl.rc $(BUILD_DIR); \
	cd $(BUILD_DIR); \
	nWave -f $(TOP).fsdb -sswr $(NC_DIR)/rtl.rc +access+r +nc64bit &

# Run synthesize with Design Compiler
synthesize: $(BUILD) syn_init
	rm -rf $(SYN_DIR)/*; \
	cd $(BUILD_DIR); \
	cp $(SCRIPT_DIR)/synopsys_dc.setup $(BUILD_DIR)/.synopsys_dc.setup; \
	dcnxt_shell -f $(SCRIPT_DIR)/$(SYN_TCL).tcl;

# Auto run synthesize with Design Compiler
autosyn: $(BUILD) syn_init
	rm -rf $(SYN_DIR)/*; \
	cd $(BUILD_DIR); \
	cp $(SCRIPT_DIR)/synopsys_dc.setup $(BUILD_DIR)/.synopsys_dc.setup; \
	nohup dcnxt_shell -f $(SCRIPT_DIR)/$(SYN_TCL).tcl &

# Run gate-level simulation (nWave)
syn: $(BUILD) cp_tb_src syn_init
	cd $(BUILD_DIR); \
	cp $(SYN_DIR)/$(TOP)_syn.sdf $(BUILD_DIR); \
	ncverilog $(SIM_DIR)/$(TB_TOP) $(SYN_DIR)/$(TOP)_syn.v \
	-v $(CBDK_DIR)/$(CORE_CELL) \
	+nc64bit \
	+access+r \
	+define+FSDB_FILE=\"$(TOP).fsdb\" \
	+define+SDF \
	+define+SDFFILE=\"$(SYN_DIR)/$(TOP)_syn.sdf\"

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl

# Remove all files
clean:
	rm -rf $(BUILD_DIR) $(SYN_DIR) $(APR_DIR) $(REPORT_DIR) *.log