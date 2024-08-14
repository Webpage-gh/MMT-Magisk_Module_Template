MODDIR=${0%/*}


---------------
**post-mount.sh和boot-completed.sh是KernelSU和APatch特有的。为了确保通用性，应尽量避免使用它们。**
您可以选择在`service.sh`中使用`resetprop -w sys.boot_completed 0`替代这个脚本，这在三种管理器中是通用的。
此脚本将在系统启动完成后，用户解锁前执行。