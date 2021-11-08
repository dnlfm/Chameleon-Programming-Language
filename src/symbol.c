#include "symbol.h"

void createData(Data **data, enum SymbolType type){
    (*data) = (Data*) malloc(sizeof(Data));
    (*data)->type = type;
}

void _createSymbol(Symbol **symbol, char *lexem, int token_type, Data *data){
    (*symbol) = (Symbol*) malloc(sizeof(Symbol));
    if(lexem != NULL){
        (*symbol)->lexem = strdup(lexem);
        strcat((*symbol)->lexem, "_key");
    }
    else
        (*symbol)->lexem = NULL;
    (*symbol)->fake_memory_address = -1;
    (*symbol)->token_type = token_type;
    (*symbol)->data = data;
}

void createSymbol(Symbol **symbol, char *lexem, int token_type, enum SymbolType type){
    
    Data *d;
    //createData(&d, type);
    createData(&d, type);
    _createSymbol(symbol, lexem,token_type, d);
}

void destroySymbol(Symbol **symbol){
    if(symbol != NULL && *symbol != NULL){
        Symbol *removedor = (*symbol); // TODO: melhorar isso, dando free nas coisas internas
        destroyData(&(removedor->data));
        free(removedor);
    }
}

void destroyData(Data **data){
    if(data != NULL && *data != NULL){
        Data *removedor = (*data);
        if(removedor->type == _WORD){
            char *r_word = removedor->v.word;
            free(r_word);
        }
        free(removedor);
    }
}

void destroySquad(Squad **squad){
    // TODO
}

int checkTypes(enum SymbolType t1, enum SymbolType t2){
    if(t1 != t2){
        if(t1 == _REAL && t2 == _INTEGER)
            return 1;
        return 0;
    }
    return 1;
}

void upTypes(Symbol *symbol, enum SymbolType t1, enum SymbolType t2){
    if(t1 != t2){
        if(t1 == _REAL && t2 == _INTEGER || (t1 == _INTEGER && t2 == _REAL))
            symbol->data->type = _REAL;        
    }
}

Symbol* applyBinaryOperatorInSymbols(Symbol *s1, char op, Symbol *s2){
    if(s1->data != NULL && s2->data != NULL){        
        if(s1->data->type == _INTEGER && s2->data->type == _INTEGER){
            int a, b;
            a = s1->data->v.integer;
            b = s2->data->v.integer;

            switch(op){
                case '+': a = a + b; break;
                case '-': a = a - b; break;
                case '/': if(b == 0) return NULL; a = a / b; break;
                case '*': a = a * b; break;
                case '%': a = a % b; break;
                case '^': a = pow(a, b); break;
            }
            s1->data->v.integer = a;            
            return s1;
        }
        if(s1->data->type == _INTEGER && s2->data->type == _REAL){
            int a;
            double b;
            a = s1->data->v.integer;
            b = s2->data->v.real;

            switch(op){
                case '+': b = a + b; break;
                case '-': b = a - b; break;
                case '/': if(b == 0) return NULL; b = (double) a / b; break;
                case '*': b = a * b; break;
                case '%': return NULL; break;
                case '^': b = pow(a, b); break;
            }
            s1->data->type = _REAL;
            s1->data->v.real = b;
            return s1;
        }     
        if(s1->data->type == _REAL && s2->data->type == _INTEGER){
            double a;
            int b;
            a = s1->data->v.real;
            b = s2->data->v.integer;

            switch(op){
                case '+': a = a + b; break;
                case '-': a = a - b; break;
                case '/': if(b == 0) return NULL; a = (double) a / b; break;
                case '*': a = a * b; break;
                case '%': return NULL; break;
                case '^': a = pow(a, b); break;
            }
            s1->data->v.real = a;            
            return s1;
        }  
        if(s1->data->type == _REAL && s2->data->type == _REAL){
            double a, b;
            a = s1->data->v.real;
            b = s2->data->v.real;

            switch(op){
                case '+': a = a + b; break;
                case '-': a = a - b; break;
                case '/': if(b == 0) return NULL; a = (double) a / b; break;
                case '*': a = a * b; break;
                case '%': return NULL; break;
                case '^': a = pow(a, b); break;
            }
            s1->data->v.real = a;            
            return s1;
        } 
        return NULL;
    }
}