TOP = gf_mult_ripple_tb
SRC = src/gf_mult_ripple.sv test/gf_mult_ripple_tb.sv
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
