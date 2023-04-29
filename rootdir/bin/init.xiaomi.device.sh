#!/vendor/bin/sh

set_acdb_path_props() {
	i=0
	for f in `ls /vendor/etc/acdbdata/${1}/*.*`; do
		setprop "persist.vendor.audio.calfile${i}" "${f}"
		let i+=1
	done
}

case "$(cat /sys/firmware/devicetree/base/model)" in
	"Qualcomm Technologies, Inc. MSM8917-PMI8937 QRD SKU5")
		if [ -e /sys/class/leds/infrared/transmit ]; then
			setprop ro.vendor.xiaomi.device rolex
		else
			setprop ro.vendor.xiaomi.device riva
		fi
		setprop ro.vendor.xiaomi.series rova
		# Audio
		set_acdb_path_props rova
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"Qualcomm Technologies, Inc. MSM8917 QRD SKU5")
		setprop ro.vendor.xiaomi.device riva
		setprop ro.vendor.xiaomi.series rova
		# Audio
		set_acdb_path_props rova
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"Qualcomm Technologies, Inc. MSM8917-PMI8937 MTP")
		setprop ro.vendor.xiaomi.device ugglite
		setprop ro.vendor.xiaomi.series ulysse
		# Audio
		set_acdb_path_props ulysse
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"Qualcomm Technologies, Inc. MSM8940-PMI8937 MTP")
		setprop ro.vendor.xiaomi.device ugg
		setprop ro.vendor.xiaomi.series ulysse
		# Audio
		set_acdb_path_props ulysse
		# Camera
		setprop persist.s5k3p8sp.flash.low 320
		setprop persist.s5k3p8sp.flash.light 300
		setprop persist.ov16885.flash.low 290
		setprop persist.ov16885.flash.light 275
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 2
		;;
	"Qualcomm Technologies, Inc. MSM8937-PMI8950 QRD SKU1")
		# Device Info
		setprop ro.vendor.xiaomi.device land
		setprop ro.vendor.xiaomi.series landtoni
		# Audio
		set_acdb_path_props land
		# Camera
		setprop persist.camera.gyro.android 0
		setprop persist.camera.gyro.disable 1
		# Fingerprint
		if grep -E "S88537AC1|S88537EC1" /proc/cmdline ; then
			setprop ro.vendor.fingerprint.supported 0
		else
			setprop ro.vendor.fingerprint.supported 1
		fi
		;;
	"Qualcomm Technologies, Inc. MSM8940-PMI8950 QRD SKU7")
		# Device Info
		setprop ro.vendor.xiaomi.device santoni
		setprop ro.vendor.xiaomi.series landtoni
		# Audio
		set_acdb_path_props santoni
		# Fingerprint
		setprop vendor.fingerprint.disable_notify_cancel_hack 1
		setprop ro.vendor.fingerprint.supported 1
		;;
	"Qualcomm Technologies, Inc. MSM8937-PMI8950 MTP")
		setprop ro.vendor.xiaomi.device prada
		# Audio
		set_acdb_path_props prada
		# Camera
		setprop persist.camera.gyro.android 0
		setprop persist.camera.gyro.disable 1
		setprop persist.camera.is_type 1
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 1
		;;
esac

exit 0