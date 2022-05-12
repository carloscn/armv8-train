#include "io.h"
#include "type.h"

#define ICACHE_POLICY_VPIPT 0
#define ICACHE_POLICY_VIPT 2
#define ICACHE_POLICY_PIPT 3

static const char *icache_policy_str[] = {
    [0 ... ICACHE_POLICY_PIPT] = "RESERVED/UNKNOWN",
    [ICACHE_POLICY_VIPT] = "VIPT",
    [ICACHE_POLICY_PIPT] = "PIPT",
    [ICACHE_POLICY_VPIPT] = "VPIPT"
};

/*
 * CTR_EL0, Cache Type Register
 * https://developer.arm.com/documentation/ddi0601/2022-03/
 * AArch64-Registers/CTR-EL0--Cache-Type-Register?lang=en
 *
 * -    IminLine, bits [3:0]:
 *      Log2 of the number of words in the smallest cache line of
 *      all the instruction caches that are controlled by the PE.
 *
 * -    L1Ip, bits [15:14]:
 *      Level 1 instruction cache policy. Indicates the indexing and
 *      tagging policy for the L1 instruction cache. Possible values
 *      of this field are:
 *      -   00: VMID aware Physical Index, Physical tag (VPIPT).
 *      -   01: ASID-tagged Virtual Index, Virtual Tag (AIVIVT).
 *              (ARMv8 only)
 *      -   10: Virtual Index, Physical Tag (VIPT).
 *      -   11: Physical Index, Physical Tag (PIPT).
 *
 * -    DminLine, bits [19:16]:
 *      Log2 of the number of words in the smallest cache line of
 *      all the data caches and unified caches that are controlled
 *      by the PE.
 *
 * -    ERG, bits [23:20]
 *      Exclusives reservation granule, and, if FEAT_TME is implemented,
 *      transactional reservation granule. Log2 of the number of words of
 *      the maximum size of the reservation granule for the Load-Exclusive
 *      and Store-Exclusive instructions, and, if FEAT_TME is implemented,
 *      for detecting transactional conflicts.
 *
 * -    CWG, bits [27:24]
 *      Cache writeback granule. Log2 of the number of words of the
 *      maximum size of memory that can be overwritten as a result of
 *      the eviction of a cache entry that has had a memory location
 *      in it modified.
 *      -   A value of 0b0000 indicates that this register does not provide
 *          Cache writeback granule information and either:
 *          -   The architectural maximum of 512 words (2KB) must be assumed.3
 *          -   The Cache writeback granule can be determined from maximum
 *              cache line size encoded in the Cache Size ID Registers.
 *      -   Values greater than 0b1001 are reserved.
 *
 * -    IDC, bit [28]
 *      Data cache clean requirements for instruction to data coherence.
 *      The meaning of this bit is:
 *      -   0:  Data cache clean to the Point of Unification is required
 *              for instruction to data coherence,
 *              unless CLIDR_EL1.LoC == 0b000 or
 *              (CLIDR_EL1.LoUIS == 0b000 && CLIDR_EL1.LoUU == 0b000).
 *      -   1:  Data cache clean to the Point of Unification is not
 *              required for instruction to data coherence.
 *
 * -    DIC, bit [29]
 *      Instruction cache invalidation requirements for data to
 *      instruction coherence.
 *      -   0: Data cache clean to the Point of Unification is
 *             required for instruction to data coherence,
 *             unless CLIDR_EL1.LoC == 0b000 or
 *             (CLIDR_EL1.LoUIS == 0b000 && CLIDR_EL1.LoUU == 0b000).
 *      -   1: Data cache clean to the Point of Unification is not
 *             required for instruction to data coherence.
 *
 * -    TminLine, bits [37:32]
 *      Tag minimum Line. Log2 of the number of words covered by
 *      Allocation Tags in the smallest cache line of all caches
 *      which can contain Allocation tags that are controlled by
 *      the PE.
 *      -   For an implementation with cache lines containing 64
 *          bytes of data and 4 Allocation Tags, this will be
 *          log2(64/4) = 4.
 *      -   For an implementation with Allocations Tags in separate
 *          cache lines of 128 Allocation Tags per line, this will
 *          be log2(128*16/4) = 9.
 */
#define CTR_L1IP_SHIFT 14
#define CTR_L1IP_MASK 3
#define CTR_DMINLINE_SHIFT 16
#define CTR_IMINLINE_SHIFT 0
#define CTR_ERG_SHIFT 20
#define CTR_CWG_SHIFT 24
#define CTR_CWG_MASK 15
#define CTR_IDC_SHIFT 28
#define CTR_DIC_SHIFT 29
#define CTR_L1IP(ctr)		(((ctr) >> CTR_L1IP_SHIFT) & CTR_L1IP_MASK)

/*
 * CSSELR_EL1, Cache Size Selection Register
 *
 * Selects the current Cache Size ID Register, CCSIDR_EL1,
 * by specifying the required cache level and the cache type
 * (either instruction or data cache).
 *
 * https://developer.arm.com/documentation/ddi0601/2022-03/
 * AArch64-Registers/CCSIDR-EL1--Current-Cache-Size-ID-Register?lang=en
 *
 * -    TnD, bit [4]
 *      -   0: Data, Instruction or Unified cache.
 *      -   1: Separate Allocation Tag cache.
 *
 * -    Associativity, bits [12:3]
 *      (Associativity of cache) - 1, therefore a value of
 *      0 indicates an associativity of 1. The associativity
 *      does not have to be a power of 2.
 *
 * -    Level, bits [3:1]
 *      Cache level of required cache.
 *      -   0b000 : Level 1 cache.
 *      -   0b001 : Level 2 cache.
 *      -   0b010 : Level 3 cache.
 *      -   0b011 : Level 4 cache.
 *      -   0b100 : Level 5 cache.
 *      -   0b101 : Level 6 cache.
 *      -   0b110 : Level 7 cache.
 * -    InD, bit [0]
 *      Instruction not Data bit.
 *      -   0 : Data or unified cache.
 *      -   1 : Instruction cache.
 */
#define CSSELR_IND_I BIT(0)
#define CSSELR_LEVEL_SHIFT 1

/*
 * CCSIDR_EL1, Current Cache Size ID Register
 * Provides information about the architecture of
 * the currently selected cache.
 *
 * https://developer.arm.com/documentation/ddi0601/2022-03/
 * AArch64-Registers/CCSIDR-EL1--Current-Cache-Size-ID-Register?lang=en
 *
 * -    NumSets, bits [27:13]
 *      (Number of sets in cache) - 1, therefore a value of
 *      0 indicates 1 set in the cache. The number of sets
 *      does not have to be a power of 2.
 *
 * -    Associativity, bits [12:3]
 *      (Associativity of cache) - 1, therefore a value of
 *      0 indicates an associativity of 1. The associativity
 *      does not have to be a power of 2.
 *
 * -    LineSize, bits [2:0]
 *      (Log2(Number of bytes in cache line)) - 4. For example:
 *      -   For a line length of 16 bytes: Log2(16) = 4,
 *          LineSize entry = 0. This is the minimum line length.
 *      -   For a line length of 32 bytes: Log2(32) = 5,
 *          LineSize entry = 1.
 */
#define CCSIDR_NUMSETS_SHIFT 13
#define CCSIDR_NUMSETS_MASK (0x1fff << CCSIDR_NUMSETS_SHIFT)
#define CCSIDR_ASS_SHIFT 3
#define CCSIDR_ASS_MASK (0x3ff << CCSIDR_ASS_SHIFT)
#define CCSIDR_LINESIZE_MASK (0x7)

/*
 * CLIDR_EL1, Cache Level ID Register
 *
 * Identifies the type of cache, or caches, that are implemented
 * at each level and can be managed using the architected cache
 * maintenance instructions that operate by set/way,
 * up to a maximum of seven levels.
 *
 * Also identifies the Level of Coherence (LoC) and Level of
 * Unification (LoU) for the cache hierarchy.
 *
 * https://developer.arm.com/documentation/ddi0601/2022-03/
 * AArch64-Registers/CLIDR-EL1--Cache-Level-ID-Register?lang=en
 *
 * -    Ttype<n>, bits [2(n-1)+34:2(n-1)+33], for n = 7 to 1
 *      When FEAT_MTE2 is implemented:
 *          - 00 no tag cache
 *          - 01 separate allocation tag cache
 *          - 10 unified allocation tag and data cache
 *              allocation tags and data in unified lines.
 *          - 11 unified allocation tag and data cache
 *              allocation tags and data in separate lines.
 *
 * -    ICB, bits [32:30]
 *      Inner cache boundary. This field indicates the boundary
 *      for caching Inner Cacheable memory regions.
 *          -  0b000 : Not disclosed by this mechanism.
 *          -  0b001 : L1 cache is the highest Inner Cacheable level.
 *          -  ....  : Lx cache is the highest Inner Cacheable level.
 *          -  0b111 : L7 cache is the highest Inner Cacheable level.
 *
 * -    LoC, bits [26:24]
 *      Level of Unification Uniprocessor for the cache hierarchy.
 *
 * -    LoUIS, bits [23:21]
 *      Level of Unification Inner Shareable for the cache hierarchy.
 *
 * -    Ctype<n>, bits [3(n-1)+2:3(n-1)], for n = 7 to 1
 *      Cache Type fields. Indicate the type of cache that is implemented
 *      and can be managed using the architected cache maintenance instructions
 *      that operate by set/way at each level, from Level 1 up to a maximum of
 *      seven levels of cache hierarchy. Possible values of each field are:
 *          -   0b000: No cache.
 *          -   0b001: Instruction cache only.
 *          -   0b010: Data cache only.
 *          -   0b011: Separate instruction and data caches.
 *          -   0b100: Unified cache.
 */
enum cache_type {
    CACHE_TYPE_NOCACHE = 0,
    CACHE_TYPE_INST = BIT(0),
    CACHE_TYPE_DATA = BIT(1),
    CACHE_TYPE_SEPARATE = CACHE_TYPE_INST | CACHE_TYPE_DATA,
    CACHE_TYPE_UNIFIED = BIT(2),
};

static const char *cache_type_string[] = {
    "nocache",
    "i-cache",
    "d-cache",
    "separate cache",
    "unifed cache"
};

#define MAX_CACHE_LEVEL		7

#define CLIDR_ICB_SHIFT     30
#define CLIDR_LOUU_SHIFT	27
#define CLIDR_LOC_SHIFT		24
#define CLIDR_LOUIS_SHIFT	21

#define CLIDR_ICB(clidr)	(((clidr) >> CLIDR_ICB_SHIFT) & 0x7)
#define CLIDR_LOUU(clidr)	(((clidr) >> CLIDR_LOUU_SHIFT) & 0x7)
#define CLIDR_LOC(clidr)	(((clidr) >> CLIDR_LOC_SHIFT) & 0x7)
#define CLIDR_LOUIS(clidr)	(((clidr) >> CLIDR_LOUIS_SHIFT) & 0x7)

/* Ctypen, bits[3(n - 1) + 2 : 3(n - 1)], for n = 1 to 7 */
#define CLIDR_CTYPE_SHIFT(level)	(3 * (level - 1))
#define CLIDR_CTYPE_MASK(level)		(7 << CLIDR_CTYPE_SHIFT(level))
#define CLIDR_CTYPE(clidr, level)	\
	(((clidr) & CLIDR_CTYPE_MASK(level)) >> CLIDR_CTYPE_SHIFT(level))

/*
 * Getting the value of cwg by read CTR_EL0.
 * The value is log2(x).
 */
static inline unsigned int cache_type_cwg(void)
{
    return (read_sysreg(CTR_EL0) >> CTR_CWG_SHIFT) & CTR_CWG_MASK;
}
static inline unsigned int cache_line_size(void)
{
    u32 cwg = cache_type_cwg();
    return 4 << cwg;
}

static inline enum cache_type get_cache_type(int level)
{
    unsigned long clidr_reg = 0;

    if (level > MAX_CACHE_LEVEL)
        return CACHE_TYPE_NOCACHE;

    clidr_reg = read_sysreg(clidr_el1);
    return CLIDR_CTYPE(clidr_reg, level);
}

/*
 * get the ways and sets on each levels.
 *
 * We can get the information from the raspi maunal.
 * https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711/README.md
 *
 * Caches: 32 KB data + 48 KB instruction L1 cache per core. 1MB L2 cache.
 */
static void get_cache_set_way(unsigned int level, unsigned int ind)
{
    unsigned long val = 0;
    unsigned int line_size, set, way;
    int temp;

    /* 1. Ensure the target cache by writing the CSSELR_EL1 register */
    temp = (level - 1) << CSSELR_LEVEL_SHIFT | ind;
    write_sysreg(temp, CSSELR_EL1);

    /* 2. Read CCSIDR_EL1 register
     * note, the register is implemented two layouts.
     **/
    val = read_sysreg(CCSIDR_EL1);
    set = (val & CCSIDR_NUMSETS_MASK) >> CCSIDR_NUMSETS_SHIFT;
    set ++;
    way = (val & CCSIDR_ASS_MASK) >> CCSIDR_ASS_SHIFT;
    line_size = 1 << ( (val & CCSIDR_LINESIZE_MASK) + 4 );

	printk("          %s: set %u way %u line_size %u size %uKB\n",
			ind ? "i-cache":"d/u cache", set, way, line_size,
			(line_size * way * set)/1024);
}

int cache_self_test(void)
{
    int level;
    unsigned long ctype;
    unsigned long reg_val;

    printk("parse cache info:\n");

    for (level = 1; level <= MAX_CACHE_LEVEL; level ++) {
        /* get cache type */
        ctype = get_cache_type(level);
        /* when the cache type is nocache, return. */
        if (CACHE_TYPE_NOCACHE == ctype) {
            level --;
            break;
        }
		printk("   L%u: %s, cache line size %u\n",
				level, cache_type_string[ctype], cache_line_size());
        if (CACHE_TYPE_SEPARATE == ctype) {
            get_cache_set_way(level, 1);
            get_cache_set_way(level, 0);
        } else if (CACHE_TYPE_UNIFIED == ctype) {
            get_cache_set_way(level, 0);
        }
    }

    /*
     * Get ICB, LOUU, LOC and LOUIS
     * ICB: inner cache boundary.
     * LOUU: Single core PoU cache boundary.
     * LOC: PoC cache boundary.
     * LOUIS: PoU for inner sharing cache boundary.
     */
    reg_val = read_sysreg(clidr_el1);
	printk("   IBC:%u LOUU:%u LoC:%u LoUIS:%u\n",
			CLIDR_ICB(reg_val), CLIDR_LOUU(reg_val),
			CLIDR_LOC(reg_val), CLIDR_LOUIS(reg_val));
    reg_val = read_sysreg(ctr_el0);
    printk("   Detected %s I-cache\n", icache_policy_str[CTR_L1IP(reg_val)]);

    return level;
}