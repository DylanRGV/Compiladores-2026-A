#include "CPU.hpp"
#include "Memory.hpp"
#include "Program.hpp"
#include "MOV.hpp"
#include "ADD.hpp"

int main() {

    Memory memory(20);
    CPU cpu;
    Program program;

    // Datos
    memory.write(6, 10);
    memory.write(7, 12);

    // Programa
    program.instructions.push_back(new MOV("AL", 6));
    program.instructions.push_back(new MOV("BL", 7));
    program.instructions.push_back(new ADD());

    // Ciclo máquina
    while (cpu.PC < program.instructions.size()) {
        cpu.fetch(program.instructions);
        cpu.decode();
        cpu.execute(memory);
    }

    return 0;
}