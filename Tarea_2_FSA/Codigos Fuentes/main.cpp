#include <iostream>
#include "Automata.hpp"

using namespace std;

int main() {

    Automata fsa;
    string token;

    cout << "Ingresa un numero: ";
    cin >> token;

    if(fsa.validar(token))
        cout << "Token valido\n";
    else
        cout << "Token invalido\n";

    return 0;
}
