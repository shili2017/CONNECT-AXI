#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTestbench.h"

double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {

  if (false && argc && argv && env) {}

  const std::unique_ptr<VerilatedContext> contextp(new VerilatedContext);
  contextp->debug(0);
  contextp->randReset(2);
  contextp->traceEverOn(true);
  contextp->commandArgs(argc, argv);

  const std::unique_ptr<VTestbench> tb(new VTestbench(contextp.get(), "TESTBENCH"));

  tb->clock = 0;
  tb->reset = 1;

  Verilated::traceEverOn(true);
  const std::unique_ptr<VerilatedVcdC> tfp(new VerilatedVcdC);
  tb->trace(tfp.get(), 99);  // Trace 99 levels of hierarchy
  tfp->open("build/sim.vcd");

  // Simulate until $finish
  while (contextp->time() < 100) {
    contextp->timeInc(1);

    tb->clock = !tb->clock;
    tb->reset = contextp->time() < 4 ? 1 : 0;

    tb->eval();
    tfp->dump(contextp->time());
  }

  tfp->close();
  tb->final();

  return 0;
}
