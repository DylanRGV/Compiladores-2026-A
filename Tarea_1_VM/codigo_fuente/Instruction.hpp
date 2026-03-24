#pragma once
#include <string>

class CPU;
class Memory;

class Instruction {
public:
    virtual void execute(CPU& cpu, Memory& memory) = 0;
    virtual std::string toString() = 0;
    virtual ~Instruction() {}
};