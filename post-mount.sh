MODDIR=${0%/*}


---------------
**post-mount.sh和boot-completed.sh是KernelSU和APatch特有的。为了确保通用性，应尽量避免使用它们。**
此脚本将在模块挂载后，Zygote启动前执行。换句话说，它依然属于post-fs-data阶段，注意事项参见post-fs-data.sh。