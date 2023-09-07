#!/vendor/bin/sh

set_acdb_path_props() {
	i=0
	for f in `ls /vendor/etc/acdbdata/${1}/*.*`; do
		setprop "persist.vendor.audio.calfile${i}" "${f}"
		let i+=1
	done
}

case "$(cat /sys/xiaomi-msm8937-mach/codename)" in
	"rolex")
		# Device Info
		setprop ro.vendor.xiaomi.device rolex
		setprop ro.vendor.xiaomi.series wt8917
		# Audio
		setprop persist.vendor.audio.fluence.speaker false
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props wt8917
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"riva")
		# Device Info
		setprop ro.vendor.xiaomi.device riva
		setprop ro.vendor.xiaomi.series wt8917
		# Audio
		setprop persist.vendor.audio.fluence.speaker false
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props wt8917
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"ugglite")
		# Device Info
		setprop ro.vendor.xiaomi.device ugglite
		setprop ro.vendor.xiaomi.series ulysse
		# Audio
		setprop persist.vendor.audio.fluence.speaker true
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props ulysse
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 0
		;;
	"ugg")
		# Device Info
		setprop ro.vendor.xiaomi.device ugg
		setprop ro.vendor.xiaomi.series ulysse
		# Audio
		setprop persist.vendor.audio.fluence.speaker true
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props ulysse
		# Camera
		setprop persist.s5k3p8sp.flash.low 320
		setprop persist.s5k3p8sp.flash.light 300
		setprop persist.ov16885.flash.low 290
		setprop persist.ov16885.flash.light 275
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 2
		;;
	"land")
		# Device Info
		setprop ro.vendor.xiaomi.device land
		setprop ro.vendor.xiaomi.series wt8937
		# Audio
		setprop persist.vendor.audio.fluence.speaker false
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props land
		# Camera
		setprop persist.camera.gyro.android 0
		setprop persist.camera.gyro.disable 1
		# Fingerprint
		if grep -E "S88537AC1|S88537EC1" /sys/xiaomi-msm8937-mach/wingtech_board_id ; then
			setprop ro.vendor.fingerprint.supported 0
		else
			setprop ro.vendor.fingerprint.supported 1
		fi
		;;
	"santoni")
		# Device Info
		setprop ro.vendor.xiaomi.device santoni
		setprop ro.vendor.xiaomi.series wt8937
		# Audio
		setprop persist.vendor.audio.fluence.speaker false
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
		set_acdb_path_props santoni
		# Fingerprint
		setprop vendor.fingerprint.disable_notify_cancel_hack 1
		setprop ro.vendor.fingerprint.supported 1
		;;
	"prada")
		setprop ro.vendor.xiaomi.device prada
		# Audio
		setprop persist.vendor.audio.fluence.speaker true
		setprop persist.vendor.audio.fluence.voicecall true
		setprop persist.vendor.audio.fluence.voicerec false
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
