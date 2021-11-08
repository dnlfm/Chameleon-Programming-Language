#include "montador_lexer.h"

Block createBlock(){
    Block b;
    b.num_inst = 0;
    return b;
}

void imprimeRISCV(Block *b){
    printf("RISC\n");
    
    	FILE *risc_file = NULL;
    	
    	char buffer[1000];
	
	risc_file = fopen("cod.asm", "w"); // abrindo para escrita
	if(risc_file == NULL){
	    printf("Nao foi possivel abrir para escrita o arquivo 'arq_three_address_code_generated'\n");
	}
        
    for(int i=0; i<b->num_inst;i ++){
        if(b->insts[i].op == "ADD" || b->insts[i].op == "MUL" || b->insts[i].op == "DIV" || b->insts[i].op == "AND" || b->insts[i].op =="OR" || b->insts[i].op =="SLT" || b->insts[i].op =="SGT"){
            printf("%s t%d, t%d, t%d\n",b->insts[i].op, b->insts[i].rd, b->insts[i].src1,b->insts[i].src2);
            sprintf(buffer, "%s t%d, t%d, t%d\n",b->insts[i].op, b->insts[i].rd, b->insts[i].src1,b->insts[i].src2);
	    fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "SUB"){
            printf("ADD t%d, t%d, -t%d\n", b->insts[i].rd, b->insts[i].src1,b->insts[i].src2);
            sprintf(buffer, "ADD t%d, t%d, -t%d\n", b->insts[i].rd, b->insts[i].src1,b->insts[i].src2);
	    fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "ADDi" || b->insts[i].op == "MULi" || b->insts[i].op == "DIVi" || b->insts[i].op == "ANDi"){
            printf("%s t%d, t%d, %d\n",b->insts[i].op, b->insts[i].rd, b->insts[i].src1,b->insts[i].imediato);
            sprintf(buffer, "%s t%d, t%d, %d\n",b->insts[i].op, b->insts[i].rd, b->insts[i].src1,b->insts[i].imediato);
	    fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "SUBi"){
            printf("ADDi t%d, t%d, %d\n", b->insts[i].rd, b->insts[i].src1,b->insts[i].imediato);
            sprintf(buffer, "ADDi t%d, t%d, %d\n", b->insts[i].rd, b->insts[i].src1,b->insts[i].imediato);
	    fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "BEQi"){
            printf("BEQi t%d, t%d, %s\n", b->insts[i].src1,b->insts[i].imediato, b->insts[i].label);
            sprintf(buffer, "BEQi t%d, t%d, %s\n", b->insts[i].src1,b->insts[i].imediato, b->insts[i].label);
	    fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "BEQiend"){
           printf("BEQi t%d, t%d, %d\n", b->insts[i].src1,b->insts[i].imediato, b->insts[i].endereco);
           sprintf(buffer, "BEQi t%d, t%d, %d\n", b->insts[i].src1,b->insts[i].imediato, b->insts[i].endereco);
	   fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "label"){
           printf("%s :\n", b->insts[i].label);
           sprintf(buffer, "%s :\n", b->insts[i].label);
	   fputs(buffer, risc_file);
        }
        if(b->insts[i].op == "labelint"){
           printf("%d :\n", b->insts[i].labelint);
           sprintf(buffer, "%d :\n", b->insts[i].labelint);
	   fputs(buffer, risc_file);
        }
    }
    fclose(risc_file);
}

void imprimeLLVM(Block *b){
	FILE *llvm_file = NULL;
	
	llvm_file = fopen("cod.ll", "w"); // abrindo para escrita
        if(llvm_file == NULL){
            printf("Nao foi possivel abrir para escrita o arquivo 'arq_three_address_code_generated'\n");
        }

	char * target_dalila = "\"x86_64-unknown-linux-gnu\"";
	char * so_dalila = "!1 = !{!\"clang version 11.0.0 (Fedora 11.0.0-2.fc33)\"} ";
	char * target_daniel = "\"x86_64-pc-linux-gnu\"";
	char * so_daniel = "!1 = !{!\"clang version 10.0.0-4ubuntu1 \"}";
	
	char * attributes0 = "attributes #0 = { noinline nounwind optnone uwtable \"correctly-rounded-divide-sqrt-fp-math\"=\"false\" \"disable-tail-calls\"=\"false\" \"frame-pointer\"=\"all\" \"less-precise-fpmad\"=\"false\" \"min-legal-vector-width\"=\"0\" \"no-infs-fp-math\"=\"false\" \"no-jump-tables\"=\"false\" \"no-nans-fp-math\"=\"false\" \"no-signed-zeros-fp-math\"=\"false\" \"no-trapping-math\"=\"true\" \"stack-protector-buffer-size\"=\"8\" \"target-cpu\"=\"x86-64\" \"target-features\"=\"+cx8,+fxsr,+mmx,+sse,+sse2,+x87\" \"unsafe-fp-math\"=\"false\" \"use-soft-float\"=\"false\" }";
	
	char * attributes1 ="attributes #1 = { \"correctly-rounded-divide-sqrt-fp-math\"=\"false\" \"disable-tail-calls\"=\"false\" \"frame-pointer\"=\"all\" \"less-precise-fpmad\"=\"false\" \"no-infs-fp-math\"=\"false\" \"no-nans-fp-math\"=\"false\" \"no-signed-zeros-fp-math\"=\"false\" \"no-trapping-math\"=\"true\" \"stack-protector-buffer-size\"=\"8\" \"target-cpu\"=\"x86-64\" \"target-features\"=\"+cx8,+fxsr,+mmx,+sse,+sse2,+x87\" \"unsafe-fp-math\"=\"false\" \"use-soft-float\"=\"false\" }"; 
	
	
	char * flags = "!llvm.module.flags = !{!0}";
	char * ident = "!llvm.ident = !{!1}";
	char * wchar_size = "!0 = !{i32 1, !\"wchar_size\", i32 4}";
	char * codigo = "define dso_local i32 @main() #0 {";
	char * codigo_ret = "  ret i32 0\n}";
	
	char * declare = "declare dso_local i32 @printf(i8*, ...) #1";
	
	char buffer[1000];	
	printf("\ntarget  triple = %s\n\n",target_dalila);
	sprintf(buffer, "\ntarget  triple = %s\n\n",target_dalila);
	fputs(buffer, llvm_file);	
	
	
	printf("@.str = private unnamed_addr constant [3 x i8] c\"%%d\\0A\", align 1\n\n");
	sprintf(buffer, "@.str = private unnamed_addr constant [3 x i8] c\"%%d\\0A\", align 1\n\n");
	fputs(buffer, llvm_file);
	
	printf("%s\n",codigo);
	sprintf(buffer, "%s", codigo);
	fputs(buffer, llvm_file);

	int t[100];
	int declara[100];
	int k = 1;
	
	printf("  %%1 = alloca i32, align 4\n");
	sprintf(buffer, "  %%1 = alloca i32, align 4\n");
	fputs(buffer, llvm_file);
	
	printf("  store i32 0, i32* %%1, align 4\n");
	sprintf(buffer, "  store i32 0, i32* %%1, align 4\n");
	fputs(buffer, llvm_file);
	k++;
	
	  	  
	//TODO: imprimir instrucoes
	for(int i=0; i<b->num_inst;i ++){
		if(b->insts[i].op == "DEC"){
			t[b->insts[i].rd] = k;
			declara[b->insts[i].rd] = k;
			printf("  %%%d = alloca i32, align 4\n",k);
			sprintf(buffer, "  %%%d = alloca i32, align 4\n",k);
			fputs(buffer, llvm_file);
	
			printf("  store i32 0, i32* %%%d, align 4\n",k);
			sprintf(buffer, "  store i32 0, i32* %%%d, align 4\n",k);
			fputs(buffer, llvm_file);
		
			k++;
		}
		if(b->insts[i].op == "ADD"){ //  %6 = add nsw i32 %4, %5
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = add nsw i32 %%%d, %%%d\n", k, k-1, k-2);
			sprintf(buffer, "  %%%d = add nsw i32 %%%d, %%%d\n", k, k-1, k-2);
			fputs(buffer, llvm_file);
			
			printf("  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			sprintf(buffer, "  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;				
		}
		if(b->insts[i].op == "ADDi"){ //    %4 = add nsw i32 %3, 99
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = add nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			sprintf(buffer, "  %%%d = add nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			fputs(buffer, llvm_file);
				
			printf("  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			sprintf(buffer, "  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;
		}
		if(b->insts[i].op == "SUB"){ //  %6 = add nsw i32 %4, %5
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = sub nsw i32 %%%d, %%%d\n", k, k-2, k-1);
			sprintf(buffer, "  %%%d = sub nsw i32 %%%d, %%%d\n", k, k-2, k-1);
			fputs(buffer, llvm_file);
			printf("  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			sprintf(buffer,"  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;				
		}
		if(b->insts[i].op == "SUBi"){ //    %4 = add nsw i32 %3, 99
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = sub nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			sprintf(buffer, "  %%%d = sub nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			fputs(buffer, llvm_file);	
			printf("  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			sprintf(buffer, "  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;
		}
		if(b->insts[i].op == "DIV"){ //  %6 = add nsw i32 %4, %5
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = sdiv i32 %%%d, %%%d\n", k, k-2, k-1);
			sprintf(buffer, "  %%%d = sdiv i32 %%%d, %%%d\n", k, k-2, k-1);
			fputs(buffer, llvm_file);
			printf("  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			sprintf(buffer, "  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;				
		}
		if(b->insts[i].op == "DIVi"){ //    %4 = add nsw i32 %3, 99
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = sdiv i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			sprintf(buffer, "  %%%d = sdiv i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			fputs(buffer, llvm_file);	
			printf("  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			sprintf(buffer, "  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);			
			k++;
		}
		if(b->insts[i].op == "MUL"){ //  %6 = add nsw i32 %4, %5
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src2]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = mul nsw i32 %%%d, %%%d\n", k, k-1, k-2);
			sprintf(buffer, "  %%%d = mul nsw i32 %%%d, %%%d\n", k, k-1, k-2);
			fputs(buffer, llvm_file);
			printf("  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);	
			sprintf(buffer, "  store i32 %%%d, i32* %%%d, align 4\n", k, declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);		
			k++;				
		}
		if(b->insts[i].op == "MULi"){ //    %4 = add nsw i32 %3, 99
			printf("  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			sprintf(buffer, "  %%%d = load i32, i32* %%%d, align 4\n",k, declara[b->insts[i].src1]);
			fputs(buffer, llvm_file);
			k++;
			
			t[b->insts[i].rd] = k;
			
			printf("  %%%d = mul nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);	
			sprintf(buffer, "  %%%d = mul nsw i32 %%%d, %d\n", k, k-1, b->insts[i].imediato);
			fputs(buffer, llvm_file);
			printf("  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);		
			sprintf(buffer, "  store i32 %d, i32* %%%d, align 4\n", b->insts[i].imediato ,declara[b->insts[i].rd]);
			fputs(buffer, llvm_file);	
			k++;
		}
	}
	
	printf("  %%%d = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32 %%%d)\n", k, k-1);
	sprintf(buffer, "  %%%d = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32 %%%d)\n", k, k-1);
	fputs(buffer, llvm_file);	
	
	printf("%s\n",codigo_ret);
	sprintf(buffer, "%s\n",codigo_ret);
	fputs(buffer, llvm_file);
	
	printf("\n%s\n\n",declare);
	sprintf(buffer, "\n%s\n\n",declare);
	fputs(buffer, llvm_file);
	
	printf("\n%s\n\n",attributes0);
	sprintf(buffer, "\n%s\n\n",attributes0);
	fputs(buffer, llvm_file);
	
	printf("\n%s\n\n",attributes1);
	sprintf(buffer, "\n%s\n\n",attributes1);
	fputs(buffer, llvm_file);
	
	printf("%s\n",flags);
	sprintf(buffer, "%s\n",flags);
	fputs(buffer, llvm_file);
	
	printf("%s\n\n",ident);
	sprintf(buffer, "%s\n\n",ident);
	fputs(buffer, llvm_file);
	
	printf("%s\n",wchar_size);
	sprintf(buffer, "%s\n",wchar_size);
	fputs(buffer, llvm_file);
	
	printf("%s\n",so_dalila);
	sprintf(buffer, "%s\n",so_dalila);
	fputs(buffer, llvm_file);
	
	fclose(llvm_file);
}

void createDeclaration(Block *b, int rd_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "DEC";
        b->insts[b->num_inst].rd = rd_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}
//and rd, a, b
void createAnd(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "AND";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createADD(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "ADD";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createSUB(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "SUB";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createMUL(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "MUL";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createDIV(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "DIV";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createADDi(Block *b, int rd_int, int src1_int, int imediato){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "ADDi";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = imediato;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createSUBi(Block *b, int rd_int, int src1_int, int imediato){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "SUBi";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = imediato;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createMULi(Block *b, int rd_int, int src1_int, int imediato){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "MULi";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = imediato;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createDIVi(Block *b, int rd_int, int src1_int, int imediato){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "DIVi";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = imediato;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createAndi(Block *b, int rd_int, int src1_int, int imediato){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "AND";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = imediato;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createOr(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "OR";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

//Dificil no RISC: 2 instrucoes
void createNot(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "NOT";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createSlt(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "SLT";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createSgt(Block *b, int rd_int, int src1_int, int src2_int){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "SGT";
        b->insts[b->num_inst].rd = rd_int;
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].src2 = src2_int;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}


void createBeqi(Block *b, int src1_int, int boolean, char * label){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "BEQi";
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = boolean;
        b->insts[b->num_inst].label = label;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createBeqEndi(Block *b, int src1_int, int boolean, int endereco){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "BEQiend";
        b->insts[b->num_inst].src1 = src1_int;
        b->insts[b->num_inst].imediato = boolean;
        b->insts[b->num_inst].endereco = endereco;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createLabel(Block *b, char * label){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "label";
        b->insts[b->num_inst].label = label;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}

void createLabelInt(Block *b, int labelint){
    if(b->num_inst < 50){
        b->insts[b->num_inst].op = "labelint";
        b->insts[b->num_inst].labelint = labelint;
        b->num_inst++;
    } else {
        printf("You have achived the maximum size of the instruction set!");
    }
}




