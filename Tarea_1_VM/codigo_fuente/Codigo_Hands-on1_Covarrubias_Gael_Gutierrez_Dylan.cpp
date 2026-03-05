#include <iostream>
#include <vector>
using namespace std;

struct Instruction {
    string opcode;
    string op1;
    int op2;

    Instruction(string code = "", string r = "", int addr = 0) {
        opcode = code;
        op1 = r;
        op2 = addr;
    }
};

class Memory {
public:
    vector<int> data;
    vector<Instruction> program; 

    Memory(int size) {
        data.resize(size, 0);
    }
};

class CPU {
public:
    int PC = 0;
    Instruction IR;
    int MAR = 0;
    int MBR = 0;
    int ACC = 0;

    int AL = 0, AH = 0, BL = 0, BH = 0;

    bool running = true;

    void printState(string stage) {
        cout << "\n==== " << stage << " ====\n";
        cout << "PC: " << PC << endl;
        cout << "IR: " << IR.opcode << " " << IR.op1 << " " << IR.op2 << endl;
        cout << "MAR: " << MAR << endl;
        cout << "MBR: " << MBR << endl;
        cout << "ACC: " << ACC << endl;
        cout << "AL: " << AL << " AH: " << AH
             << " BL: " << BL << " BH: " << BH << endl;
    }

    int* getRegister(string name) {
        if (name == "AL") return &AL;
        if (name == "BL") return &BL;
        if (name == "AH") return &AH;
        if (name == "BH") return &BH;
        return nullptr;
    }

    void fetch(Memory &mem) {
        MAR = PC;
        IR = mem.program[MAR];
        PC++;
        printState("FETCH");
    }

    void decode() {
        printState("DECODE");
    }

    void execute(Memory &mem) {

        if (IR.opcode == "MOV") {
            MAR = IR.op2;
            MBR = mem.data[MAR];
            *getRegister(IR.op1) = MBR;
        }

        else if (IR.opcode == "ADD") {
            ACC = AL + BL;
        }

        else if (IR.opcode == "STO") {
            MAR = IR.op2;
            MBR = ACC;
            mem.data[MAR] = MBR;
        }

        else if (IR.opcode == "END") {
            running = false;
        }

        printState("EXECUTE");
    }
};

int main() {

    Memory memory(20);
    CPU cpu;

    memory.data[6] = 10;
    memory.data[7] = 12;

    memory.program = {
        Instruction("MOV", "AL", 6),
        Instruction("MOV", "BL", 7),
        Instruction("ADD"),
        Instruction("STO", "", 8),
        Instruction("END")
    };

    while (cpu.running) {
        cpu.fetch(memory);
        cpu.decode();
        cpu.execute(memory);
    }

    cout << "\nResultado final en memoria[8]: "
         << memory.data[8] << endl;

    return 0;
}