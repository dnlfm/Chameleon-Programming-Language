%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "custom_defines.h"       


    extern int yylineno;
    extern FILE* yyin;
    int yylex();
    int yyerror(const char*);
    void raiseErrorVariableRedeclaration(char *lexem);
    void raiseError(char *msg);   
    void emit(char *msg);
    

    short flag_block_continue = 0; 
    int num_prox_instr = 0;
    FILE *arq_three_address_code;
    int id_temporario;
    int *_id_temporario;
    char type_names[][20] = {"???", "REAL", "FUNCTION", "INTEGER", "WORD", "SQUAD", "VARIABLE"};
    char rel_operators_str[][3] = {"==", "!=", ">=", "<=", ">", "<"};
    int line_backpatch_for_aux, line_backpatch_for_aux2;    
%}
    %code requires{
        #include "hash-table.h"
        #include "montador_lexer.h"
        void action_math_expression(Symbol *sd, Symbol *s1, char op, Symbol *s2);
        void action_math_expression_logic(Symbol *sd, Symbol *s1, char op, Symbol *s2);
        void action_math_expression_rel(Symbol *sd, Symbol *s1, char op, Symbol *s2);
        void action_math_expression_unary(Symbol *sd, char op, Symbol *s1);
        void emitBackpatch(int linha_origem, int linha_destino);
    }

    %union{
        Symbol *symbol;
        hashtable_t *symbol_table;
        char type_aux[20]; // apenas para print...
        char op;
        int type_declaration;
        int id_temporario;
    }

    %define parse.error verbose
    %define parse.lac full 
    %token WORD_VALUE
    %token NUMBER REAL_NUMBER
    %token SQUAD_ACCESS_DERREFERENCE
    %token INTEGER WORD REAL
    %token SQUAD ENDSQUAD
    %token VECTOR
    %token IDENTIFIER
    %token ADD_OPERATOR DIV_OPERATOR POW_OPERATOR LOGIC_OPERATOR 
    %token NEG_OPERATOR REL_OPERATOR WORD_CONCAT_OPERATOR
    %token GIVEUP
    %token BLOCK_BEGIN BLOCK_END
    %token SAY LISTEN
    %token IF ENDIF ELIF ENDELIF    
    %token FOR ENDFOR
    %token WHILE ENDWHILE 
    %token TASK ENDTASK   
    %token FAREWELL
    %token JUMPTO
    %token STOP

    %right '='
    %left ADD_OPERATOR NEG_OPERATOR
    %left DIV_OPERATOR
    %left POW_OPERATOR
    %left LOGIC_OPERATOR
    %left REL_OPERATOR
    %left '('    

    %start block
%%

    block: BLOCK_BEGIN {
        if(flag_block_continue){
            flag_block_continue = 0;            
            if(curr_symbol_table->brother_hash == NULL){
                hashtable_t *brother_symbol_table = $<symbol_table>1;                
                curr_symbol_table->brother_hash = brother_symbol_table;        
                curr_symbol_table = brother_symbol_table;
            } else{
                raiseError("O Brother e nao nulo!");
            }
            
        }
    } statement BLOCK_END block_continue {PRINT(("block -> [BLOCK_BEGIN statement BLOCK_END block_continue]\n"))}
        | task_command block_continue                     {PRINT(("block -> [task_command block_continue]\n"))}
    ;

    block_continue: /* palavra vazia */     {PRINT(("block_continue -> []\n"))}
                | { flag_block_continue = 1; } block                     {PRINT(("block_continue -> [block]\n"))}
    ;

    statement: /* palavra vazia */              {PRINT(("statement -> []\n"))}
            | command statement                 {PRINT(("statement -> [command statement]\n"))}
            | variable_declaration statement    {PRINT(("statement -> [variable_declaration statement]\n"))}
            | BLOCK_BEGIN {     
                    if(curr_symbol_table->child_hash != NULL){
                        while(curr_symbol_table->child_hash != NULL){
                            curr_symbol_table = curr_symbol_table->child_hash;
                        }
                        hashtable_t *brother_symbol_table = $<symbol_table>1;
                        curr_symbol_table->brother_hash = brother_symbol_table;
                        brother_symbol_table->previous_hash = curr_symbol_table->previous_hash;
                        curr_symbol_table = brother_symbol_table;
                    } else{          
                        hashtable_t *child_symbol_table = $<symbol_table>1;
                        child_symbol_table->previous_hash = curr_symbol_table;
                        curr_symbol_table->child_hash = child_symbol_table;
                        curr_symbol_table = child_symbol_table;
                    }
                } statement BLOCK_END {
                    if(curr_symbol_table->previous_hash != NULL)
                        curr_symbol_table = curr_symbol_table->previous_hash;
                } statement {PRINT(("statement -> [BLOCK_BEGIN statement BLOCK_END statement]\n"))}
    ;

    command: variable '=' expression        {PRINT(("command -> [variable '=' expression]\n"))
                                            //printf("--> %s %d\n", $<symbol>1->lexem, $<symbol>1->fake_memory_address);    
                                            if($<symbol>1 == NULL)
                                                raiseError("Variable is not declared!");
                                            if(!checkTypes($<symbol>1->data->type, $<symbol>3->data->type)){
                                                char *lexem_copy = strdup($<symbol>1->lexem);
                                                lexem_copy[strlen(lexem_copy)-4]='\0';
                                                char s[200]; sprintf(s, "Wrong data types in attribution - the variable %s is a %s and the value of the expression is a %s", 
                                                    lexem_copy, type_names[$<symbol>1->data->type], type_names[$<symbol>3->data->type]);
                                                free(lexem_copy);
                                                raiseError(s);
                                            }
                                            $<symbol>$ = $<symbol>1;
                                            if($<symbol>1->fake_memory_address != $<symbol>3->fake_memory_address){
                                                char s[200]; sprintf(s, "t%d = t%d", $<symbol>1->fake_memory_address, $<symbol>3->fake_memory_address); emit(s);
                                                if($<symbol>3->data->type == _INTEGER)
                                                    createADDi(&block_mount, $<symbol>1->fake_memory_address+1, $<symbol>3->fake_memory_address+1, $<symbol>3->data->v.integer);
                                                else
                                                    createADDi(&block_mount, $<symbol>1->fake_memory_address+1, $<symbol>3->fake_memory_address+1, 0);
                                            }
                                        }
            | variable '=' word_expression  {PRINT(("command -> [variable '=' word_expression]\n"))
                                            if($<symbol>1 == NULL)
                                                raiseError("Variable is not declared!");
                                            if(!checkTypes($<symbol>1->data->type, $<symbol>3->data->type)){                                                
                                                char *lexem_copy = strdup($<symbol>1->lexem);
                                                lexem_copy[strlen(lexem_copy)-4]='\0';
                                                char s[200]; sprintf(s, "Wrong data types in attribution - the variable %s is a %s and the value of the expression is a %s", 
                                                    lexem_copy, type_names[$<symbol>1->data->type], type_names[$<symbol>3->data->type]);
                                                free(lexem_copy);
                                                raiseError(s);
                                            }       
                                            $<symbol>$ = $<symbol>1;
                                            if($<symbol>1->fake_memory_address != $<symbol>3->fake_memory_address){                                     
                                                char s[200]; sprintf(s, "t%d = %s", $<symbol>1->fake_memory_address, $<symbol>3->data->v.word); emit(s);                                        
                                            }
                                        }            
            | variable '=' task_call        {PRINT(("command -> [variable '=' task_call]\n"))}            
            | givingup                      {PRINT(("command -> [givingup]\n"))}
            | if_command                    {PRINT(("command -> [if_command]\n"))}
            | for_command                   {PRINT(("command -> [for_command]\n"))}
            | while_command                 {PRINT(("command -> [while_command]\n"))}
            | farewell_command              {PRINT(("command -> [farewell_command]\n"))}
            | STOP                          {PRINT(("command -> [STOP]\n"))}
            | jumpto_command                {PRINT(("command -> [jumpto_command]\n"))}
            | say_command                   {PRINT(("command -> [say_command]\n"))}
            | listen_command                {PRINT(("command -> [listen_command]\n"))}            
            | task_call                     {PRINT(("command -> [task_call]\n"))}
            | label                         {PRINT(("command -> [label]\n"))} 
    ;

    say_command: SAY expression     {PRINT(("say_command -> [SAY expression]\n"))}
            | SAY word_expression   {PRINT(("say_command -> [SAY word_expression]\n"))}
    ;

    listen_command: LISTEN variable {PRINT(("LISTEN -> [variable]\n"))}
    ;

    if_cond: IF expression ':'      { PRINT(("if_cond -> [IF expression ':']\n"))                                    
                                    $<symbol>$ = $<symbol>2;
                                    sprintf($<symbol>$->to_emit, "ifFalse t%d goto ___", $<symbol>2->fake_memory_address); emit($<symbol>$->to_emit);  
                                    $<symbol>$->line_backpatch_risc = block_mount.num_inst;                                  
                                    createBeqEndi(&block_mount, $<symbol>2->fake_memory_address+1, 0, 0);
                                    $<symbol>$->line_backpatch = num_prox_instr;
                                }
    ;

    elif_cond: ELIF expression ':' { PRINT(("elif_cond -> [ELIF expression ':']\n"))                                    
                                    $<symbol>$ = $<symbol>2;
                                    sprintf($<symbol>$->to_emit, "ifFalse t%d goto ___", $<symbol>2->fake_memory_address); emit($<symbol>$->to_emit);    
                                    $<symbol>$->line_backpatch_risc = block_mount.num_inst;                                  
                                    createBeqEndi(&block_mount, $<symbol>2->fake_memory_address+1, 0, 0);                                
                                    $<symbol>$->line_backpatch = num_prox_instr;                                    
                                }
    ;

    if_command: if_cond statement ENDIF   {PRINT(("if_command -> [IF expression ':' statement ENDIF]\n"))                                    
                                    emitBackpatch($<symbol>1->line_backpatch, num_prox_instr);           
                                    block_mount.insts[$<symbol>1->line_backpatch_risc].endereco = num_prox_instr;                         
                                }
               | if_cond statement elif_cond statement ENDELIF {PRINT(("if_command -> [IF expression ':' statement ELIF expression ':' statement ENDELIF]\n"))
                                    emitBackpatch($<symbol>1->line_backpatch, $<symbol>3->line_backpatch - 2);
                                    emitBackpatch($<symbol>3->line_backpatch, num_prox_instr);
                                    block_mount.insts[$<symbol>1->line_backpatch_risc].endereco = $<symbol>3->line_backpatch - 2;
                                    block_mount.insts[$<symbol>3->line_backpatch_risc].endereco = num_prox_instr;
                                }
    ;	

    for_cond_aux: expression ':' { 
                                    PRINT(("for_cond_aux -> [expression ':']\n"))
                                    $<symbol>$ = $<symbol>1;
                                    $<symbol>$->line_backpatch = num_prox_instr;
                                    emitBackpatch(line_backpatch_for_aux, num_prox_instr+1);
                                    char *s = (char*) malloc(50*sizeof(char));                                                
                                    sprintf(s, "goto ___"); emit(s);  
                                    line_backpatch_for_aux = num_prox_instr;                                    
                                    free(s);
                            }
    ;

    for_cond: expression ',' expression ',' {
                                                PRINT(("for_cond -> [expression ',' expression ',']\n"))                                    
                                                $<symbol>$ = $<symbol>3;
                                                sprintf($<symbol>$->to_emit, "ifFalse t%d goto ___", $<symbol>3->fake_memory_address); emit($<symbol>$->to_emit);                                    
                                                $<symbol>$->line_backpatch = num_prox_instr;
                                                //$<symbol>$->line_backpatch_risc = block_mount.num_inst;                                  
                                                //createBeqEndi(&block_mount, $<symbol>2->fake_memory_address, 0, 0);
                                                char *s = (char*) malloc(50*sizeof(char));                                                
                                                sprintf(s, "goto ___"); emit(s);  
                                                free(s);        
                                                line_backpatch_for_aux = num_prox_instr;  
                                                line_backpatch_for_aux2 = num_prox_instr;
                                        }
    ;

    for_command: FOR for_cond for_cond_aux statement ENDFOR {
                PRINT(("for_command -> [FOR for_cond for_cond_aux statement ENDFOR]\n"))
                emitBackpatch(line_backpatch_for_aux, $<symbol>2->line_backpatch-2);
                char *s = (char*) malloc(50*sizeof(char));                                                
                sprintf(s, "goto %d", line_backpatch_for_aux2 + 1); emit(s);  
                free(s);
                emitBackpatch($<symbol>2->line_backpatch, num_prox_instr);
        }
    ;

    while_cond: expression ':'      {
                            PRINT(("expression -> [expression ':']\n"))                                    
                            $<symbol>$ = $<symbol>1;
                            sprintf($<symbol>$->to_emit, "ifFalse t%d goto ___", $<symbol>1->fake_memory_address); emit($<symbol>$->to_emit);                                    
                            $<symbol>$->line_backpatch = num_prox_instr;                            
                }
    ;

    while_command: WHILE while_cond statement ENDWHILE  {
                                PRINT(("while_command -> [WHILE expression ':' statement ENDWHILE]\n"))
                                $<symbol>$ = $<symbol>2;
                                sprintf($<symbol>$->to_emit, "goto %d", $<symbol>$->line_backpatch - 1); emit($<symbol>$->to_emit);
                                emitBackpatch($<symbol>2->line_backpatch, num_prox_instr);                                    
                            }
    ;

    farewell_command: FAREWELL expression   {PRINT(("farewell_command -> [FAREWELL expression]\n"))}
    ;

    task_command: TASK IDENTIFIER task_parameters ':' statement ENDTASK {PRINT(("task_command -> [TASK IDENTIFIER task_parameters ':' ENDTASK]\n"))
                    // TODO
                }
    ;
    
    task_parameter: expression                          {PRINT(("task_parameter -> [expression]\n"))}
                 | expression ',' task_parameter        {PRINT(("task_parameter -> [expression ',' task_parameter]\n"))}
    ;

    task_parameters: /* palavra vazia */    {PRINT(("task_parameter -> []\n"))}
                    | task_parameter        {PRINT(("task_parameter -> [task_parameter]\n"))}
    ;

    task_call: TASK IDENTIFIER '(' task_parameters ')'   {PRINT(("task_call -> [TASK IDENTIFIER '(' task_parameter ')']\n"))
                    if(ht_get(curr_symbol_table, $<symbol>2->lexem, 1) == NULL){
                        $<symbol>2->data->v.word = strdup($<type_aux>1);
                        ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                    }
                }
    ;

    jumpto_command: JUMPTO IDENTIFIER   {PRINT(("jumpto_command -> [JUMPTO IDENTIFIER]\n"))
                        if(ht_get(curr_symbol_table, $<symbol>2->lexem, 1) == NULL){
                            //$<symbol>2->data->v.word = strdup("jumpto");
                            ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                            $<symbol>$ = $<symbol>2;
                            char *lexem_copy = strdup($<symbol>2->lexem);                         
                            lexem_copy[strlen(lexem_copy)-4]='\0';
                            sprintf($<symbol>$->to_emit, "goto %s", lexem_copy); emit($<symbol>$->to_emit); 
                            free(lexem_copy);                                   
                            $<symbol>$->line_backpatch = num_prox_instr;
                        }
                    }    
    ;

    label: IDENTIFIER ':'       {PRINT(("label -> [IDENTIFIER ':']\n"))
                        if(ht_get(curr_symbol_table, $<symbol>1->lexem, 1) == NULL){
                            $<symbol>1->fake_memory_address = num_prox_instr;
                            ht_set(curr_symbol_table, $<symbol>1->lexem, $<symbol>2);                            
                        } /* else{
                            emitBackpatch($<symbol>2->line_backpatch, num_prox_instr);
                        }*/

                        $<symbol>$ = $<symbol>1;
                        char *lexem_copy = strdup($<symbol>1->lexem);                         
                        lexem_copy[strlen(lexem_copy)-4]=':';
                        lexem_copy[strlen(lexem_copy)-3]='\0';                        
                        sprintf($<symbol>$->to_emit, "%s", lexem_copy); emit($<symbol>$->to_emit);
                        free(lexem_copy);
                    } 
    ;    
        
    expression: math_expression         {PRINT(("expression -> [math_expression]\n"))
                                $<symbol>$ = $<symbol>1;
                                //$<id_temporario>$ = $<id_temporario>1;
                    }            
               | variable '=' expression    {PRINT(("expression -> [variable '=' expression]\n"))
                                if($<symbol>1 == NULL)
                                    raiseError("Variable is not declared!");
                                if(!checkTypes($<symbol>1->data->type, $<symbol>3->data->type)){
                                    char *lexem_copy = strdup($<symbol>1->lexem);
                                    lexem_copy[strlen(lexem_copy)-4]='\0';
                                    char s[200]; sprintf(s, "Wrong data types in attribution - the variable %s is a %s and the value of the expression is a %s", 
                                        lexem_copy, type_names[$<symbol>1->data->type], type_names[$<symbol>3->data->type]);
                                    free(lexem_copy);
                                    raiseError(s);
                                }
                                $<symbol>$ = $<symbol>1;
                                if($<symbol>1->fake_memory_address != $<symbol>3->fake_memory_address){
                                    sprintf($<symbol>$->to_emit, "t%d = t%d", $<symbol>1->fake_memory_address, $<symbol>3->fake_memory_address); emit($<symbol>$->to_emit);
                                    if($<symbol>3->data->type == _INTEGER)
                                        createADDi(&block_mount, $<symbol>1->fake_memory_address+1, $<symbol>3->fake_memory_address+1, $<symbol>3->data->v.integer);
                                    else
                                        createADDi(&block_mount, $<symbol>1->fake_memory_address+1, $<symbol>3->fake_memory_address+1, 0);
                                }
                    } 
    ;   

    ex_aux_abre: '(' math_expression ex_aux_fecha    {PRINT(("ex_aux_abre -> ['(' math_expression ex_aux_fecha]\n"))
                                                    $<symbol>$ = $<symbol>2;
                                                    //$<id_temporario>$ = $<id_temporario>2;
                                                }        
        | math_expression    {$<symbol>$ = $<symbol>1;}                                        
    ;

    ex_aux_fecha: ')'                           {PRINT(("ex_aux_fecha -> [')']\n"))}
    ;

    math_expression: ex_aux_abre ADD_OPERATOR ex_aux_abre   { PRINT(("math_expression -> [ex_aux_abre ADD_OPERATOR ex_aux_abre]\n"))
                                                                createSymbol(&($<symbol>$), "", $<symbol>1->token_type, $<symbol>1->data->type);
                                                                action_math_expression($<symbol>$, $<symbol>1, $<op>2, $<symbol>3); }
        | ex_aux_abre DIV_OPERATOR ex_aux_abre              { PRINT(("math_expression -> [ex_aux_abre DIV_OPERATOR ex_aux_abre]\n"))
                                                                createSymbol(&($<symbol>$), "", $<symbol>1->token_type, $<symbol>1->data->type);
                                                                action_math_expression($<symbol>$, $<symbol>1, $<op>2, $<symbol>3); }
        | ex_aux_abre POW_OPERATOR ex_aux_abre              { PRINT(("math_expression -> [ex_aux_abre POW_OPERATOR ex_aux_abre]\n"))
                                                                createSymbol(&($<symbol>$), "", $<symbol>1->token_type, $<symbol>1->data->type);
                                                                action_math_expression($<symbol>$, $<symbol>1, $<op>2, $<symbol>3); }
        | ex_aux_abre LOGIC_OPERATOR ex_aux_abre            { PRINT(("math_expression -> [ex_aux_abre LOGIC_OPERATOR ex_aux_abre]\n"))
                                                                createSymbol(&($<symbol>$), "", $<symbol>1->token_type, $<symbol>1->data->type);
                                                                action_math_expression_logic($<symbol>$, $<symbol>1, $<op>2, $<symbol>3); }
        | ex_aux_abre REL_OPERATOR ex_aux_abre              { PRINT(("math_expression -> [ex_aux_abre REL_OPERATOR ex_aux_abre]\n"))
                                                                createSymbol(&($<symbol>$), "", REL_OPERATOR, _INTEGER); action_math_expression_rel($<symbol>$, $<symbol>1, $<op>2, $<symbol>3); }
        | unary_operators ex_aux_abre %prec DIV_OPERATOR    { PRINT(("math_expression -> [unary_operators ex_aux_abre %%prec DIV_OPERATOR]\n"))
                                                                createSymbol(&($<symbol>$), "", $<symbol>2->token_type, $<symbol>2->data->type); 
                                                                action_math_expression_unary($<symbol>$, $<op>1, $<symbol>2);}
        | math_term                                         { PRINT(("math_expression -> [math_term]\n"))
            char s_aux[200];
            if($<symbol>1->token_type != _VARIABLE) {
                if($<symbol>1->fake_memory_address == -1) { $<symbol>1->fake_memory_address = id_temporario++; createDeclaration(&(block_mount), $<symbol>1->fake_memory_address + 1); }
                //printf("TIIIPO: %d\n", $<symbol>1->data->type);
                if($<symbol>1->data->type == _INTEGER) { sprintf(s_aux, "%d", $<symbol>1->data->v.integer);  
                    createADDi(&block_mount, $<symbol>1->fake_memory_address+1, $<symbol>1->fake_memory_address+1, $<symbol>1->data->v.integer); }
                else if($<symbol>1->data->type == _REAL) sprintf(s_aux, "%lf", $<symbol>1->data->v.real);
                else if($<symbol>1->data->type == _WORD) sprintf(s_aux, "%s", $<symbol>1->data->v.word);                            
                char s[1000]; sprintf(s, "t%d = %s", $<symbol>1->fake_memory_address, s_aux); emit(s);
            }
            $<symbol>$ = $<symbol>1;
            //$<id_temporario>$ = id_temporario++; char s[1000]; sprintf(s, "t%d = %s", $<id_temporario>$, s_aux); emit(s);
        }                                            
    ;    
    
    variable_declarations: variable_declaration                      {PRINT(("variable_declarations -> [variable_declaration]\n"))}
                        | variable_declaration variable_declarations {PRINT(("variable_declarations -> [variable_declaration variable_declarations]\n"))}
    ;
        /* {PRINT(("Squad encontrado %d\n", yylval))} guardando o yylval pra nao esquecermos */
    variable_declaration: type IDENTIFIER       {PRINT(("variable_declaration -> [type IDENTIFIER]\n"))
                                if(ht_get(curr_symbol_table, $<symbol>2->lexem, 0) == NULL){
                                    $<symbol>2->data->type = $<type_declaration>$;
                                    $<symbol>2->token_type = _VARIABLE;
                                    ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                                    createDeclaration(&(block_mount), $<symbol>2->fake_memory_address + 1);
                                } else{
                                    raiseErrorVariableRedeclaration($<symbol>2->lexem);
                                }
                            }
                          | squad_declaration   {PRINT(("variable_declaration -> [squad_declaration]\n"))}
                          | vector_declaration  {PRINT(("variable_declaration -> [vector_declaration]\n"))}
    ;
    
    vector_access: IDENTIFIER '[' NUMBER ']'        {PRINT(("vector_access -> [IDENTIFIER '[' NUMBER ']']\n"))
                                                        /* PRINT((PRINT_ERROR "-> %s\nint_code_s0\n", yylineno, $<symbol>3->lexem))*/}
                  | IDENTIFIER '[' IDENTIFIER ']'   {PRINT(("vector_access -> [IDENTIFIER '[' IDENTIFIER ']']\n"))}
    ;

    squad_access: IDENTIFIER SQUAD_ACCESS_DERREFERENCE IDENTIFIER        {PRINT(("squad_access -> [IDENTIFIER '->' IDENTIFIER ]\n"))}
                  |  squad_access SQUAD_ACCESS_DERREFERENCE IDENTIFIER   {PRINT(("squad_access -> [IDENTIFIER '->' IDENTIFIER ]\n"))}
    ;

    squad_declaration: SQUAD IDENTIFIER ':' variable_declarations ENDSQUAD {PRINT(("squad_declaration -> [SQUAD IDENTIFIER ':' variable_declarations ENDSQUAD]\n"))
                        if(ht_get(curr_symbol_table, $<symbol>2->lexem, 0) == NULL){
                            $<symbol>2->data->v.word = strdup($<type_aux>1);
                            ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                        } else{
                            raiseErrorVariableRedeclaration($<symbol>2->lexem);
                        }
    }
    ;

    vector_declaration: VECTOR IDENTIFIER NUMBER     {PRINT(("vector_declaration -> [VECTOR IDENTIFIER NUMBER]\n"))
                            if(ht_get(curr_symbol_table, $<symbol>2->lexem, 0) == NULL){
                                $<symbol>2->data->v.word = strdup($<type_aux>1);
                                ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                            } else{
                                raiseErrorVariableRedeclaration($<symbol>2->lexem);
                            }
                        }
                    | VECTOR IDENTIFIER IDENTIFIER   {PRINT(("vector_declaration -> [VECTOR IDENTIFIER IDENTIFIER]\n"))
                            if(ht_get(curr_symbol_table, $<symbol>2->lexem, 0) == NULL){
                                $<symbol>2->data->v.word = strdup($<type_aux>1);
                                ht_set(curr_symbol_table, $<symbol>2->lexem, $<symbol>2);
                            } else{
                                raiseErrorVariableRedeclaration($<symbol>2->lexem);
                            }
                    }
    ;

    type: INTEGER   {PRINT(("type -> [INTEGER]\n"))
                        $<type_declaration>$ = _INTEGER;
                }
        | REAL      {PRINT(("type -> [REAL]\n"))
                        $<type_declaration>$ = _REAL;
                }
        | WORD      {PRINT(("type -> [WORD]\n"))
                        $<type_declaration>$ = _WORD;
                }
    ;

    unary_operators: ADD_OPERATOR   {PRINT(("unary_operators -> [ADD_OPERATOR]\n")) $<op>$ = $<op>1;}
                    | NEG_OPERATOR  {PRINT(("unary_operators -> [NEG_OPERATOR]\n")) $<op>$ = $<op>1;}
    ;    

    word_term: WORD_VALUE       {PRINT(("word_term -> [WORD_VALUE]\n")) 
                                $<symbol>$ = $<symbol>1;
                            }
                | expression    {PRINT(("word_term -> [expression]\n"))}
    ;

    word_term_aux: word_term              {PRINT(("word_term_aux -> [word_term]\n")) 
                                            $<symbol>$ = $<symbol>1; 
                                        }
            | word_term WORD_CONCAT_OPERATOR word_term_aux  {PRINT(("word_term_aux -> [word_term WORD_CONCAT_OPERATOR word_term]\n"))
                                            $<symbol>$ = $<symbol>1;
                                            sprintf($<symbol>$->data->v.word, "%s%s", $<symbol>$->data->v.word, $<symbol>3->data->v.word);
                                }                    
    ;

    word_expression: WORD_VALUE              {PRINT(("word_expression -> [WORD_VALUE]\n"))
                                            $<symbol>$ = $<symbol>1;
                                }
                    | word_term WORD_CONCAT_OPERATOR word_term_aux  {PRINT(("word_expression -> [word_term WORD_CONCAT_OPERATOR expression]\n"))
                                            $<symbol>$ = $<symbol>1;
                                            sprintf($<symbol>$->data->v.word, "%s%s", $<symbol>$->data->v.word, $<symbol>3->data->v.word);
                                }                    
    ; 
    
    variable: IDENTIFIER    {PRINT(("variable -> [IDENTIFIER]\n"))
                            //printf("%s\n", $<symbol>1->lexem);
                            $<symbol>$ = ht_get(curr_symbol_table, $<symbol>1->lexem, 1);
                            if($<symbol>$ == NULL){
                                raiseError("Variable is not declared!");
                            }
                            //destroySymbol(&($<symbol>1));
                        }
            | vector_access {PRINT(("variable -> [vector_access]\n"))}
            | squad_access  {PRINT(("variable -> [squad_access]\n"))}
    ;

    math_term: NUMBER   {PRINT(("math_term -> [NUMBER]\n"))
                        $<symbol>$ = $<symbol>1;
            }
        | REAL_NUMBER   {PRINT(("math_term -> [REAL_NUMBER]\n"))
                        $<symbol>$ = $<symbol>1;
            }
        | variable      {PRINT(("math_term -> [variable]\n"))
                        $<symbol>$ = $<symbol>1;
            } /* ATENCAO A ESTA VARIAVEL AQUI */
    ;


    givingup: GIVEUP     {PRINT(("givingup -> [GIVEUP]\nADEUS :)\n")) 
                            exit(0);}
    ;

%%
    void action_math_expression(Symbol *sd, Symbol *s1, char op, Symbol *s2){
        if(sd->fake_memory_address == -1) { sd->fake_memory_address = id_temporario++; createDeclaration(&(block_mount), sd->fake_memory_address + 1); }
        upTypes(sd, s1->data->type, s2->data->type);
        sprintf(sd->to_emit, "t%d = t%d %c t%d", sd->fake_memory_address, s1->fake_memory_address, op, s2->fake_memory_address); 
        switch(op){
            case '+': createADD(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1); break;
            case '-': createSUB(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1); break;
            case '*': createMUL(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1); break;
            case '/': createDIV(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1); break;
        }
        //if($<symbol>2->token_type != _VARIABLE){ // imediato        
        emit(sd->to_emit);                        
    }

    void action_math_expression_logic(Symbol *sd, Symbol *s1, char op, Symbol *s2){
        if(sd->fake_memory_address == -1) { sd->fake_memory_address = id_temporario++; createDeclaration(&(block_mount), sd->fake_memory_address + 1); }
        upTypes(sd, s1->data->type, s2->data->type);
        switch((int)op){
            case AND: sprintf(sd->to_emit, "t%d = t%d AND t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case OR: sprintf(sd->to_emit, "t%d = t%d OR t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
        }        
        emit(sd->to_emit);                        
    }

    void action_math_expression_rel(Symbol *sd, Symbol *s1, char op, Symbol *s2){
        if(sd->fake_memory_address == -1) { sd->fake_memory_address = id_temporario++; createDeclaration(&(block_mount), sd->fake_memory_address + 1); }
        switch((int)op){
            case EQ: sprintf(sd->to_emit, "t%d = t%d == t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case NE: sprintf(sd->to_emit, "t%d = t%d != t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case GE: sprintf(sd->to_emit, "t%d = t%d >= t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case LE: sprintf(sd->to_emit, "t%d = t%d <= t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case GT: 
                createSgt(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1);
                sprintf(sd->to_emit, "t%d = t%d > t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;
            case LT: 
                createSlt(&block_mount, sd->fake_memory_address+1, s1->fake_memory_address+1, s2->fake_memory_address+1);
                sprintf(sd->to_emit, "t%d = t%d < t%d", sd->fake_memory_address, s1->fake_memory_address, s2->fake_memory_address); break;            
        }        
        emit(sd->to_emit);                        
    }

    void action_math_expression_unary(Symbol *sd, char op, Symbol *s1){
        if(sd->fake_memory_address == -1) { sd->fake_memory_address = id_temporario++; createDeclaration(&(block_mount), sd->fake_memory_address + 1); }
        switch(op){
            case '!': sprintf(sd->to_emit, "t%d = !t%d", s1->fake_memory_address, s1->fake_memory_address); break;
            case '-': sprintf(sd->to_emit, "t%d = -t%d", s1->fake_memory_address, s1->fake_memory_address); break;
        }
        emit(sd->to_emit);    
    }

    void raiseError(char *msg){
        fprintf(stderr, "Near line: %d ---> Error: %s <---\n\n", yylineno, msg);
        emit("--ERRO--");
        fclose(arq_three_address_code);
        exit(1);
        //yyerror(msg);
    }

    void raiseErrorVariableRedeclaration(char *lexem){
        char error_msg[50];
        char *lexem_copy = strdup(lexem);
        lexem_copy[strlen(lexem_copy)-4]='\0';
        sprintf(error_msg, "The variable %s has already been declared before!", lexem_copy);
        free(lexem_copy);
        yyerror(error_msg);
    }

    int yyerror(const char *s){
        fprintf(stderr, "Line: %d ---> %s <---\n\n", yylineno, s);
        emit("--ERRO--");
        fclose(arq_three_address_code);
        exit(1);
    }

    void emitBackpatch(int linha_origem, int linha_destino){
        fclose(arq_three_address_code);
        arq_three_address_code = NULL;
        FILE *arq_three_address_code_temp = NULL;
        arq_three_address_code = fopen("arq_three_address_code_generated", "r"); // abrindo para leitura
        arq_three_address_code_temp = fopen("arq_three_address_code_generated_temp", "w"); // abrindo para escrita
        if(arq_three_address_code == NULL){
            raiseError("Nao foi possivel abrir para escrita o arquivo 'arq_three_address_code_generated'\n");
        }
        if(arq_three_address_code_temp == NULL){
            raiseError("Nao foi possivel abrir para escrita o arquivo 'arq_three_address_code_generated_temp'\n");
        }
        int count = 0;
        char buffer[255];
        while ((fgets(buffer, 255, arq_three_address_code)) != NULL)
        {
            count++;

            /* If current line is line to replace */
            if (count == linha_origem){
                buffer[strlen(buffer)-4] = '\0';
                char *str_aux = (char*) malloc(20*sizeof(char));
                sprintf(str_aux, "%d\n", (linha_destino+1));
                strcat(buffer, str_aux);
                free(str_aux);
                fputs(buffer, arq_three_address_code_temp);
            } else {
                fputs(buffer, arq_three_address_code_temp);
            }
        }

        fclose(arq_three_address_code);
        fclose(arq_three_address_code_temp);

        remove("arq_three_address_code_generated");

        rename("arq_three_address_code_generated_temp", "arq_three_address_code_generated");       
        arq_three_address_code = fopen("arq_three_address_code_generated", "a+"); // abrindo para append para continuar o processo
    }

    void emit(char *msg){
        printf("%s\n", msg);
        fprintf(arq_three_address_code, "%s\n", msg);
        num_prox_instr++;
    }

    void emitSymbol(Symbol *symbol){
        PRINT(("%d", symbol->data->v.integer))
        //PRINT(("%s", symbol->to_emit))
        //PRINT((symbol->))
        /*switch(symbol->token_type){
            case _VARIABLE: {
                PRINT(("t%d", symbol->data->v.integer))
                //switch(symbol->data->token_type){
                //    case 
                //}
            } break;
        }*/
    }

    void emitCode(){
        hashtable_t *hashtable = first_symbol_table;
        if(hashtable == NULL){
                return;
        }   
        hashtable_t *st = hashtable;         
        int i = 0;
        entry_t *pair;
        
        pair = hashtable->first_entry;
        printf("IMPRIMINDO CODIGO\n");
        while(pair != NULL){
            Symbol *s = pair->value;     
            emitSymbol(s);              
            
            pair = pair->next;
        }
        
        
        if(hashtable->child_hash != NULL){ // imprime os filhos primeiro
                ht_print(hashtable->child_hash);
        }
        if(hashtable->brother_hash != NULL){
                ht_print(hashtable->brother_hash);
        }
    }
    
    int main(int argc, char *argv[]){
        first_symbol_table = NULL;
        curr_symbol_table = NULL;        
        id_temporario = 0;//MAX_TAM_HASH;
        _id_temporario = &id_temporario;

        block_mount = createBlock();
        //printf("Numero de parametros: %d\n", argc);        
        if(argc == 2){
            //FILE *f;
            if(!(yyin = fopen(argv[1], "r"))){
                PRINT(("Could not open the file!\n"))
                return 0;
            }
            char c;
            printf("-------------- Readed Code --------------\n\n");
            printf("1 ");
            int l = 2;
            while((c = fgetc(yyin)) != EOF){                
                printf("%c", c);
                if(c == '\n'){
                    printf("%d ", l++);
                }
            }
            printf("\n\n");
            rewind(yyin);
        }
        arq_three_address_code = NULL;
        arq_three_address_code = fopen("arq_three_address_code_generated", "w");
        if(arq_three_address_code == NULL){
            raiseError("Nao foi possivel abrir para escrita o arquivo 'arq_three_address_code_generated'\n");
        }
        int r = yyparse();        
        //ht_print(first_symbol_table);
        //emitCode();        
        fclose(arq_three_address_code);
        imprimeRISCV(&block_mount);
        imprimeLLVM(&block_mount);
        return r;
    }






























































