MODDIR=${0%/*}


---------------
此脚本在显示开机动画前后执行，和开机过程同时进行，大多数命令推荐在这种模式执行。
MODDIR变量用于获取模块的路径，例如/data/adb/module。不要硬编码路径，在以后可能会被修改。如果您记不住，可以使用`MODDIR=$(dirname "$0")`代替。
您可以删除post-fs-data.sh、post-mount.sh、boot-completed.sh，如果您没有用到他们；但不要删除和更改META-INF，尽管它没什么用。

## RESETPROP 命令用法
系统属性操纵工具

用法：resetprop [标志] [参数 …]

读取模式参数：
 （没有参数） 打印所有属性
 名称         获取名称的属性

写入模式参数：
 名称值将属性名称设置为值
 -f, --file     加载并从文件中设置属性
 -d, --delete 名称 - 删除属性

等待模式参数（用-w切换）：
 名称         等到期望的名称改变
 名称 值      等到期望的值出现

通用标志：
 -h, --help   帮助显示此消息
 -v           打印详细输出到stderr
 -w          切换到等待模式

读取模式标志：
 -p          也从 /data/property/persistent_properties 中读取persist.*属性
 -P          仅从/data/property/persistent_properties 中读取persist.*属性
 -Z          获取属性上下文（类似于SELinux上下文）而不是属性的值

写入模式标志：
 -n          绕过 property_service 设置属性
 -p          将persist.*属性设置到 /data/property/persistent_properties 中实现持久化

如果属性更改未通过 property_service（使用-n标志写入属性），则不会触发在 `*.rc` 脚本中注册的`on property:foo=bar`操作
### 例子
resetprop ro.product.board
获取设备代号

resetprop -w sys.boot_completed 0
等待开机完成

resetprop ro.boot.selinux enforcing
伪装SELinux状态为强制模式