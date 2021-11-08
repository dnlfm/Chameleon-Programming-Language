#include <stdio.h>

//int line_backpatch_risc;

typedef struct Instrucao{
    int endereco;
    char * label;
    int imediato;
    int rd;
    int src1, src2;
    char * op;
    int labelint;
}Instrucao;

typedef struct Block{
    Instrucao insts[50];
    int num_inst;
}Block;

Block block_mount;

Block createBlock();

void imprimeRISCV(Block *b);

void imprimeLLVM(Block *b);

void createADD(Block *b, int rd_int, int src1_int, int src2_int);
void createSUB(Block *b, int rd_int, int src1_int, int src2_int);
void createMUL(Block *b, int rd_int, int src1_int, int src2_int);
void createDIV(Block *b, int rd_int, int src1_int, int src2_int);

void createADDi(Block *b, int rd_int, int src1_int, int imediato);
void createSUBi(Block *b, int rd_int, int src1_int, int imediato);
void createMULi(Block *b, int rd_int, int src1_int, int imediato);
void createDIVi(Block *b, int rd_int, int src1_int, int imediato);

void createDeclaration(Block *b, int rd_int);
//Dificil no RISC: 2 instrucoes
//void createIsNotEqual(Block *b, int rd_int, int src1_int, int src2_int);

void createAnd(Block *b, int rd_int, int src1_int, int src2_int);
void createAndi(Block *b, int rd_int, int src1_int, int imediato);
void createOr(Block *b, int rd_int, int src1_int, int src2_int);
//Dificil no RISC: 2 instrucoes
void createNot(Block *b, int rd_int, int src1_int, int src2_int);

void createSlt(Block *b, int rd_int, int src1_int, int src2_int);
void createSgt(Block *b, int rd_int, int src1_int, int src2_int);

/*void createSltEqual(Block *b, int rd_int, int src1_int, int src2_int);
void createSgtEqual(Block *b, int rd_int, int src1_int, int src2_int);
*/

void createBeqi(Block *b, int src1_int, int src2_int, char * label);
void createBeqEndi(Block *b, int src1_int, int src2_int, int endereco);

void createLabel(Block *b, char * label);
void createLabelInt(Block *b, int labelint);

