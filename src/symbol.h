#ifndef ESTRUTURA_TIPOS_INCLUDED
#define ESTRUTURA_TIPOS_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

    #include <stdlib.h>
    #include <stdio.h>
    #include <limits.h>
    #include <string.h>
    #include <math.h>

    //#define TAM_LEXEMA 255 // colocar?

    #define MAX_TAM_WORD 255

    enum SymbolType {NOTHING, _REAL, FFUNCTION, _INTEGER, _WORD, AGGREGATED, _VARIABLE};     
    

    typedef void* (Function) (void* p, ...);

    typedef struct Squad{
        struct Symbol *internal_variables; // TODO: Arrumar
    } Squad;

    typedef struct Data{
        enum SymbolType type;
        union{
            int integer;
            double real;
            char *word;  
            Squad squad; 
            Function *Function;
        } v;
    } Data;

    typedef struct Symbol{
        int fake_memory_address;
        char *lexem;
        int token_type;    
        Data *data;
        char to_emit[255]; // limitacao de emissao (se der tempo, melhorar)
        int line_backpatch;
        int line_backpatch_risc;
    } Symbol;

    void createData(Data **data, enum SymbolType type);
    void _createSymbol(Symbol **symbol, char *lexem, int token_type, Data *data);
    void createSymbol(Symbol **symbol, char *lexem, int token_type, enum SymbolType type);
    void destroySymbol(Symbol **symbol);
    void destroyData(Data **data);
    void destroySquad(Squad **squad);
    int checkTypes(enum SymbolType t1, enum SymbolType t2);
    void upTypes(Symbol *symbol, enum SymbolType t1, enum SymbolType t2);
    Symbol* applyBinaryOperatorInSymbols(Symbol *s1, char op, Symbol *s2);

#ifdef __cplusplus
}
#endif

#endif /* ESTRUTURA_TIPOS_INCLUDED  */