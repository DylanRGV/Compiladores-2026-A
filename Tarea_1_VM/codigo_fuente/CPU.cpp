#include "CPU.hpp"
#include "Instruction.hpp"
#include "Memory.hpp"
#include <iostream>

void CPU::fetch(std::vector<Instruction*>& program) {
    MAR = PC;
    IR = program[MAR];
    PC++;
    printState("FETCH");
}

void CPU::decode() {
    printState("DECODE");
}

void CPU::execute(Memory& memory) {
    IR->execute(*this, memory);
    printState("EXECUTE");
}

void CPU::printState(std::string stage) {
    std::cout << "\n=== " << stage << " ===\n";
    std::cout << "PC: " << PC << "\n";
    std::cout << "MAR: " << MAR << "\n";
    std::cout << "MBR: " << MBR << "\n";
    std::cout << "ACC: " << ACC << "\n";
    std::cout << "AL: " << AL << " BL: " << BL << "\n";
}