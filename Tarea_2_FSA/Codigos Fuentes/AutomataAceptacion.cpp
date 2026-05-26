#include "Automata.hpp"

bool Automata::esEstadoDeAceptacion(Estado e) {
    return (e == q1 || e == q3 || e == q6);
}
