import sys

def match(term,lst,used):
    if lst[0].strip() == term:
       # print(lst)
        if lst[1].strip() in keywords.values():
            print("palavras chave repetidas!!!")
            exit(1)
        s = lst[1].strip()
        used.append(s)
        keywords[term] = s
        return True

def ordenarVetorPeloTamanho(used):
    return used.sort(key=len, reverse=True)     

#return, func, goto, break, print, input, float, string, const, if/else
keywords = {}
defs = {}
used = []
block = "Chameleon"

keywords["farewell"] = None
keywords["task"] = None
keywords["stop"] = None
keywords["jumpto"] = None
keywords["say"] = None
keywords["listen"] = None
keywords["if"] = None
keywords["elif"] = None
keywords["for"] = None
keywords["while"] = None

keywords["real"] = None
keywords["word"] = None
keywords["integer"] = None
keywords["vector"] = None
keywords["squad"] = None

keywords["+"] = None
keywords["-"] = None
keywords["*"] = None
keywords["/"] = None
keywords["%"] = None
keywords["="] = None
keywords["=="] = None
keywords["^"] = None
keywords["!"] = None
keywords["!="] = None
keywords[">="] = None
keywords["<="] = None
keywords[">"] = None
keywords["<"] = None
keywords["and"] = None
keywords["or"] = None
keywords[","] = None
keywords["."] = None
keywords["//"] = None
keywords['\\\\'] = None


name = ""

#MAIN
if len(sys.argv) > 1:
    name = sys.argv[1]
else:
    print("n")
    exit(1)

arquivo_in = open(name, 'r')
arquivo_out = open(name+'.out', 'w')

init = False
code = False
tokens = []
pilha = []
arquivo_out.write('begin\n')
for line in arquivo_in:
    #print(line)
    if line.find("#MACROS") != -1:
        print("bloco de macros")
        init = True

    if line.find("#ENDMACROS") != -1:
        init = False

    done = False    
    if init:
        lst = line.split(":")
        if lst[0].strip() == 'def':
            defs[lst[1].strip()] = lst[2].strip()
        elif lst[0].strip() == 'block':
            block = lst[1].strip()
            if block == "Pascal":
                keywords[":"] = "begin"
                used.append("begin")

            elif block == "C":
                keywords[":"] = "{"
                used.append("{")

        for term in keywords.keys():
            if done:
                break
            done = match(term,lst,used)

    if line.find("#ENDCOD") != -1:
        code = False

    if code:
        line2 = line.strip()
        lst = line2.split(" ")

        print(lst)

        for i in range(len(lst)):
            for item in used:
                if lst[i].find(item) != -1:
                   #print(item)
                   for k in keywords.keys():
                       if item == keywords[k]:
                           lst[i] = lst[i].replace(item,k)
                   break
        #print(lst)
        tokens.append(lst)
        
        for l in lst:
            if(block == "C"):
                commands = ["while", "if", "task", "squad", "for"]

                print("LLLLLLLL",l)
                if l in commands:
                    pilha.append(l)
                elif l == "}elif":
                    pilha.pop()
                    l = "elif"
                    pilha.append(l)
                elif l == "}":
                    l = "end"+pilha.pop()

            elif(block == "Pascal"):
                commands = ["while", "if", "task", "squad", "for"]

                print("LLLLLLLL",l)
                if l in commands:
                    pilha.append(l)
                elif l == "elif":
                    pilha.pop()
                    pilha.append(l)
                elif l == "end":
                    l = "end"+pilha.pop()

            print("PILHAAAA",pilha)
            arquivo_out.write(l+" ")
        arquivo_out.write("\n")
       # print(line)

    if line.find("#COD") != -1:
        ordenarVetorPeloTamanho(used)
        print(used)
        print("bloco de macros")
        code = True
arquivo_out.write('end')

#print(keywords)
print("TOKENS",tokens)
#print(defs)
#print(block)



















