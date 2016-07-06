/*
|| This file is part of Pike. For copyright information see COPYRIGHT.
|| Pike is distributed under GPL, LGPL and MPL. See the file COPYING
|| for more information.
*/

#include "global.h"
#include "svalue.h"
#include "operators.h"
#include "bitvector.h"
#include "object.h"
#include "builtin_functions.h"
#include "bignum.h"

#define MACRO  ATTRIBUTE((unused)) static

/* ARM32 machine code backend
 *
 * naming conventions:
 *
 *  <op>_reg_reg(dst, a, b)
 *      execute a <op> b and store to dst
 *  <op>_reg_imm(dst, a, imm, rot)
 *      execute a <op> (ROT(imm, rot*2)) and store to dst
 *  arm32_<op>_reg_int(dst, a, v)
 *      execute a <op> v and store to dst
 *
 */

enum arm32_register {
    ARM_REG_R0,
    ARM_REG_R1,
    ARM_REG_R2,
    ARM_REG_R3,

    /* everything below is calee saved */
    ARM_REG_R4 = 4,
    ARM_REG_R5 = 5,
    ARM_REG_R6 = 6,
    ARM_REG_R7 = 7,
    ARM_REG_PIKE_LOCALS = 7,

    ARM_REG_R8 = 8,
    ARM_REG_PIKE_IP = 8,
    ARM_REG_R9 = 9,
    ARM_REG_PIKE_SP = 9,
    ARM_REG_R10 = 10,
    ARM_REG_PIKE_FP = 10,
    ARM_REG_R11,
    ARM_REG_FP = 11,
    ARM_REG_R12,
    ARM_REG_IP = 12,
    ARM_REG_R13,
    ARM_REG_SP = 13,
    ARM_REG_R14,
    ARM_REG_LR = 14,
    ARM_REG_R15,
    ARM_REG_PC = 15,
    ARM_REG_NONE = -1
};

unsigned INT32 RBIT(enum arm32_register reg) {
    return 1<<reg; 
}

enum arm32_condition {
    ARM_COND_EQ = 0,       /* equal */
    ARM_COND_Z  = 0,       /* zero */
    ARM_COND_NE = 1 << 28, /* not equal */
    ARM_COND_NZ = 1 << 28, /* not zero */
    ARM_COND_CS = 2 << 28,
    ARM_COND_CC = 3 << 28,
    ARM_COND_MI = 4 << 28,
    ARM_COND_PL = 5 << 28,
    ARM_COND_VS = 6 << 28, /* overflow */
    ARM_COND_VC = 7 << 28, /* no overflow */
    ARM_COND_HI = 8 << 28,
    ARM_COND_LS = 9 << 28,
    ARM_COND_GE = 10 << 28,
    ARM_COND_LT = 11 << 28,
    ARM_COND_GT = 12 << 28,
    ARM_COND_LE = 13 << 28,
    ARM_COND_AL = 14 << 28 /* unconditional */
};

enum arm32_addr_mode {
    ARM_ADDR_REGISTER,
    ARM_ADDR_IMMEDIATE = 1<<25,
    ARM_ADDR_LSL_IMM = 0,
    ARM_ADDR_LSL_REG = 1 << 3,
    ARM_ADDR_LSR_IMM = 1 << 4,
    ARM_ADDR_LSR_REG = 3 << 4,
    ARM_ADDR_ASR_IMM = 1 << 5,
    ARM_ADDR_ASR_REG = 5 << 5
};

enum data_proc_instr {
    ARM_PROC_AND,
    ARM_PROC_XOR,
    ARM_PROC_SUB,
    ARM_PROC_RSB,
    ARM_PROC_ADD,
    ARM_PROC_ADC,
    ARM_PROC_SBC,
    ARM_PROC_RSC,
    ARM_PROC_TST,
    ARM_PROC_TEQ,
    ARM_PROC_CMP,
    ARM_PROC_CMN,
    ARM_PROC_OR,
    ARM_PROC_MOV,
    ARM_PROC_BIC,
    ARM_PROC_MVN
};

#define OPCODE_FUN ATTRIBUTE((unused,warn_unused_result)) static PIKE_OPCODE_T


MACRO void arm32_flush_dirty_regs(void);
MACRO void arm32_call(void *ptr);
MACRO enum arm32_register ra_alloc_any(void);
MACRO void ra_free(enum arm32_register reg);

MACRO void break_my_arm(void) {
}

#ifdef ARM32_LOW_DEBUG
static unsigned INT32 stats[F_MAX_INSTR - F_OFFSET];

#define OPCODE0(X,Y,F) case X: return #X;
#define OPCODE1(X,Y,F) case X: return #X;
#define OPCODE2(X,Y,F) case X: return #X;
#define OPCODE0_TAIL(X,Y,F) case X: return #X;
#define OPCODE1_TAIL(X,Y,F) case X: return #X;
#define OPCODE2_TAIL(X,Y,F) case X: return #X;
#define OPCODE0_JUMP(X,Y,F) case X: return #X;
#define OPCODE1_JUMP(X,Y,F) case X: return #X;
#define OPCODE2_JUMP(X,Y,F) case X: return #X;
#define OPCODE0_TAILJUMP(X,Y,F) case X: return #X;
#define OPCODE1_TAILJUMP(X,Y,F) case X: return #X;
#define OPCODE2_TAILJUMP(X,Y,F) case X: return #X;
#define OPCODE0_PTRJUMP(X,Y,F) case X: return #X;
#define OPCODE1_PTRJUMP(X,Y,F) case X: return #X;
#define OPCODE2_PTRJUMP(X,Y,F) case X: return #X;
#define OPCODE0_TAILPTRJUMP(X,Y,F) case X: return #X;
#define OPCODE1_TAILPTRJUMP(X,Y,F) case X: return #X;
#define OPCODE2_TAILPTRJUMP(X,Y,F) case X: return #X;
#define OPCODE0_RETURN(X,Y,F) case X: return #X;
#define OPCODE1_RETURN(X,Y,F) case X: return #X;
#define OPCODE2_RETURN(X,Y,F) case X: return #X;
#define OPCODE0_TAILRETURN(X,Y,F) case X: return #X;
#define OPCODE1_TAILRETURN(X,Y,F) case X: return #X;
#define OPCODE2_TAILRETURN(X,Y,F) case X: return #X;
#define OPCODE0_BRANCH(X,Y,F) case X: return #X;
#define OPCODE1_BRANCH(X,Y,F) case X: return #X;
#define OPCODE2_BRANCH(X,Y,F) case X: return #X;
#define OPCODE0_TAILBRANCH(X,Y,F) case X: return #X;
#define OPCODE1_TAILBRANCH(X,Y,F) case X: return #X;
#define OPCODE2_TAILBRANCH(X,Y,F) case X: return #X;
#define OPCODE0_ALIAS(X,Y,F,A) case X: return #X;
#define OPCODE1_ALIAS(X,Y,F,A) case X: return #X;
#define OPCODE2_ALIAS(X,Y,F,A) case X: return #X;

const char* arm_get_opcode_name(PIKE_OPCODE_T code) {
    switch (code+F_OFFSET) {
#include "interpret_protos.h"
    default:
        return "<unknown>";
    }
}

#undef OPCODE0
#undef OPCODE1
#undef OPCODE2
#undef OPCODE0_TAIL
#undef OPCODE1_TAIL
#undef OPCODE2_TAIL
#undef OPCODE0_PTRJUMP
#undef OPCODE1_PTRJUMP
#undef OPCODE2_PTRJUMP
#undef OPCODE0_TAILPTRJUMP
#undef OPCODE1_TAILPTRJUMP
#undef OPCODE2_TAILPTRJUMP
#undef OPCODE0_RETURN
#undef OPCODE1_RETURN
#undef OPCODE2_RETURN
#undef OPCODE0_TAILRETURN
#undef OPCODE1_TAILRETURN
#undef OPCODE2_TAILRETURN
#undef OPCODE0_BRANCH
#undef OPCODE1_BRANCH
#undef OPCODE2_BRANCH
#undef OPCODE0_TAILBRANCH
#undef OPCODE1_TAILBRANCH
#undef OPCODE2_TAILBRANCH
#undef OPCODE0_JUMP
#undef OPCODE1_JUMP
#undef OPCODE2_JUMP
#undef OPCODE0_TAILJUMP
#undef OPCODE1_TAILJUMP
#undef OPCODE2_TAILJUMP
#undef OPCODE0_ALIAS
#undef OPCODE1_ALIAS
#undef OPCODE2_ALIAS

ATTRIBUTE((destructor))
MACRO void write_stats() {
    int i;
    FILE* file = fopen("/home/el/opcode.state", "a");

    for (i = 0; i < F_MAX_INSTR - F_OFFSET; i++) {
        if (!stats[i]) continue;

        fprintf(file, "%s\t%u\n", arm_get_opcode_name(i), stats[i]);
    }

    fclose(file);
}
#endif

MACRO void record_opcode(PIKE_OPCODE_T code) {
    code = code; /* prevent unused warning */
#ifdef ARM32_LOW_DEBUG
    stats[code - F_OFFSET] ++;
#endif
}

OPCODE_FUN set_status(unsigned INT32 instr) {
    return instr | (1<<19);
}

OPCODE_FUN set_cond(unsigned INT32 instr, enum arm32_condition cond) {
    return (instr&0x0fffffff)|cond;
}

OPCODE_FUN set_src1_reg(unsigned INT32 instr, enum arm32_register r) {
    return instr | (r << 16);
}

OPCODE_FUN set_dst_reg(unsigned INT32 instr, enum arm32_register r) {
    unsigned INT32 ret = instr | (r << 12);
    return ret;
}

OPCODE_FUN set_src_imm(unsigned INT32 instr, unsigned char imm, unsigned char rot) {
    return ARM_ADDR_IMMEDIATE | instr | imm | (rot << 8);
}

OPCODE_FUN set_src2_reg(unsigned INT32 instr, enum arm32_register r) {
    return instr | ARM_ADDR_REGISTER | r;
}


enum arm32_multiple_mode {
#define MODE(P, U, W)   (((P)<<24) | ((U)<<23) | ((W)<<21))
    ARM_MULT_DB  = MODE(1, 0, 0),
    ARM_MULT_DA  = MODE(0, 0, 0),
    ARM_MULT_IB  = MODE(1, 1, 0),
    ARM_MULT_IA  = MODE(0, 1, 0),
    ARM_MULT_DBW = MODE(1, 0, 1),
    ARM_MULT_DAW = MODE(0, 0, 1),
    ARM_MULT_IBW = MODE(1, 1, 1),
    ARM_MULT_IAW = MODE(0, 1, 1)
#undef MODE
};

OPCODE_FUN gen_store_multiple(enum arm32_register addr, enum arm32_multiple_mode mode,
                              unsigned INT32 registers) {
    unsigned INT32 instr = ARM_COND_AL | (1<<27) | registers | mode;

    instr |= addr << 16;
    
    return instr;
}

MACRO void store_multiple(enum arm32_register addr, enum arm32_multiple_mode mode,
                          unsigned INT32 registers) {
    add_to_program(gen_store_multiple(addr, mode, registers));
}

OPCODE_FUN gen_load_multiple(enum arm32_register addr, enum arm32_multiple_mode mode,
                             unsigned INT32 registers) {
    unsigned INT32 r = gen_store_multiple(addr, mode, registers) | (1<<20);

    return r;
}

MACRO void load_multiple(enum arm32_register addr, enum arm32_multiple_mode mode,
                         unsigned INT32 registers) {
    add_to_program(gen_load_multiple(addr, mode, registers));
}

OPCODE_FUN gen_mov_wide(enum arm32_register reg, unsigned short imm) {
    return ARM_COND_AL | (3 << 24) | (imm & 0xfff) | (reg << 12) | ((imm & 0xf000) << 4);
}

MACRO void mov_wide(enum arm32_register reg, unsigned short imm) {
    add_to_program(gen_mov_wide(reg, imm));
}

OPCODE_FUN gen_mov_top(enum arm32_register reg, unsigned short imm) {
    return gen_mov_wide(reg, imm) | (1<<22);
}

MACRO void mov_top(enum arm32_register reg, unsigned short imm) {
    add_to_program(gen_mov_top(reg, imm));
}

OPCODE_FUN gen_bx_reg(enum arm32_register to) {
    unsigned INT32 instr = ARM_COND_AL;
    int i;

    instr |= to;
    instr |= (1<<4);
    instr |= (1<<21)|(1<<24);

    for (i = 8; i < 20; i++) {
        instr |= (1<<i);
    }

    return instr;
}

MACRO void bx_reg(enum arm32_register to) {
    add_to_program(gen_bx_reg(to));
}

OPCODE_FUN gen_blx_reg(enum arm32_register to) {
    return gen_bx_reg(to) | (1<<5);
}

MACRO void blx_reg(enum arm32_register to) {
    add_to_program(gen_blx_reg(to));
}

OPCODE_FUN gen_b_imm(INT32 dist) {
    unsigned INT32 instr = ARM_COND_AL | (1<<27)|(1<<25);

    instr |= dist & 0xffffff;

    return instr;
}

MACRO void b_imm(INT32 dist, enum arm32_condition cond) {
    add_to_program(set_cond(gen_b_imm(dist), cond));
}

OPCODE_FUN gen_bl_imm(INT32 dist) {
    return gen_b_imm(dist) | (1<<24);
}

MACRO void bl_imm(INT32 dist) {
    add_to_program(gen_bl_imm(dist));
}

OPCODE_FUN gen_reg(enum data_proc_instr op, enum arm32_register dst, enum arm32_register src) {
    unsigned INT32 instr = ARM_ADDR_REGISTER | ARM_COND_AL;

    instr |= op << 21;
    instr = set_dst_reg(instr, dst);
    instr = set_src2_reg(instr, src);

    return instr;
}

OPCODE_FUN gen_reg_reg(enum data_proc_instr op, enum arm32_register dst,
                           enum arm32_register a, enum arm32_register b) {
    unsigned INT32 instr = gen_reg(op, dst, b);

    instr = set_src1_reg(instr, a);

    return instr;
}

OPCODE_FUN gen_cmp_reg_reg(enum arm32_register a, enum arm32_register b) {
    unsigned INT32 instr = gen_reg_reg(ARM_PROC_CMP, 0, a, b);

    instr |= (1<<20);

    return instr;
}

MACRO void cmp_reg_reg(enum arm32_register a, enum arm32_register b) {
    add_to_program(gen_cmp_reg_reg(a, b));
}

OPCODE_FUN gen_imm(enum data_proc_instr op, enum arm32_register dst,
                       unsigned char imm, unsigned char rot) {
    unsigned INT32 instr = ARM_ADDR_IMMEDIATE | ARM_COND_AL;

    instr |= op << 21;
    instr = set_dst_reg(instr, dst);
    instr = set_src_imm(instr, imm, rot);

    return instr;
}

#define ROTR(v, n)      (((v) >> (n)) | ((v) << (32-(n))))

/* returns 1 if v can be represented as a rotated imm, with imm and rot set */
MACRO int arm32_make_imm(unsigned INT32 v, unsigned char *imm, unsigned char *rot) {
    unsigned INT32 b, n;

    if (v <= 0xff) {
        *imm = v;
        *rot = 0;
        return 1;
    }

    b = ctz32(v) / 2;
    n = v >> (b*2);
    if (n <= 0xff) {
        *imm = n;
        *rot = 16 - b;
        return 1;
    }

    return 0;
}

MACRO void arm32_mov_int(enum arm32_register reg, unsigned INT32 v);

OPCODE_FUN gen_reg_imm(enum data_proc_instr op, enum arm32_register dst,
                       enum arm32_register reg, unsigned char imm, unsigned char rot) {
    unsigned INT32 instr = gen_imm(op, dst, imm, rot);

    instr = set_src1_reg(instr, reg);

    return instr;
}

OPCODE_FUN gen_cmp_reg_imm(enum arm32_register a, unsigned char imm, unsigned char rot) {
    unsigned INT32 instr = gen_reg_imm(ARM_PROC_CMP, 0, a, imm, rot);

    instr |= (1<<20);

    return instr;
}

MACRO void cmp_reg_imm(enum arm32_register a, unsigned char imm, unsigned char rot) {
    add_to_program(gen_cmp_reg_imm(a, imm, rot));
}


OPCODE_FUN gen_store_reg_imm(enum arm32_register dst, enum arm32_register base, INT32 offset) {
    unsigned INT32 instr = ARM_COND_AL;

    instr = set_dst_reg(instr, dst);
    instr = set_src1_reg(instr, base);
    instr |= (1 << 26) | (1<< 24);

    if (offset < 0) {
        instr |= -offset;
        assert(!((-offset) >> 12));
    } else {
        instr |= (1<<23);
        instr |= offset;
        assert(!(offset >> 12));
    }

    return instr;
}

MACRO void store_reg_imm(enum arm32_register dst, enum arm32_register base, INT32 offset) {
    add_to_program(gen_store_reg_imm(dst, base, offset));
}

OPCODE_FUN gen_load_reg_imm(enum arm32_register dst, enum arm32_register base, INT32 offset) {
    return gen_store_reg_imm(dst, base, offset) | (1<<20);
}

MACRO void load_reg_imm(enum arm32_register dst, enum arm32_register base, INT32 offset) {
    add_to_program(gen_load_reg_imm(dst, base, offset));
}

#define GEN_PROC_OP(name, NAME)                                                                          \
OPCODE_FUN gen_ ## name ## _reg_imm(enum arm32_register dst, enum arm32_register reg,                    \
                                    unsigned char imm, unsigned char rot) {                              \
    return gen_reg_imm(ARM_PROC_ ## NAME, dst, reg, imm, rot);                                           \
}                                                                                                        \
OPCODE_FUN gen_ ## name ## _reg_reg(enum arm32_register dst, enum arm32_register a,                      \
                                    enum arm32_register b) {                                             \
    return gen_reg_reg(ARM_PROC_ ## NAME, dst, a, b);                                                    \
}                                                                                                        \
OPCODE_FUN gen_ ## name ## s_reg_imm(enum arm32_register dst, enum arm32_register reg,                   \
                                     unsigned char imm, unsigned char rot) {                             \
    return gen_ ## name ## _reg_imm(dst, reg, imm, rot)|(1<<20);                                         \
}                                                                                                        \
OPCODE_FUN gen_ ## name ## s_reg_reg(enum arm32_register dst, enum arm32_register a,                     \
                                     enum arm32_register b) {                                            \
    return gen_ ## name ## _reg_reg(dst, a, b)|(1<<20);                                                  \
}                                                                                                        \
                                                                                                         \
MACRO void name ## _reg_imm(enum arm32_register dst, enum arm32_register reg, unsigned char imm,         \
                                      unsigned char rot) {                                               \
    add_to_program(gen_ ## name ## _reg_imm(dst, reg, imm, rot));                                        \
}                                                                                                        \
MACRO void name ## _reg_reg(enum arm32_register dst, enum arm32_register a, enum arm32_register b) {     \
    add_to_program(gen_ ## name ## _reg_reg(dst, a, b));                                                 \
}                                                                                                        \
MACRO void name ## s_reg_imm(enum arm32_register dst, enum arm32_register reg, unsigned char imm,        \
                                      unsigned char rot) {                                               \
    add_to_program(gen_ ## name ## s_reg_imm(dst, reg, imm, rot));                                       \
}                                                                                                        \
MACRO void name ## s_reg_reg(enum arm32_register dst, enum arm32_register a, enum arm32_register b) {    \
    add_to_program(gen_ ## name ## s_reg_reg(dst, a, b));                                                \
}                                                                                                        \
MACRO void arm32_ ## name ## _reg_int(enum arm32_register dst, enum arm32_register a, unsigned INT32 v) {\
    unsigned char imm, rot;                                                                              \
                                                                                                         \
    if (arm32_make_imm(v, &imm, &rot)) {                                                                 \
        name ## _reg_imm(dst, a, imm, rot);                                                              \
    } else {                                                                                             \
        enum arm32_register tmp = ra_alloc_any();                                                        \
        arm32_mov_int(tmp, v);                                                                           \
        name ## _reg_reg(dst, a, tmp);                                                                   \
        ra_free(tmp);                                                                                    \
    }                                                                                                    \
}                                                                                                        \
MACRO void arm32_ ## name ## s_reg_int(enum arm32_register dst, enum arm32_register a, unsigned INT32 v) {\
    unsigned char imm, rot;                                                                              \
                                                                                                         \
    if (arm32_make_imm(v, &imm, &rot)) {                                                                 \
        name ## s_reg_imm(dst, a, imm, rot);                                                             \
    } else {                                                                                             \
        enum arm32_register tmp = ra_alloc_any();                                                        \
        arm32_mov_int(tmp, v);                                                                           \
        name ## s_reg_reg(dst, a, tmp);                                                                  \
        ra_free(tmp);                                                                                    \
    }                                                                                                    \
}                                                                                                        \

GEN_PROC_OP(sub, SUB)
GEN_PROC_OP(add, ADD)
GEN_PROC_OP(or, OR)
GEN_PROC_OP(and, AND)


OPCODE_FUN gen_mov_reg(enum arm32_register dst, enum arm32_register src) {
    return gen_reg(ARM_PROC_MOV, dst, src);
}

MACRO void mov_reg(enum arm32_register dst, enum arm32_register src) {
    add_to_program(gen_mov_reg(dst, src));
}

OPCODE_FUN gen_mov_imm(enum arm32_register dst, unsigned char imm, unsigned char rot) {
    return gen_imm(ARM_PROC_MOV, dst, imm, rot);
}

MACRO void mov_imm(enum arm32_register dst, unsigned char imm, unsigned char rot) {
    add_to_program(gen_mov_imm(dst, imm, rot));
}

MACRO void arm32_mov_int(enum arm32_register reg, unsigned INT32 v) {
    unsigned char imm, rot;

    if (arm32_make_imm(v, &imm, &rot)) {
        mov_imm(reg, imm, rot);
    } else {
        mov_wide(reg, v);
        if (v>>16) mov_top(reg, v>>16);
    }
}

/*
 * TODO: work with labels
 */
MACRO void arm32_rel_cond_jmp(enum arm32_register reg, enum arm32_register b, enum arm32_condition cond, int jmp) {
    cmp_reg_reg(reg, b);
    b_imm(jmp-2, cond);
}


#define SIZEOF_ADD_SET_REG_AT   2
static void arm32_mov_int_at(unsigned INT32 offset, unsigned INT32 v,
                           enum arm32_register dst) {
    upd_pointer(offset++, gen_mov_wide(dst, v));
    upd_pointer(offset++, gen_mov_top(dst, v>>16));
}

/*
 * "High" level interface
 */

#define FLAG_SP_LOADED  1
#define FLAG_FP_LOADED  2
#define FLAG_LOCALS_LOADED 4

struct location_list_entry {
    unsigned INT32 location;
    struct location_list_entry *next;
};

struct compiler_state {
    /* currently unused and dirt registers */
    unsigned short free, dirt;
    /* address into which the initial stack push has to be
     * generated
     */
    unsigned INT32 push_addr;
    unsigned INT32 flags;
    struct location_list_entry *pop_list, *push_list;
} compiler_state;


static struct location_list_entry* add_to_list(struct location_list_entry *list, unsigned INT32 location) {
    struct location_list_entry *e = xalloc(sizeof(struct location_list_entry));

    e->location = location;
    e->next = list;

    return e;
}

static void add_to_pop_list(unsigned INT32 location) {
    compiler_state.pop_list = add_to_list(compiler_state.pop_list, location);
}

static void add_to_push_list(unsigned INT32 location) {
    compiler_state.push_list = add_to_list(compiler_state.push_list, location);
}

static void free_list(struct location_list_entry *list) {
    while (list) {
        struct location_list_entry * next = list->next;
        free(list);
        list = next;
    }
}

static void free_pop_list(void) {
    free_list(compiler_state.pop_list);
    compiler_state.pop_list = NULL;
}

static void free_push_list(void) {
    free_list(compiler_state.push_list);
    compiler_state.push_list = NULL;
}

struct label {
    struct location_list_entry *list;
    unsigned INT32 loc;
};

static void label_init(struct label *l) {
    l->list = NULL;
    l->loc = (unsigned INT32)-1;
}

MACRO INT32 label_dist(struct label *l) {
    if (l->loc != (unsigned INT32)-1)
        return l->loc - PIKE_PC - 2;
    l->list = add_to_list(l->list, PIKE_PC);
    return 0;
}

MACRO void label_generate(struct label *l) {
    unsigned INT32 loc = PIKE_PC;

    assert(l->loc == (unsigned INT32)-1);

    l->loc = loc;

    struct location_list_entry *e = l->list;

    while (e) {
        unsigned INT32 instr = read_pointer(e->location);
        if (instr & 0xffffff) {
            Pike_fatal("Setting label distance twice in %x\n", instr);
        }
        upd_pointer(e->location, instr|(loc - e->location - 2));
        e = e->next;
    }

    free_list(l->list);
}

MACRO void ra_init(void) {
    /* all register r0 through r10 are unused
     *
     */
    compiler_state.free = RBIT(0)|RBIT(1)|RBIT(2)|RBIT(3)|RBIT(4);
    compiler_state.dirt = 0;
    compiler_state.push_addr = -1;
    compiler_state.flags = 0;
    // FIXME: not quite the place
    instrs[F_CATCH - F_OFFSET].address = inter_return_opcode_F_CATCH;
    compiler_state.pop_list = NULL;
    compiler_state.push_list = NULL;
}

MACRO enum arm32_register ra_alloc(enum arm32_register reg) {
    unsigned INT32 rbit = RBIT(reg);

    if (!(rbit & compiler_state.free))
        Pike_fatal("Register %d is already in use.\n", reg);

    compiler_state.free ^= rbit;
    compiler_state.dirt |= rbit;

    return reg;
}

MACRO enum arm32_register ra_alloc_persistent(void) {
    unsigned short free = compiler_state.free;

    /* we dont want 0-3 */
    free &= 0xfff0;

    if (!free)
        Pike_fatal("No register left: %x\n", compiler_state.free);

    return ra_alloc(ctz32(free));
}

MACRO enum arm32_register ra_alloc_any(void) {
    if (!compiler_state.free)
        Pike_fatal("No register left.\n");

    return ra_alloc(ctz32(compiler_state.free));
}

MACRO void ra_free(enum arm32_register reg) {
    unsigned INT32 rbit = RBIT(reg);

    if (rbit & compiler_state.free)
        Pike_fatal("Register %d is not in use.\n", reg);

    compiler_state.free |= rbit;
}

MACRO int ra_is_dirty(enum arm32_register reg) {
    unsigned INT32 rbit = RBIT(reg);

    return !!(rbit & compiler_state.dirt);
}

MACRO int ra_is_free(enum arm32_register reg) {
    unsigned INT32 rbit = RBIT(reg);

    return !!(rbit & compiler_state.free);
}

MACRO void add_push(void) {
    unsigned INT32 registers;

    add_to_push_list(PIKE_PC);
    add_to_program(0);
}

MACRO void add_pop(void) {
    add_to_pop_list(PIKE_PC);
    add_to_program(0);
}

/* corresponds to ENTRY_PROLOGUE_SIZE */
MACRO void arm32_prologue(void) {
    add_push();
    mov_reg(ARM_REG_PIKE_IP, ARM_REG_R0);
}

#define EPILOGUE_SIZE 2
MACRO void arm32_epilogue(void) {
    add_pop();
    bx_reg(ARM_REG_LR);
}

MACRO void arm32_call(void *ptr) {
    unsigned INT32 v = (char*)ptr - (char*)NULL;
    enum arm32_register tmp = ra_alloc_any();

    arm32_mov_int(tmp, v);
    blx_reg(tmp);
    ra_free(tmp);
}


void arm32_flush_instruction_cache(void *addr, size_t len) {
    __builtin___clear_cache(addr, (char*)addr+len);
}

MACRO void arm32_low_load_sp_reg(void) {
    INT32 offset = OFFSETOF(Pike_interpreter_struct, stack_pointer);

    load_reg_imm(ARM_REG_PIKE_SP, ARM_REG_PIKE_IP, offset);
}

static void arm32_load_sp_reg(void) {
    if (!(compiler_state.flags & FLAG_SP_LOADED)) {

        compiler_state.flags |= FLAG_SP_LOADED;

        arm32_low_load_sp_reg();
    }
}

static void arm32_store_sp_reg(void) {
    INT32 offset = OFFSETOF(Pike_interpreter_struct, stack_pointer);
    assert(compiler_state.flags & FLAG_SP_LOADED);
    store_reg_imm(ARM_REG_PIKE_SP, ARM_REG_PIKE_IP, offset);
}

static void arm32_load_fp_reg(void) {
    if (!(compiler_state.flags & FLAG_FP_LOADED)) {
        INT32 offset = OFFSETOF(Pike_interpreter_struct, frame_pointer);
        /* load Pike_interpreter_pointer->frame_pointer into ARM_REG_PIKE_FP */
        load_reg_imm(ARM_REG_PIKE_FP, ARM_REG_PIKE_IP, offset);
        compiler_state.flags |= FLAG_FP_LOADED;
        compiler_state.flags &= ~FLAG_LOCALS_LOADED;
    }
}

MACRO void arm32_load_locals_reg(void) {
    arm32_load_fp_reg();

    if (!(compiler_state.flags & FLAG_LOCALS_LOADED)) {
        INT32 offset = OFFSETOF(pike_frame, locals);

        load_reg_imm(ARM_REG_PIKE_LOCALS, ARM_REG_PIKE_FP, offset);

        compiler_state.flags |= FLAG_LOCALS_LOADED;
    }
}

MACRO void arm32_change_sp_reg(INT32 offset) {
    assert(compiler_state.flags & FLAG_SP_LOADED);
    offset *= sizeof(struct svalue);
    if (offset < 0) {
        offset = -offset;
        arm32_sub_reg_int(ARM_REG_PIKE_SP, ARM_REG_PIKE_SP, offset);
    } else {
        arm32_add_reg_int(ARM_REG_PIKE_SP, ARM_REG_PIKE_SP, offset);
    }
}

MACRO void arm32_change_sp(INT32 offset) {
    arm32_load_sp_reg();
    arm32_change_sp_reg(offset);
    arm32_store_sp_reg();
}

static void arm32_flush_dirty_regs(void) {
    arm32_store_sp_reg();
}

MACRO void arm32_call_efun(void (*fun)(int), int args) {
    arm32_mov_int(ra_alloc(ARM_REG_R0), args);
    arm32_call(fun);
    ra_free(ARM_REG_R0);
    if (args != 1 && compiler_state.flags & FLAG_SP_LOADED) {
        arm32_change_sp_reg(-(args-1));
    }
}

MACRO void arm32_push_int(unsigned INT32 value, int subtype) {
    unsigned INT32 combined = TYPE_SUBTYPE(PIKE_T_INT, subtype);
    enum arm32_register tmp1 = ra_alloc_any(), tmp2 = ra_alloc_any();

    assert(tmp1 < tmp2);

    arm32_load_sp_reg();

    arm32_mov_int(tmp1, combined);
    arm32_mov_int(tmp2, value);

    store_multiple(ARM_REG_PIKE_SP, ARM_MULT_IAW, RBIT(tmp1)|RBIT(tmp2));

    ra_free(tmp1);
    ra_free(tmp2);

    arm32_store_sp_reg();
}

MACRO void arm32_push_ptr_type(enum arm32_register treg, enum arm32_register vreg) {
    assert(treg < vreg);

    arm32_load_sp_reg();
    store_multiple(ARM_REG_PIKE_SP, ARM_MULT_IAW, RBIT(treg)|RBIT(vreg));
    arm32_store_sp_reg();

    /* add reference */
    load_reg_imm(treg, vreg, 0);
    arm32_add_reg_int(treg, treg, 1);
    store_reg_imm(treg, vreg, 0);
}

MACRO void arm32_move_svaluep_nofree(enum arm32_register dst, enum arm32_register from) {
    enum arm32_register treg = ra_alloc_any(),
                        vreg = ra_alloc_any();

    assert(treg < vreg);

    load_multiple(from, ARM_MULT_IA, RBIT(treg)|RBIT(vreg));
    store_multiple(dst, ARM_MULT_IA, RBIT(treg)|RBIT(vreg));

    ra_free(treg);
    ra_free(vreg);
}

MACRO void arm32_assign_svaluep_nofree(enum arm32_register dst, enum arm32_register from) {
    enum arm32_register treg = ra_alloc_any(),
                        vreg = ra_alloc_any();

    assert(treg < vreg);

    load_multiple(from, ARM_MULT_IA, RBIT(treg)|RBIT(vreg));
    store_multiple(dst, ARM_MULT_IA, RBIT(treg)|RBIT(vreg));

    arm32_ands_reg_int(treg, treg, TYPE_SUBTYPE(MIN_REF_TYPE, 0));

    add_to_program(set_cond(gen_load_reg_imm(treg, vreg, OFFSETOF(pike_string, refs)), ARM_COND_NZ));
    add_to_program(set_cond(gen_add_reg_imm(treg, treg, 1, 0), ARM_COND_NZ));
    add_to_program(set_cond(gen_store_reg_imm(treg, vreg, OFFSETOF(pike_string, refs)), ARM_COND_NZ));

    ra_free(treg);
    ra_free(vreg);
}

MACRO void arm32_push_svaluep_off(enum arm32_register src, INT32 offset) {
    enum arm32_register tmp1 = ra_alloc_any(),
                        tmp2 = ra_alloc_any();

    assert(tmp1 < tmp2);
    assert(sizeof(struct svalue) == 8);

    if (offset) {
        arm32_add_reg_int(tmp1, src, offset*sizeof(struct svalue));

        load_multiple(tmp1, ARM_MULT_IA, RBIT(tmp1)|RBIT(tmp2));
    } else {
        load_multiple(src, ARM_MULT_IA, RBIT(tmp1)|RBIT(tmp2));
    }

    arm32_load_sp_reg();

    store_multiple(ARM_REG_PIKE_SP, ARM_MULT_IAW, RBIT(tmp1)|RBIT(tmp2));

    arm32_store_sp_reg();

    arm32_ands_reg_int(tmp1, tmp1, TYPE_SUBTYPE(MIN_REF_TYPE, 0));

    add_to_program(set_cond(gen_load_reg_imm(tmp1, tmp2, OFFSETOF(pike_string, refs)), ARM_COND_NZ));
    add_to_program(set_cond(gen_add_reg_imm(tmp1, tmp1, 1, 0), ARM_COND_NZ));
    add_to_program(set_cond(gen_store_reg_imm(tmp1, tmp2, OFFSETOF(pike_string, refs)), ARM_COND_NZ));

    ra_free(tmp1);
    ra_free(tmp2);
}

void arm32_flush_codegen_state(void) {
    //fprintf(stderr, "flushing codegen state.\n");
    compiler_state.flags = 0;
}

void arm32_start_function(int UNUSED(no_pc)) {
    ra_init();
}

void arm32_end_function(int UNUSED(no_pc)) {
    unsigned INT32 registers, instr;
    struct location_list_entry *e;

    /* NOTE: number of registers always needs to be even */
    registers = RBIT(ARM_REG_PIKE_SP)
                |RBIT(ARM_REG_PIKE_IP)
                |RBIT(ARM_REG_PIKE_FP)
                |RBIT(ARM_REG_PIKE_LOCALS)
                |RBIT(ARM_REG_LR)
                |RBIT(4);

    e = compiler_state.pop_list;

    instr = gen_load_multiple(ARM_REG_SP, ARM_MULT_IAW, registers);
    while (e) {
        upd_pointer(e->location, instr);
        e = e->next;
    }

    e = compiler_state.push_list;

    instr = gen_store_multiple(ARM_REG_SP, ARM_MULT_DBW, registers);

    while (e) {
        upd_pointer(e->location, instr);
        e = e->next;
    }

    free_pop_list();
    free_push_list();
}

/* Store $pc into Pike_fp->pc */
void arm32_update_pc(void) {
    unsigned INT32 v = PIKE_PC;
    INT32 offset;
    enum arm32_register tmp = ra_alloc_any();

    arm32_load_fp_reg();
    v = 4*(PIKE_PC - v + 2);
    arm32_sub_reg_int(tmp, ARM_REG_PC, v);
    store_reg_imm(tmp, ARM_REG_PIKE_FP, OFFSETOF(pike_frame, pc));
    ra_free(tmp);
}

void arm32_ins_entry(void) {
    arm32_prologue();
    arm32_flush_codegen_state();
}

static void arm32_ins_maybe_exit(void) {
    arm32_mov_int(ARM_REG_R1, -1);
    arm32_rel_cond_jmp(ARM_REG_R0, ARM_REG_R1, ARM_COND_NE, EPILOGUE_SIZE+1);
    arm32_epilogue();
}

MACRO void arm32_maybe_update_pc() {
  {
    static int last_prog_id=-1;
    static size_t last_num_linenumbers=(size_t)~0;
    if(last_prog_id != Pike_compiler->new_program->id ||
       last_num_linenumbers != Pike_compiler->new_program->num_linenumbers)
    {
      unsigned INT32 tmp = PIKE_PC;
      last_prog_id=Pike_compiler->new_program->id;
      last_num_linenumbers = Pike_compiler->new_program->num_linenumbers;

      UPDATE_PC();
    }
  }
}

static void low_ins_call(void *addr) {
  arm32_maybe_update_pc();
  arm32_call(addr);
}

static void arm32_call_c_function(void * addr) {
    compiler_state.flags &= ~FLAG_SP_LOADED;
    compiler_state.flags &= ~FLAG_FP_LOADED;
    arm32_call(addr);
}

static void arm32_call_c_opcode(unsigned int opcode) {
  void *addr = instrs[opcode-F_OFFSET].address;
  int flags = instrs[opcode-F_OFFSET].flags;

  if (flags & I_UPDATE_SP) {
    compiler_state.flags &= ~FLAG_SP_LOADED;
  }
  if (flags & I_UPDATE_M_SP) {}
  if (flags & I_UPDATE_FP) {
    compiler_state.flags &= ~FLAG_FP_LOADED;
  }

  low_ins_call(addr);
}

MACRO void arm32_free_svalue_off(enum arm32_register src, int off, int guaranteed) {
    unsigned INT32 combined = TYPE_SUBTYPE(MIN_REF_TYPE, 0);
    unsigned char imm, rot;
    struct label end;
    enum arm32_register reg = ra_alloc(ARM_REG_R0);
    enum arm32_register tmp = ra_alloc_any();

    guaranteed = guaranteed;

    off *= sizeof(struct svalue);

    label_init(&end);

    load_reg_imm(reg, src, off);

    arm32_ands_reg_int(reg, reg, combined);

    b_imm(label_dist(&end), ARM_COND_Z);

    load_reg_imm(tmp, src, off+OFFSETOF(svalue, u));

    load_reg_imm(reg, tmp, OFFSETOF(pike_string, refs));
    subs_reg_imm(reg, reg, 1, 0);
    store_reg_imm(reg, tmp, OFFSETOF(pike_string, refs));

    b_imm(label_dist(&end), ARM_COND_NZ);

    if (off > 0) {
        add_reg_imm(reg, src, off, 0);
    } else if (off < 0 ) {
        sub_reg_imm(reg, src, -off, 0);
    } else {
        mov_reg(reg, src);
    }

    arm32_call_c_function(really_free_svalue);

    label_generate(&end);
    ra_free(reg);
    ra_free(tmp);
}


static void arm32_free_svalue(enum arm32_register reg, int guaranteed_ref) {
    arm32_free_svalue_off(reg, 0, guaranteed_ref);
}

static void arm32_mark(enum arm32_register base, int offset) {

  enum arm32_register tmp = ra_alloc_any();

  load_reg_imm(tmp, ARM_REG_PIKE_IP, OFFSETOF(Pike_interpreter_struct, mark_stack_pointer));

  if (offset) {
    enum arm32_register tmp2 = ra_alloc_any();

    offset *= sizeof(struct svalue);

    if (offset > 0) {
      arm32_add_reg_int(tmp2, base, offset);
    } else {
      arm32_sub_reg_int(tmp2, base, -offset);
    }
    store_reg_imm(tmp2, tmp, 0);

    ra_free(tmp2);
  } else {
    store_reg_imm(base, tmp, 0);
  }

  add_reg_imm(tmp, tmp, sizeof(void*), 0);
  store_reg_imm(tmp, ARM_REG_PIKE_IP, OFFSETOF(Pike_interpreter_struct, mark_stack_pointer));

  ra_free(tmp);
}

#ifdef PIKE_DEBUG
MACRO void arm_green_on(void) {
    if (Pike_interpreter.trace_level > 2)
        fprintf(stderr, "\33[032m");
}

MACRO void arm_green_off(void) {
    if (Pike_interpreter.trace_level > 2)
        fprintf(stderr, "\33[0m");
}

MACRO void arm32_debug_instr_prologue_0(PIKE_INSTR_T instr) {
  arm32_call(arm_green_on);
  arm32_maybe_update_pc();
  arm32_mov_int(ra_alloc(ARM_REG_R0), instr-F_OFFSET);
  arm32_call(simple_debug_instr_prologue_0);
  arm32_call(arm_green_off);
  ra_free(ARM_REG_R0);
}

MACRO void arm32_debug_instr_prologue_1(PIKE_INSTR_T instr, INT32 arg1) {
  arm32_call(arm_green_on);
  arm32_maybe_update_pc();
  arm32_mov_int(ra_alloc(ARM_REG_R0), instr-F_OFFSET);
  arm32_mov_int(ra_alloc(ARM_REG_R1), arg1);
  arm32_call(simple_debug_instr_prologue_1);
  arm32_call(arm_green_off);
  ra_free(ARM_REG_R0);
  ra_free(ARM_REG_R1);
}

MACRO void arm32_debug_instr_prologue_2(PIKE_INSTR_T instr, INT32 arg1, INT32 arg2) {
  arm32_call(arm_green_on);
  arm32_maybe_update_pc();
  arm32_mov_int(ra_alloc(ARM_REG_R0), instr-F_OFFSET);
  arm32_mov_int(ra_alloc(ARM_REG_R1), arg1);
  arm32_mov_int(ra_alloc(ARM_REG_R2), arg2);
  arm32_call(simple_debug_instr_prologue_2);
  arm32_call(arm_green_off);
  ra_free(ARM_REG_R0);
  ra_free(ARM_REG_R1);
  ra_free(ARM_REG_R2);
}
#else
#define arm32_debug_instr_prologue_1(a, b)  do {} while(0)
#define arm32_debug_instr_prologue_2(a, b, c)  do {} while(0)
#define arm32_debug_instr_prologue_0(a) do { } while(0)
#endif

static void low_ins_f_byte(PIKE_OPCODE_T opcode)
{
  int flags;
  INT32 rel_addr = rel_addr;

  record_opcode(opcode);

#ifdef PIKE_DEBUG
  assert(opcode-F_OFFSET<=255);
#endif

  flags = instrs[opcode-F_OFFSET].flags;

  switch (opcode) {
  case F_UNDEFINED:
      arm32_debug_instr_prologue_0(opcode);
      arm32_push_int(0, NUMBER_UNDEFINED);
      return;
  case F_CONST_1:
      arm32_debug_instr_prologue_0(opcode);
      arm32_push_int(-1, NUMBER_NUMBER);
      return;
  case F_CONST1:
      arm32_debug_instr_prologue_0(opcode);
      arm32_push_int(1, NUMBER_NUMBER);
      return;
  case F_CONST0:
      arm32_debug_instr_prologue_0(opcode);
      arm32_push_int(0, NUMBER_NUMBER);
      return;
  case F_CATCH:
      {
          int i;
          mov_reg(ra_alloc(ARM_REG_R0), ARM_REG_PC);

          rel_addr = PIKE_PC;
          /* we will move an offset into R8 */
          for (i = 0; i < SIZEOF_ADD_SET_REG_AT; i++)
            add_to_program(0);

          add_reg_reg(ARM_REG_R0, ARM_REG_R0, ARM_REG_R2);
      }
      break;
  case F_POP_VALUE:
      arm32_change_sp(-1);
      arm32_free_svalue(ARM_REG_PIKE_SP, 0);
      return;
  case F_MARK:
      arm32_load_sp_reg();
      arm32_mark(ARM_REG_PIKE_SP, 0);
      return;
  case F_MARK2:
      ins_f_byte(F_MARK);
      ins_f_byte(F_MARK);
      return;
  case F_MARK_AND_CONST0:
      ins_f_byte(F_MARK);
      ins_f_byte(F_CONST0);
      return;
  case F_MARK_AND_CONST1:
      ins_f_byte(F_MARK);
      ins_f_byte(F_CONST1);
      return;
  case F_MAKE_ITERATOR:
      arm32_debug_instr_prologue_0(opcode);
      arm32_call_efun(f_get_iterator, 1);
      return;
  case F_ADD:
      arm32_debug_instr_prologue_0(opcode);
      arm32_call_efun(f_add, 2);
      return;
  }

  arm32_call_c_opcode(opcode);


  if (opcode == F_CATCH) ra_free(ARM_REG_R0);

  if (flags & I_RETURN) {
      enum arm32_register kludge_reg = ARM_REG_NONE;

      if (opcode == F_RETURN_IF_TRUE) {
          kludge_reg = ra_alloc_persistent();
          /* -4 == 4*(JUMP_EPILOGUE_SIZE - 2) */
          sub_reg_imm(kludge_reg, ARM_REG_PC, 4, 0);
      }
    
      arm32_ins_maybe_exit();

      if (opcode == F_RETURN_IF_TRUE) {
          arm32_rel_cond_jmp(ARM_REG_R0, kludge_reg, ARM_COND_EQ, 2);
          bx_reg(ARM_REG_R0);
          ra_free(kludge_reg);
          return;
      }
  }
  if (flags & I_JUMP) {
    /* This is the code that JUMP_EPILOGUE_SIZE compensates for. */
    bx_reg(ARM_REG_R0);

    compiler_state.flags &= ~FLAG_FP_LOADED;

    if (opcode == F_CATCH) {
        arm32_mov_int_at(rel_addr, 4*(PIKE_PC - rel_addr - 1), ARM_REG_R2);
    }
  }
}

void ins_f_byte(unsigned int opcode)
{
  low_ins_f_byte(opcode);
}

void ins_f_byte_with_arg(PIKE_OPCODE_T opcode, INT32 arg1)
{
  struct label done;
  label_init(&done);

  record_opcode(opcode);

  switch (opcode) {
  case F_NUMBER:
      arm32_debug_instr_prologue_1(opcode, arg1);
      arm32_push_int(arg1, NUMBER_NUMBER);
      return;
  case F_NEG_NUMBER:
      if (!INT32_NEG_OVERFLOW(arg1)) {
        arm32_debug_instr_prologue_1(opcode, arg1);
        arm32_push_int(-arg1, 0);
        return;
      }
      break;
  case F_SUBTRACT_INT:
    {
      struct label fallback;
      enum arm32_register tmp;
      arm32_debug_instr_prologue_1(opcode, arg1);

      tmp = ra_alloc_any();
      label_init(&fallback);
      arm32_load_sp_reg();
      load_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+0);
      cmp_reg_imm(tmp, 0, 0);
      b_imm(label_dist(&fallback), ARM_COND_NE);
      load_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+4);
      arm32_subs_reg_int(tmp, tmp, arg1);
      b_imm(label_dist(&fallback), ARM_COND_VS);
      store_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+4);
      ra_free(tmp);
      b_imm(label_dist(&done), ARM_COND_AL);
      label_generate(&fallback);
      break;
    }
  case F_ADD_INT:
    {
      struct label fallback;
      unsigned char imm, rot;
      enum arm32_register tmp;
      arm32_debug_instr_prologue_1(opcode, arg1);

      tmp = ra_alloc_any();
      label_init(&fallback);
      arm32_load_sp_reg();
      load_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+0);
      cmp_reg_imm(tmp, 0, 0);
      b_imm(label_dist(&fallback), ARM_COND_NE);
      load_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+4);
      arm32_adds_reg_int(tmp, tmp, arg1);
      b_imm(label_dist(&fallback), ARM_COND_VS);
      store_reg_imm(tmp, ARM_REG_PIKE_SP, -sizeof(struct svalue)+4);
      ra_free(tmp);
      b_imm(label_dist(&done), ARM_COND_AL);
      label_generate(&fallback);
      break;
    }
  case F_MARK_AND_CONST0:
      ins_f_byte(F_MARK);
      ins_f_byte(F_CONST0);
      return;
  case F_MARK_AND_CONST1:
      ins_f_byte(F_MARK);
      ins_f_byte(F_CONST1);
      return;
  case F_MARK_AND_STRING:
      ins_f_byte(F_MARK);
      ins_f_byte_with_arg(F_STRING, arg1);
      return;
  case F_MARK_AND_GLOBAL:
      ins_f_byte(F_MARK);
      ins_f_byte_with_arg(F_GLOBAL, arg1);
      return;
  case F_MARK_AND_LOCAL:
      ins_f_byte(F_MARK);
      ins_f_byte_with_arg(F_LOCAL, arg1);
      return;
  case F_LOCAL:
      arm32_debug_instr_prologue_1(opcode, arg1);
      arm32_load_locals_reg();
      arm32_push_svaluep_off(ARM_REG_PIKE_LOCALS, arg1);
      return;
  case F_MARK_AT:
      arm32_debug_instr_prologue_1(opcode, arg1);
      arm32_load_locals_reg();
      arm32_mark(ARM_REG_PIKE_LOCALS, arg1);
      return;
  case F_STRING:
      {
          enum arm32_register treg = ra_alloc_any(),
                              vreg = ra_alloc_any();

          arm32_load_fp_reg();

          load_reg_imm(vreg, ARM_REG_PIKE_FP, OFFSETOF(pike_frame, context));
          load_reg_imm(vreg, vreg, OFFSETOF(inherit, prog));
          load_reg_imm(vreg, vreg, OFFSETOF(program, strings));
          load_reg_imm(vreg, vreg, arg1*sizeof(struct pike_string*));

          arm32_mov_int(treg, TYPE_SUBTYPE(PIKE_T_STRING, 0));

          arm32_push_ptr_type(treg, vreg);

          ra_free(treg);
          ra_free(vreg);
          return;
      }
  case F_ASSIGN_LOCAL_AND_POP:
      {
          enum arm32_register tmp;
          arm32_debug_instr_prologue_1(opcode, arg1);
          arm32_load_locals_reg();

          tmp = ra_alloc_persistent();
          arm32_add_reg_int(tmp, ARM_REG_PIKE_LOCALS, arg1 * sizeof(struct svalue));

          arm32_free_svalue_off(tmp, 0, 0);

          arm32_load_sp_reg();
          arm32_sub_reg_int(ARM_REG_PIKE_SP, ARM_REG_PIKE_SP, sizeof(struct svalue));
          arm32_store_sp_reg();
          arm32_move_svaluep_nofree(tmp, ARM_REG_PIKE_SP);

          ra_free(tmp);
          return;
      }
  case F_PROTECT_STACK:
      {
          arm32_load_fp_reg();
          arm32_load_locals_reg();

          if (arg1) {
              enum arm32_register reg = ra_alloc_any();

              arm32_add_reg_int(reg, ARM_REG_PIKE_LOCALS, arg1);
              store_reg_imm(reg, ARM_REG_PIKE_FP, OFFSETOF(pike_frame, expendible));

              ra_free(reg);
          } else {
              store_reg_imm(ARM_REG_PIKE_LOCALS, ARM_REG_PIKE_FP, OFFSETOF(pike_frame, expendible));
          }
          return;
      }
  }
  arm32_mov_int(ra_alloc(ARM_REG_R0), arg1);
  low_ins_f_byte(opcode);
  ra_free(ARM_REG_R0);
  label_generate(&done);
  return;
}

void ins_f_byte_with_2_args(PIKE_OPCODE_T opcode, INT32 arg1, INT32 arg2)
{
  record_opcode(opcode);
  switch (opcode) {
  case F_MARK_AND_EXTERNAL:
      ins_f_byte(F_MARK);
      ins_f_byte_with_2_args(F_EXTERNAL, arg1, arg2);
      return;
  case F_INIT_FRAME: {
          enum arm32_register tmp;
          arm32_debug_instr_prologue_2(opcode, arg1, arg2);
          arm32_load_fp_reg();

          tmp = ra_alloc_any();
          arm32_mov_int(tmp, arg2|(arg1<<16));

          assert(OFFSETOF(pike_frame, num_locals) % 4 == 0);
          assert(OFFSETOF(pike_frame, num_locals) + 2 == OFFSETOF(pike_frame, num_args));

          store_reg_imm(tmp, ARM_REG_PIKE_FP, OFFSETOF(pike_frame, num_locals));
          ra_free(tmp);
          return;
      }
  case F_FILL_STACK:
      {
          enum arm32_register reg, treg, vreg;
          struct label skip, loop;
          label_init(&skip);
          label_init(&loop);

          arm32_load_sp_reg();
          arm32_load_locals_reg();

          reg = ra_alloc_any();
          treg = ra_alloc_any();
          vreg = ra_alloc_any();

          assert(treg < vreg);

          arm32_add_reg_int(reg, ARM_REG_PIKE_LOCALS, arg1*sizeof(struct svalue));

          cmp_reg_reg(ARM_REG_PIKE_SP, reg);
          b_imm(label_dist(&skip), ARM_COND_GE);
          arm32_mov_int(treg, TYPE_SUBTYPE(PIKE_T_INT, arg2 ? NUMBER_UNDEFINED : NUMBER_NUMBER));
          arm32_mov_int(vreg, 0);

          label_generate(&loop);
          store_multiple(ARM_REG_PIKE_SP, ARM_MULT_IAW, RBIT(treg)|RBIT(vreg));
          cmp_reg_reg(ARM_REG_PIKE_SP, reg);
          b_imm(label_dist(&loop), ARM_COND_LT);

          arm32_store_sp_reg();
          label_generate(&skip);

          ra_free(reg);
          ra_free(treg);
          ra_free(vreg);

          return;
      }
  case F_2_LOCALS:
      ins_f_byte_with_arg(F_LOCAL, arg1);
      ins_f_byte_with_arg(F_LOCAL, arg2);
      return;
  }
  arm32_mov_int(ra_alloc(ARM_REG_R0), arg1);
  arm32_mov_int(ra_alloc(ARM_REG_R1), arg2);
  low_ins_f_byte(opcode);
  ra_free(ARM_REG_R0);
  ra_free(ARM_REG_R1);
  return;
}
