TOP = lfsr_tb
SRC = src/lfsr.sv test/lfsr_tb.sv src/gf_mult_ripple.sv test/syndrome_checker.sv
EXE = obj_dir/V$(TOP)

all: run

$(EXE): $(SRC)
	verilator --binary --sv --trace --Wno-fatal --top-module $(TOP) $(SRC)

run: $(EXE)
	./$(EXE)

wave: run
	gtkwave $(TOP).vcd

clean:
	rm -rf obj_dir *.vcd
