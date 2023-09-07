#include <sys/ioctl.h>

struct gf_key {
	unsigned int key;
	int value;
};

#define  GF_IOC_MAGIC	'G'
#define  GF_IOC_DISABLE_IRQ	_IO(GF_IOC_MAGIC, 0)
#define  GF_IOC_ENABLE_IRQ	_IO(GF_IOC_MAGIC, 1)
#define  GF_IOC_SETSPEED	_IOW(GF_IOC_MAGIC, 2, unsigned int)
#define  GF_IOC_RESET	_IO(GF_IOC_MAGIC, 3)
#define  GF_IOC_COOLBOOT	_IO(GF_IOC_MAGIC, 4)
#define  GF_IOC_SENDKEY	_IOW(GF_IOC_MAGIC, 5, struct gf_key)
#define  GF_IOC_CLK_READY	_IO(GF_IOC_MAGIC, 6)
#define  GF_IOC_CLK_UNREADY	_IO(GF_IOC_MAGIC, 7)
#define  GF_IOC_PM_FBCABCK	_IO(GF_IOC_MAGIC, 8)
#define  GF_IOC_POWER_ON	_IO(GF_IOC_MAGIC, 9)
#define  GF_IOC_POWER_OFF	_IO(GF_IOC_MAGIC, 10)
#define  GF_IOC_ENABLE_GPIO	_IO(GF_IOC_MAGIC, 11)
#define  GF_IOC_RELEASE_GPIO	_IO(GF_IOC_MAGIC, 12)
