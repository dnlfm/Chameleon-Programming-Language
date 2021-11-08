#include "hash-table.h"
extern int *_id_temporario;
// Create a new hashtable.
hashtable_t *ht_create( int size ) {
        
        hashtable_t *hashtable = NULL;
        int i;

        if( size < 1 ) return NULL;

        // Allocate the table itself.
        if( ( hashtable = malloc( sizeof( hashtable_t ) ) ) == NULL ) {
                return NULL;
        }

        // Allocate pointers to the head nodes.
        if( ( hashtable->table = malloc( sizeof( entry_t * ) * size ) ) == NULL ) {
                return NULL;
        }
        for( i = 0; i < size; i++ ) {
                hashtable->table[i] == NULL;
        }

        hashtable->size = size;
        hashtable->first_entry = NULL;
        hashtable->previous_hash = NULL;
        hashtable->brother_hash = NULL;
        hashtable->child_hash = NULL;

        return hashtable;
}

// Hash a string for a particular hash table.
int ht_hash( hashtable_t *hashtable, char *key ) {
/*
        int hashval;
        int i = 0;
        //printf("Imakey %s  %d\n", key, strlen( key ));
        // Convert our string to an integer
        while( hashval < UINT_MAX && i < strlen( key ) ) {
                hashval = hashval << 4;
                hashval += key[ i ];
                i++;
        }
        //printf("HASHVAL: %ul    %d      %d\n", hashval, hashtable->size, hashval % hashtable->size);
        printf("PPPPPPPPPPPPPPPPPPPPPPPPPPPPP: %d\n\n", hashval);
        return hashval % hashtable->size;
*/
        unsigned long hash = hashtable->size;
        int c;

        while (c = *key++) {
                hash = ((hash << 5) + hash) + c; /* hash * 33 + c */ /* https://stackoverflow.com/questions/2535284/how-can-i-hash-a-string-to-an-int-using-c */
        }

        return ((unsigned int) hash) % hashtable->size;
}

// Create a key-value pair.
entry_t *ht_newpair( char *key, Symbol *value ) {
        entry_t *newpair;

        if( ( newpair = malloc( sizeof( entry_t ) ) ) == NULL ) {
                return NULL;
        }

        if( ( newpair->key = strdup( key ) ) == NULL ) {
                return NULL;
        }

        if( ( newpair->value = value ) == NULL ) {
                return NULL;
        }

        newpair->next = NULL;

        return newpair;
}

// Insert a key-value pair into a hash table. 
void ht_set( hashtable_t *hashtable, char *key, Symbol *value ) {
        int bin = 0;
        entry_t *newpair = NULL;
        entry_t *next = NULL;
        entry_t *last = NULL;

        bin = ht_hash( hashtable, key );
        //printf("BBBBBBBBIN INSEEEERT: %d %s\n", bin, key);

        next = hashtable->table[ bin ];
        
        while( next != NULL && next->key != NULL && strcmp( key, next->key ) > 0 ) {
                last = next;
                next = next->next;
        }

        // There's already a pair.  Let's replace that string.
        if( next != NULL && next->key != NULL && strcmp( key, next->key ) == 0 ) {

                //free( next->value );
                //printf("TTTTTT\n");
                destroySymbol(&(next->value));
                next->value = value;

        // Nope, could't find it.  Time to grow a pair.
        } else {
                //printf("YYYYYYYYY %d\n", bin);
                newpair = ht_newpair( key, value );
                newpair->value->fake_memory_address = (*_id_temporario)++;
                //newpair->value->fake_memory_address = bin;
                if(hashtable->first_entry == NULL){
                        hashtable->first_entry = newpair;
                }
                // We're at the start of the linked list in this bin.
                if( next == hashtable->table[ bin ] ) {
                        newpair->next = next;
                        hashtable->table[ bin ] = newpair;
        
                // We're at the end of the linked list in this bin.
                } else if ( next == NULL ) {
                        last->next = newpair;
        
                // We're in the middle of the list.
                } else  {
                        newpair->next = next;
                        last->next = newpair;
                }
        }
}

// Retrieve a key-value pair from a hash table.
Symbol *ht_get( hashtable_t *hashtable, char *key, int find_fathers ) {
        int bin = 0;
        entry_t *pair;
        //printf("CHAVE: %s\n", key);
        bin = ht_hash( hashtable, key );
        //printf("BBBBBBBBIN GGEEEET: %d %s\n", bin, key);
        //printf("%d\n", bin);
        // Step through the bin, looking for our value.
        pair = hashtable->table[ bin ];
        while( pair != NULL && pair->key != NULL && strcmp( key, pair->key ) > 0 ) {
                pair = pair->next;
        }

        // Did we actually find anything?
        if( pair == NULL || pair->key == NULL || strcmp( key, pair->key ) != 0 ) {
                /*//printf("AAAAAAA\n");
                if(pair == NULL) printf("ee\n");
                else if(pair->key == NULL) printf("ff\n");
                else if(strcmp( key, pair->key ) != 0) printf("ggg\n");*/
                //return pair->value;
                if(hashtable->previous_hash != NULL && find_fathers == 1){
                        return ht_get(hashtable->previous_hash, key, find_fathers );
                }
                return NULL;

        } else {
                return pair->value;
        }
        
}

void ht_print( hashtable_t *hashtable ){
        if(hashtable == NULL){
                return;
        }   
        hashtable_t *st = hashtable;         
        int i = 0;
        entry_t *pair;
        printf("\n------------------------------------- SYMBOL TABLE ------------------------------------\n\n");
        int t_max = 43;
        int t = t_max-strlen("Lexem");
        printf("Lexem%*s%*s\n\n", t <= 0 ? 1 : t, "Data Type", t_max, "Memory Address (fake)");
        for(i = 0; i < st->size; i++){
                pair = st->table[i];
                if(pair != NULL){
                        //char *key = pair->key;
                        Symbol *s = pair->value;       
                        //printf("AAAAAAAAAAAAAAAAAAAAAAA\n");                 
                        char *lexem_copy = strdup(s->lexem);
                        //printf("BBBBBBBBBBBBBBBBBBBBB\n");  
                        lexem_copy[strlen(lexem_copy)-4]='\0';
                        //printf("CCCCCCCCCCCCCCCCCCC\n");  
                        int t = t_max-strlen(lexem_copy);
                        //printf("CCCCCCCCCCCCCCCCCCC\n");  
                        //printf("%s%*s%*d\n", lexem_copy, t <= 0 ? 1 : t, s->data->v.word, t_max, pair->fake_memory_address);    
                        // TODO: Trocar essa impressao -> Não temos apenas word agora para imprimir, temos diversos outros valores!
                        // TODO: Trocar essa impressao -> Não temos apenas word agora para imprimir, temos diversos outros valores!
                        // TODO: Trocar essa impressao -> Não temos apenas word agora para imprimir, temos diversos outros valores!
                        // TODO: Trocar essa impressao -> Não temos apenas word agora para imprimir, temos diversos outros valores!
                        //printf("CCCCCCCCCCCCCCCCCCC\n");  
                        free(lexem_copy);                    
                }
        }
        printf("\n-------------------------------------------------------------------------------------------------\n\n");
        
        if(hashtable->child_hash != NULL){ // imprime os filhos primeiro
                ht_print(hashtable->child_hash);
        }
        if(hashtable->brother_hash != NULL){
                ht_print(hashtable->brother_hash);
        }
}