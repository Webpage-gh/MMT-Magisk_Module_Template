该仓库已存档，因为我认为不再需要维护了。如果有issue、pr、取消存档的请求，[请到issue仓库](https://github.com/Webpage-gh/issues/issues/new)

## Magisk_Module_Template

## 用法: [点此下载模板](https://github.com/Webpage-gh/MMT-Magisk_Module_Template/archive/refs/heads/main.zip)
下载完成后解压到当前目录，根据每个sh文件中的提示进行编写，编写完成后压缩即可。这些是在customize.sh中的提示：

## 调试代码
Root 管理器会内置一个 busybox，避免手机厂商的改动影响代码，让脚本始终在可预测的环境中执行。要模拟这个环境，请在终端中执行以下命令（建议复制粘贴避免出错）
```POSIX sh
/system/bin/su -c 'for i in magisk ksu/bin ap/bin; do i=/data/adb/$i/busybox; if [ -x "$i" ]; then ASH_STANDALONE=1 $i sh; break; fi; done'
```
或者，手动选择一个：
Magisk: `ASH_STANDALONE=1 /data/adb/magisk/busybox sh <sh脚本>`
KernelSU: `ASH_STANDALONE=1 /data/adb/ksu/bin/busybox sh <sh脚本>`
APatch: `ASH_STANDALONE=1 /data/adb/ap/bin/busybox sh <sh脚本>`
其中 <sh脚本> 为可选项，不填写时会打开一个 Shell。

## 有用的变量
```
REPLACE="
/system/app/YouTube
/system/app/Bloatware
"
```
启用模块时，将会把 `/system/app/YouTube` 和 `/system/app/Bloatware` 替换为空目录。禁用模块后重启恢复。
```
REMOVE="
/system/app/YouTube
/system/app/Bloatware
"
```
**KernelSU 和 APatch 特有功能**，将会把 `/system/app/YouTube` 和 `/system/app/Bloatware` 删除。禁用模块后重启恢复。

## 通用变量
- MODPATH (path): 当前模块的安装目录
- TMPDIR (path): 可以存放临时文件的目录
- ZIPFILE (path): 当前模块的安装包文件
- ARCH (string): 设备的 CPU 构架，只有 arm64
- IS64BIT (bool): 是否是 64 位设备
- API (int): 当前设备的 Android API 版本 (如：Android 6.0 上为 23)

### KernelSU 变量
- KSU (bool): 标记此脚本运行在 KernelSU 环境下，此变量的值将永远为 true，你可以通过它区分 Magisk。
- KSU_VER (string): KernelSU 当前的版本名字 (如： v0.4.0)
- KSU_VER_CODE (int): KernelSU 用户空间当前的版本号 (如 10672)
- KSU_KERNEL_VER_CODE (int): KernelSU 内核空间当前的版本号 (如 10672)
- BOOTMODE (bool): 此变量在 KernelSU 中永远为 true

### APATCH 变量
- KERNELPATCH (bool): 标记此脚本运行在 APatch 环境下，此变量的值将永远为 true
- KERNEL_VERSION (hex): 从 KernelPatch 继承，内核版本号 (如： 50a01 是指 5.10.1)
- KERNELPATCH_VERSION (hex): 从 KernelPatch 继承，KernelPatch 版本号 (如： a05 是指 0.10.5)
- SUPERKEY (string): 从 KernelPatch 继承，用于调用 kpatch 或者 supercall
- APATCH (bool): 标记此脚本运行在 APatch 环境下，此变量的值将永远为 true
- APATCH_VER_CODE (int): APatch 当前的版本号 (如 10672)
- APATCH_VER (string): APatch 当前的版本名 (如 10672)
- BOOTMODE (bool): 此变量在 APatch 中永远为 true

## 内置函数
```sh
ui_print() {
  if $BOOTMODE; then
    echo "$1"
  else
    echo -e "ui_print $1\nui_print" >> /proc/self/fd/$OUTFD
  fi
}
```
例: `ui_print "- 正在设置权限"`  
确保 Recovery 模式下正确打印文字到屏幕上，尽管 KernelSU 和 APatch 不支持 Recovery 模式下安装模块，但习惯上依然使用 ui_print 代替 echo

```sh
abort() {
  ui_print "$1"
  $BOOTMODE || recovery_cleanup
  [ ! -z $MODPATH ] && rm -rf $MODPATH
  rm -rf $TMPDIR
  exit 1
}
```
例: `abort "! 不支持的架构: $ARCH"`  
abort 比 exit 会多做一个清理的步骤，这也是我们应该避免使用 exit 的原因

```sh
set_perm() {
  local file_path="$1"
  local user="$2"
  local group="$3"
  local mode="$4"
  local CON=$5
  [ -z $CON ] && CON=u:object_r:system_file:s0
  chown "$user":"$group" "$file_path" || return 1
  chmod "$mode" "$file_path" || return 1
  chcon "$selinux_context" "$file_path" || return 1
}
```
例: `set_perm /data/adb/modules/post-fs-data.d/example.sh root root 755`  
设置文件权限所有者、用户组、权限和 SELinux 上下文，SELinux 上下文为可选项

```sh
set_perm_recursive() {
  local dir_path="$1"
  local user="$2"
  local group="$3"
  local dir_mode="$4"
  local file_mode="$5"
  local selinux_context="$6"
  find $dir_path -type d 2>/dev/null | while read dir; do
    set_perm "$dir" "$user" "$group" "$dir_mode" "$selinux_context"
  done
  find $dir_path -type f -o -type l 2>/dev/null | while read file; do
    set_perm "$file" "$user" "$group" "$file_mode" "$selinux_context"
  done
}
```
例: 
```
pkg=bin.mt.plus
user=$(dumpsys package $pkg | sed -n 's/.*userId=\([0-9]*\).*/\1/p')
group=$user
set_perm_recursive "/data/user/0/$pkg" $user $group 771 660
```
递归设置目录及其内容的所有权、权限和上下文
