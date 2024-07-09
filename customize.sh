<<EOF
刷入Magisk模块时Magisk会执行一次此脚本，使用busybox环境，内置一些函数，请优先使用它们，伪代码见最后（不保证可被shell理解）

术语
KSU：KernelSU
AP：APatch
KAP：KSU+AP
环境变量
MAGISK_VER_CODE（string）：在 KSU/AP 中永远为 25200
MAGISK_VER（int）：在 KSU 中永远为 v25.2，请不要通过这两个变量来判断是否是 KernelSU！
KSU (bool): 标记此脚本运行在 KernelSU 环境下，此变量的值将永远为 true，你可以通过它区分 Magisk。
KSU_VER (string): KernelSU 当前的版本名字 (如： v0.4.0)
KSU_VER_CODE (int): KernelSU 用户空间当前的版本号 (如. 10672)
KSU_KERNEL_VER_CODE (int): KernelSU 内核空间当前的版本号 (如. 10672)
BOOTMODE (bool): 此变量在 KernelSU 中永远为 true
MODPATH (path): 当前模块的安装目录
TMPDIR (path): 可以存放临时文件的目录
ZIPFILE (path): 当前模块的安装包文件
ARCH (string): 设备的 CPU 构架，有如下几种： arm, arm64, x86, or x64
IS64BIT (bool): 是否是 64 位设备
API (int): 当前设备的 Android API 版本 (如：Android 6.0 上为 23)
WARNING

MAGISK_VER_CODE 在 KernelSU 中永远为 25200，MAGISK_VER 则为 v25.2，请不要通过这两个变量来判断是否是 KernelSU！
REPLACE中的路径可被Magisk和KSU及AP完全替换为模块中的文件夹，而不是叠加；不要使用.replace文件，因为KSU和AP不支持。
REPLACE="
/system/app/YouTube
/system/app/Bloatware
"
KSU支持REMOVE用法，可以删除文件夹，解决了REPLACE只能替换为空文件夹的问题。Magisk不支持此用法，AP也许支持。
REMOVE="
/system/app/YouTube
/system/app/Bloatware
"

伪代码
ui_print() {
  echo "$@"
}

abort() {
  echo "$@"
  echo "! "
  exit
}

set_perm() {
  target=$1
  owner=$2
  group=$3
  permission=$4
  context=$5
  if [ "$context" == "" ]; then content="u:object_r:system_file:s0"
  
  chown ${owner}:{$group} $target
  chmod $permission $target
  chcon $context $target
}

set_perm_recursive() {
  directory=$1
  owner=$2
  group=$3
  dirpermission=$4
  filepermission=$5
  context=$6
  if [ "$context" == "" ]; then content="u:object_r:system_file:s0"

    for file in $directory/**: do
       set_perm $file $owner $group $filepermission $context
    done

    for dir in ( $directory/**/ $directory ); then
       set_perm $dir $owner $group $dirpermission $context
    done
EOF
