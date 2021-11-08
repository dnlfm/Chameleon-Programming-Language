// https://gist.github.com/tonious/1377667/d9e4f51f05992f79455756836c9371942d0f0cee

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include "symbol.h"

#define MAX_TAM_HASH 500

struct entry_s {        
        char *key;
        Symbol *value;
        struct entry_s *next;
};

typedef struct entry_s entry_t;
typedef struct hashtable_s hashtable_t;

struct hashtable_s {
        int size;
        entry_t *first_entry;
        struct entry_s **table; 
        hashtable_t *previous_hash;
        hashtable_t *child_hash;
        hashtable_t *brother_hash;
};

hashtable_t *first_symbol_table; // global
hashtable_t *curr_symbol_table; // global

hashtable_t *ht_create( int size );
int ht_hash( hashtable_t *hashtable, char *key ) ;
entry_t *ht_newpair( char *key, Symbol *value ) ;
void ht_set( hashtable_t *hashtable, char *key, Symbol *value ) ;
Symbol *ht_get( hashtable_t *hashtable, char *key, int find_fathers ) ;
void ht_print( hashtable_t *hashtable );