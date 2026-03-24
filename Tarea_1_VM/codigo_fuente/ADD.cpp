#include "ADD.hpp"
#include "CPU.hpp"

void ADD::execute(CPU& cpu, Memory& memory) {
    cpu.ACC = cpu.AL + cpu.BL;
}

std::string ADD::toString() {
    return "ADD";
}