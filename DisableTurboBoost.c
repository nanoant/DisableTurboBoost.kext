#include <libkern/libkern.h>
#include <mach/mach_types.h>
#include <i386/proc_reg.h>

extern void mp_rendezvous_no_intrs(
		void (*action_func)(void *),
		void *arg);

const uint64_t expectedFeatures  = 0x850089;
const uint64_t disableTurboBoost = 0x4000000000;

static void disable_tb(__unused void * param_not_used) {
	wrmsr64(0x1a0, rdmsr64(0x1a0) | disableTurboBoost);
}

static void enable_tb(__unused void * param_not_used) {
	wrmsr64(0x1a0, rdmsr64(0x1a0) & ~disableTurboBoost);
}

static kern_return_t start(kmod_info_t *ki, void *d) {
	mp_rendezvous_no_intrs(disable_tb, NULL);
	printf("Disabled Turbo Boost (%llx)\n", rdmsr64(0x1a0));
	return KERN_SUCCESS;
}

static kern_return_t stop(kmod_info_t *ki, void *d) {
	mp_rendezvous_no_intrs(enable_tb, NULL);
	printf("Re-enabled Turbo Boost (%llx)\n", rdmsr64(0x1a0));
	return KERN_SUCCESS;
}

extern kern_return_t _start(kmod_info_t *ki, void *data);
extern kern_return_t _stop(kmod_info_t *ki, void *data);

KMOD_EXPLICIT_DECL(com.nanoant.DisableTurboBoost, "0.0.1", _start, _stop)
__private_extern__ kmod_start_func_t *_realmain = start;
__private_extern__ kmod_stop_func_t  *_antimain = stop;
__private_extern__ int _kext_apple_cc = __APPLE_CC__;
