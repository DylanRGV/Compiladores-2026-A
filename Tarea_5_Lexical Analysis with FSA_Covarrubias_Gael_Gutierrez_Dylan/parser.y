%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);

extern FILE *yyin;
extern int yylineno;

#define MAX_SIMB 300
#define TIPO_VAR 0
#define TIPO_FUNC 1
#define TIPO_MACRO 2
#define TIPO_INT 0

typedef struct {
    char *nombre;
    int clase;
    int tipo_dato;
    int aridad;
    int ambito;
    int activo;
    int usado;
} Simbolo;

Simbolo tabla[MAX_SIMB];

int ntabla = 0;
int ambito_actual = 0;
int semantic_errors = 0;

int yyerror(char *s) {
    printf("Error sintactico en linea %d: %s\n", yylineno, s);
    return 0;
}

void entrar_ambito() {
    ambito_actual++;
}

void salir_ambito() {
    for (int i = 0; i < ntabla; i++) {
        if (tabla[i].ambito == ambito_actual) {
            tabla[i].activo = 0;
        }
    }
    ambito_actual--;
}

int existe_en_ambito_actual(char *id) {
    for (int i = 0; i < ntabla; i++) {
        if (tabla[i].activo &&
            tabla[i].ambito == ambito_actual &&
            strcmp(tabla[i].nombre, id) == 0) {
            return 1;
        }
    }
    return 0;
}

int existe_global(char *id, int clase) {
    for (int i = 0; i < ntabla; i++) {
        if (tabla[i].activo &&
            tabla[i].ambito == 0 &&
            tabla[i].clase == clase &&
            strcmp(tabla[i].nombre, id) == 0) {
            return 1;
        }
    }
    return 0;
}

void agregar_variable(char *id, int tipo_dato) {
    if (existe_en_ambito_actual(id)) {
        printf("Error semantico en linea %d: redeclaracion de variable '%s'\n", yylineno, id);
        semantic_errors++;
        return;
    }
    tabla[ntabla++] = (Simbolo){strdup(id), TIPO_VAR, tipo_dato, 0, ambito_actual, 1, 0};
}

void agregar_macro(char *id) {
    if (existe_global(id, TIPO_MACRO)) {
        printf("Error semantico en linea %d: macro '%s' ya definida\n", yylineno, id);
        semantic_errors++;
        return;
    }
    tabla[ntabla++] = (Simbolo){strdup(id), TIPO_MACRO, TIPO_INT, 0, 0, 1, 1};
}

void agregar_funcion(char *id, int aridad) {
    if (existe_global(id, TIPO_FUNC)) {
        printf("Error semantico en linea %d: funcion '%s' ya declarada\n", yylineno, id);
        semantic_errors++;
        return;
    }
    tabla[ntabla++] = (Simbolo){strdup(id), TIPO_FUNC, TIPO_INT, aridad, 0, 1, 1};
}

int buscar_tipo_variable(char *id) {
    for (int a = ambito_actual; a >= 0; a--) {
        for (int i = ntabla - 1; i >= 0; i--) {
            if (tabla[i].activo &&
                tabla[i].clase == TIPO_VAR &&
                tabla[i].ambito == a &&
                strcmp(tabla[i].nombre, id) == 0) {
                return tabla[i].tipo_dato;
            }
        }
    }
    return -1;
}

void verificar_y_marcar_uso(char *id) {
    if (buscar_tipo_variable(id) == -1) {
        printf("Error semantico en linea %d: variable '%s' no declarada\n", yylineno, id);
        semantic_errors++;
    } else {
        for (int a = ambito_actual; a >= 0; a--) {
            for (int i = ntabla - 1; i >= 0; i--) {
                if (tabla[i].activo && tabla[i].clase == TIPO_VAR && tabla[i].ambito == a && strcmp(tabla[i].nombre, id) == 0) {
                    tabla[i].usado = 1;
                    return;
                }
            }
        }
    }
}

int buscar_aridad_funcion(char *id) {
    for (int i = 0; i < ntabla; i++) {
        if (tabla[i].activo &&
            tabla[i].clase == TIPO_FUNC &&
            strcmp(tabla[i].nombre, id) == 0) {
            return tabla[i].aridad;
        }
    }
    return -1;
}

void verificar_llamada_funcion(char *id, int argumentos) {
    int esperados = buscar_aridad_funcion(id);
    if (esperados == -1) {
        printf("Error semantico en linea %d: funcion '%s' no declarada\n", yylineno, id);
        semantic_errors++;
        return;
    }

    if (esperados != argumentos) {
        printf("Error semantico en linea %d: funcion '%s' espera %d argumento(s), pero recibio %d\n", yylineno, id, esperados, argumentos);
        semantic_errors++;
    }
}

void imprimir_tabla_y_advertencias() {
    printf("\n+-------------------------------------------------------------+\n");
    printf("| Nombre     | Clase    | Tipo | Ambito | Aridad | Activo |\n");
    printf("+-------------------------------------------------------------+\n");
    for (int i = 0; i < ntabla; i++) {
        char *clase_str = (tabla[i].clase == TIPO_VAR) ? "variable" : (tabla[i].clase == TIPO_FUNC) ? "funcion" : "macro";
        printf("| %-10s | %-8s | int  | %-6d | %-6d | %-6d |\n",
               tabla[i].nombre, clase_str, tabla[i].ambito, tabla[i].aridad, tabla[i].activo);
    }
    printf("+-------------------------------------------------------------+\n\n");

    for(int i = 0; i < ntabla; i++) {
        if (tabla[i].clase == TIPO_VAR && tabla[i].usado == 0) {
            printf("Advertencia: variable '%s' declarada pero no usada\n", tabla[i].nombre);
        }
    }
}
%}

%union {
    char *str;
    int num;
}

%token <str> ID
%token <str> STRING_LITERAL
%token <str> NUMBER

%token INCLUDE DEFINE
%token INT FUNC RETURN IGUAL IF
%token PARIZQ PARDER LLAVEIZQ LLAVEDER PUNTOYCOMA COMA
%token MENOR MAYOR PUNTO
%token OP_SUMA OP_RESTA OP_MULT OP_DIV

%type <num> parametros
%type <num> lista_param
%type <num> argumentos
%type <num> lista_args

%%

programa:
      preprocesador declaraciones
      {
          if (semantic_errors == 0) {
              printf("Analisis completado sin errores semanticos.\n");
          } else {
              printf("Analisis completado con %d error(es) semantico(s).\n", semantic_errors);
          }
          imprimir_tabla_y_advertencias();
      }
    ;

preprocesador:
      preprocesador directiva
    |
    ;

directiva:
      include
    | define
    ;

include:
      INCLUDE MENOR ID MAYOR
    | INCLUDE MENOR ID PUNTO ID MAYOR
    | INCLUDE STRING_LITERAL
    ;

define:
      DEFINE ID NUMBER { agregar_macro($2); }
    | DEFINE ID ID { agregar_macro($2); }
    | DEFINE ID STRING_LITERAL { agregar_macro($2); }
    | DEFINE ID { agregar_macro($2); }
    ;

declaraciones:
      declaracion
    | declaraciones declaracion
    ;

declaracion:
      INT ID PUNTOYCOMA
      {
          agregar_variable($2, TIPO_INT);
      }
    | FUNC ID PARIZQ
      {
          agregar_funcion($2, -1);
          entrar_ambito();
      }
      parametros PARDER bloque_funcion
      {
          int aridad = $5;
          for (int i = 0; i < ntabla; i++) {
              if (tabla[i].activo &&
                  tabla[i].clase == TIPO_FUNC &&
                  strcmp(tabla[i].nombre, $2) == 0) {
                  tabla[i].aridad = aridad;
                  break;
              }
          }
          salir_ambito();
      }
    ;

parametros:
      { $$ = 0; }
    | lista_param { $$ = $1; }
    ;

lista_param:
      ID
      {
          agregar_variable($1, TIPO_INT);
          $$ = 1;
      }
    | lista_param COMA ID
      {
          agregar_variable($3, TIPO_INT);
          $$ = $1 + 1;
      }
    ;

bloque_funcion:
      LLAVEIZQ instrucciones LLAVEDER
    ;

bloque:
      LLAVEIZQ
      {
          entrar_ambito();
      }
      instrucciones LLAVEDER
      {
          salir_ambito();
      }
    ;

instrucciones:
      instrucciones instruccion
    |
    ;

instruccion:
      INT ID PUNTOYCOMA
      {
          agregar_variable($2, TIPO_INT);
      }
    | ID IGUAL expresion PUNTOYCOMA
      {
          if(buscar_tipo_variable($1) == -1) {
              printf("Error semantico en linea %d: variable '%s' no declarada\n", yylineno, $1);
              semantic_errors++;
          }
      }
    | ID PARIZQ argumentos PARDER PUNTOYCOMA
      {
          verificar_llamada_funcion($1, $3);
      }
    | RETURN ID PUNTOYCOMA
      {
          verificar_y_marcar_uso($2);
      }
    | IF PARIZQ ID PARDER
      { 
          verificar_y_marcar_uso($3); 
      } 
      bloque
    | bloque
    ;

expresion:
      ID 
      { 
          verificar_y_marcar_uso($1); 
      }
    | ID OP_SUMA ID 
      { 
          verificar_y_marcar_uso($1); 
          verificar_y_marcar_uso($3); 
      }
    | ID OP_RESTA ID 
      { 
          verificar_y_marcar_uso($1); 
          verificar_y_marcar_uso($3); 
      }
    | ID OP_MULT ID 
      { 
          verificar_y_marcar_uso($1); 
          verificar_y_marcar_uso($3); 
      }
    | ID OP_DIV ID 
      { 
          verificar_y_marcar_uso($1); 
          verificar_y_marcar_uso($3); 
      }
    ;

argumentos:
      { $$ = 0; }
    | lista_args { $$ = $1; }
    ;

lista_args:
      ID
      {
          verificar_y_marcar_uso($1);
          $$ = 1;
      }
    | lista_args COMA ID
      {
          verificar_y_marcar_uso($3);
          $$ = $1 + 1;
      }
    ;

%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: %s archivo_fuente\n", argv[0]);
        return EXIT_FAILURE;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Error: no se pudo abrir el archivo '%s'\n", argv[1]);
        return EXIT_FAILURE;
    }

    yyparse();

    fclose(yyin);

    return semantic_errors == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}