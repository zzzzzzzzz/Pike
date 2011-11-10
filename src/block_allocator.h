#include <stdint.h>

typedef struct ba_page * ba_page;

struct block_allocator {
    uint32_t block_size;
    uint32_t blocks;
    uint16_t num_pages;
    uint16_t free; 
    uint16_t magnitude;
    uint16_t allocated;
    void * pages;
    uint16_t * htable;
};

void ba_init(struct block_allocator * a, uint32_t block_size, uint32_t blocks);
void * ba_alloc(struct block_allocator * a);
void ba_free(struct block_allocator * a, void * ptr);
