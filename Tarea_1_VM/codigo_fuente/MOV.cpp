#include "MOV.hpp"
#include "CPU.hpp"
#include "Memory.hpp"

MOV::MOV(std::string r, int a) {
    reg = r;
    addr = a;
}

void MOV::execute(CPU& cpu, Memory& memory) {
    cpu.MAR = addr;
    cpu.MBR = memory.read(addr);

    if (reg == "AL") cpu.AL = cpu.MBR;
    else if (reg == "BL") cpu.BL = cpu.MBR;
}

std::string MOV::toString() {
    return "MOV " + reg + ", " + std::to_string(addr);
}