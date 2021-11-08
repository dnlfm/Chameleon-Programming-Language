%{
#include "custom_defines.h"
#include "y.tab.h" /* para poder usar as constantes dos tokens, por exemplo. */

#define PRINT_ERROR_EOF "-> Um ou mais erros foram encontrados. Corrija-os!\n"

void remover_espacos_e_print(int t);
#define _REAL 1
#define _NUMBER 2

int supress_errors_flag = 0;
int erro_encontrado = 0;
%}
/* condicao exclusiva (bloqueia as demais regras) */
%x comment_condition
%x word_condition
/* condicao que e ativa mas mantem as demais ativadas tambem */
%s supress_errors_condition
/* Permitir a contabilizacao de linhas */
%option   yylineno 

supress_errors				"SUPRESS_ERRORS"

/* captura uma ocorrencia de espaco em branco, tabulacao ou quebra de linha*/
delim						[ \t\n\r]
/* ign (ignorador) ira ignorar um ou mais delim*/
ign							{delim}+
letter						[A-Za-z]
digit						[0-9]
underline					_
word_value					(\\.|[^"\\])*
number						{ign}*({digit}{ign}*)+
type						"integer"|"word"|"real"

squad_declaration 			"squad"
vector_declaration 			"vector"

end_squad				    "endsquad"
block_begin 				"begin"
block_end					"end" 

for 					    "for"
end_for						"endfor" 
while 					    "while"
end_while					"endwhile" 
if 					    	"if"
end_if						"endif"
elif 					    "elif"
end_elif					"endelif"
task 					    "task"
end_task					"endtask"

jumpto						"jumpto"
farewell					"farewell"
say							"say"
listen						"listen"
stop						"stop"
comma						","
open_parenthesis			"("
close_parenthesis			")"

identifier_complement		({digit}|{letter}|{underline})*
identifier					({letter}|{underline}{letter}){identifier_complement}

vector_access_start			"["
vector_access_end			"]"

squad_access_derreference	"->"
separator         			":"
real_number 				{ign}*({digit}{ign}*)+{ign}*(\.{ign}*({digit}{ign}*)+)
word_concat_operator		"++"
add_operator				[+-]
div_operator				[/*\%]
pow_operator				[\^]
rel_operator				"=="|"!="|">="|"<="|[><]
logic_operator				"and"|"or"|"!"
attribution					"="
creditos					"??creditos??"			

%%
{supress_errors}			{ BEGIN(supress_errors_condition); supress_errors_flag = 1; }
"giveup"					{return GIVEUP;}
"//"						BEGIN(comment_condition);
{ign}						{}

<comment_condition>.|\n		{}
<comment_condition>"\\\\"	{ BEGIN(INITIAL); if(supress_errors_flag) BEGIN(supress_errors_condition); }
 
"\""								BEGIN(word_condition);
<word_condition>{word_value}		{
									createSymbol(&(yylval.symbol), NULL, _WORD, _WORD);
									(yylval.symbol)->data->v.word = (char*) malloc(MAX_TAM_WORD * sizeof(char));
									sprintf((yylval.symbol)->data->v.word, "%s", yytext);
									return WORD_VALUE;
								}
<word_condition>"\""				{BEGIN(INITIAL);  if(supress_errors_flag) BEGIN(supress_errors_condition); }

{creditos}				{PRINT(("Feito por:\n%s\n", 
							"Daniel Freitas Martins - 2304\n"
							"João Arthur Gonçalves do Vale - 3025\n"
							"Maria Dalila Vieira - 3030\n"
							"Naiara Cristiane dos Reis Diniz - 3005"))}

{type}					{
							if(strcmp("integer", yytext) == 0)
								return INTEGER;
							if(strcmp("real", yytext) == 0)
								return REAL;
							return WORD;							
						}
{squad_declaration}	 	{strcpy(yylval.type_aux, "squad"); return SQUAD;}
{vector_declaration}	{strcpy(yylval.type_aux, "vector"); return VECTOR;}
	
{end_squad}				{return ENDSQUAD;}
{block_begin}			{
							yylval.symbol_table = ht_create(MAX_TAM_HASH);	
							if(curr_symbol_table == NULL){						
								curr_symbol_table = yylval.symbol_table;
								if(first_symbol_table == NULL){
									first_symbol_table = yylval.symbol_table;
								}
							}						
							return BLOCK_BEGIN;}
{block_end}				{return BLOCK_END;} 

{for}				    {return FOR;}
{end_for}				{return ENDFOR;} 
{while}				    {return WHILE;}
{end_while}				{return ENDWHILE;}
{if}				    {return IF;}
{end_if}				{return ENDIF;}
{elif}				    {return ELIF;}
{end_elif}				{return ENDELIF;}
{task}				    {strcpy(yylval.type_aux, "task"); return TASK;}
{end_task}				{return ENDTASK;}

{jumpto}				{return JUMPTO;}
{farewell}				{return FAREWELL;}
{say}				    {return SAY;}
{listen}				{return LISTEN;}
{stop}				    {return STOP;}

{comma}				    {return yytext[0];}
{open_parenthesis}		{return yytext[0];}
{close_parenthesis}		{return yytext[0];}
 
{vector_access_start}			{return yytext[0];}
{vector_access_end}				{return yytext[0];}


{squad_access_derreference}		{return SQUAD_ACCESS_DERREFERENCE;}
{separator}						{return yytext[0];}
{word_concat_operator}			{return WORD_CONCAT_OPERATOR;}
{add_operator}					{yylval.op = yytext[0]; return ADD_OPERATOR;}
{div_operator}					{yylval.op = yytext[0]; return DIV_OPERATOR;}
{pow_operator}					{yylval.op = yytext[0]; return POW_OPERATOR;}
{rel_operator}					{
						if(strcmp(yytext, "==") == 0) yylval.op = EQ;
						else if(strcmp(yytext, "!=") == 0) yylval.op = NE;
						else if(strcmp(yytext, ">=") == 0) yylval.op = GE;
						else if(strcmp(yytext, "<=") == 0) yylval.op = LE;
						else if(strcmp(yytext, ">") == 0) yylval.op = GT;
						else if(strcmp(yytext, "<") == 0) yylval.op = LT;
						return REL_OPERATOR;
		}
{logic_operator}				{
									if(yytext[0] == '!'){
										yylval.op = '!';
										return NEG_OPERATOR;
									}
									if(strcmp(yytext, "and") == 0) yylval.op = AND;
									else yylval.op = OR;
									return LOGIC_OPERATOR;
								}
{attribution}					{return yytext[0];}

{real_number}					{remover_espacos_e_print(_REAL); 
							createSymbol(&(yylval.symbol), NULL, _REAL, _REAL);
							(yylval.symbol)->data->v.real = atof(yytext);
							return REAL_NUMBER;} 
{number}						{remover_espacos_e_print(_NUMBER); 
							createSymbol(&(yylval.symbol), NULL, _INTEGER, _INTEGER);
							(yylval.symbol)->data->v.integer = atoi(yytext);
							return NUMBER;}

{identifier}					{ createSymbol(&(yylval.symbol), yytext, NOTHING, NOTHING);
									// (yylval.symbol)->data->v.integer = atoi(yytext);
									return IDENTIFIER;}

<supress_errors_condition>.		{}
";"+							{} /* ignorando ponto e virgula */
.								{PRINT((PRINT_ERROR "-> %s\nint_code_s0: %d\n", yylineno, yytext, yytext[0])) erro_encontrado = 1;} /* Ignorar o que nao foi definido */
<<EOF>>							{
				if(erro_encontrado){
					PRINT((PRINT_ERROR_EOF))
					exit(1);
				}
				return 0;
			}

%%
void remover_espacos_e_print(int t){
	char* s; /* tera a nova string sem os espacos em branco */
	int i, j, tam_yytext = strlen(yytext);
	s = (char*) malloc(tam_yytext*sizeof(char));
	j = 0;
	for(i = 0; i < tam_yytext; i++){
		if(yytext[i] == ' ' || yytext[i] == '\n' || yytext[i] == '\t')
			continue;
		s[j++] = yytext[i];
	}
	s[j] = '\0';

	strcpy(yytext, s);

	switch(t){
		case _REAL:
			//PRINT((PRINT_REAL_NUMBER PRINT_LEXEME, yylineno, s))
		break;
		case _NUMBER:
			//PRINT((PRINT_NUMBER PRINT_LEXEME, yylineno, s))
		break;
	}
	free(s);
}
int yywrap(){ return 1; } /* se EOF for encontrado, encerre. */

