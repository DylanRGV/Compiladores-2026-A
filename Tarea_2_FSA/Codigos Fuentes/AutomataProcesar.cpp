#include "Automata.hpp"
#include <cctype>

bool Automata::validar(const std::string& lexema) {

    Estado estado = q0;

    for(char c : lexema) {
        switch(estado) {
            case q0:
                if(isdigit(c)) estado = q1;
                else return false;
            break;

            case q1:
                if(isdigit(c)) estado = q1;
                else if(c == '.') estado = q2;
                else if(c == 'E') estado = q4;
                else return false;
            break;

            case q2:
                if(isdigit(c)) estado = q3;
                else return false;
            break;

            case q3:
                if(isdigit(c)) estado = q3;
                else if(c == 'E') estado = q4;
                else return false;
            break;

            case q4:
                if(c == '+' || c == '-') estado = q5;
                else if(isdigit(c)) estado = q6;
                else return false;
            break;

            case q5:
                if(isdigit(c)) estado = q6;
                else return false;
            break;

            case q6:
                if(isdigit(c)) estado = q6;
                else return false;
            break;
        }
    }

    return esEstadoDeAceptacion(estado);
}
