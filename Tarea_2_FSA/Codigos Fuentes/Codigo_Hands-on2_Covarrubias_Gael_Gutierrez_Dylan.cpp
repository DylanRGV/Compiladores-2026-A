#include <iostream>
#include <string>
#include <cctype>

using namespace std;

class Automata {

private:
    int estado;

public:

    Automata() {
        estado = 12;
    }

    bool esAceptacion(int e) {
        return (e == 19 || e == 20 || e == 21);
    }

    bool procesar(string cadena) {

        estado = 12;
        cadena += '#'; // simulamos "other" al final

        for(char c : cadena) {

            switch(estado) {

                case 12:
                    if(isdigit(c)) estado = 13;
                    else return false;
                break;

                case 13:
                    if(isdigit(c)) estado = 13;
                    else if(c == '.') estado = 14;
                    else if(c == 'E') estado = 16;
                    else estado = 20;
                break;

                case 14:
                    if(isdigit(c)) estado = 15;
                    else return false;
                break;

                case 15:
                    if(isdigit(c)) estado = 15;
                    else if(c == 'E') estado = 16;
                    else estado = 21;
                break;

                case 16:
                    if(c == '+' || c == '-') estado = 17;
                    else if(isdigit(c)) estado = 18;
                    else return false;
                break;

                case 17:
                    if(isdigit(c)) estado = 18;
                    else return false;
                break;

                case 18:
                    if(isdigit(c)) estado = 18;
                    else estado = 19;
                break;

                case 19:
                case 20:
                case 21:
                    return esAceptacion(estado);
            }
        }

        return esAceptacion(estado);
    }
};

int main() {

    Automata a;
    string cadena;

    cout << "Ingresa numero: ";
    cin >> cadena;

    if(a.procesar(cadena))
        cout << "Cadena valida\n";
    else
        cout << "Cadena invalida\n";

}