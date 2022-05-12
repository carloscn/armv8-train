#ifndef	P_BASE_H
#define	P_BASE_H

/* Main peripherals on Low Peripheral mode
 * - ARM and GPU can access
 * see <BCM2711 ARM Peripherals> 1.2.4
 */
#define PBASE 0xFE000000
/*
 * ARM LOCAL register on Low Peripheral mode
 * - Only ARM can access
 * see <BCM2711 ARM Peripherals> 6.5.2
 */
#define ARM_LOCAL_BASE 0xff800000

/* GIC V2*/
#define GIC_V2_DISTRIBUTOR_BASE     (ARM_LOCAL_BASE + 0x00041000)
#define GIC_V2_CPU_INTERFACE_BASE   (ARM_LOCAL_BASE + 0x00042000)

#endif  /*_P_BASE_H */
