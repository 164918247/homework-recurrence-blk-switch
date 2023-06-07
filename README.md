# 源地址
https://github.com/resource-disaggregation/blk-switch

# 选择Ubuntu版本
论文里提到的系统版本是Ubuntu 20.04 LTS
Github里提到的是Ubuntu 16.04 LTS
实验使用了 Ubuntu 20.04 LTS

# 提前下载好所需的包
### 因为同时需要配置两台服务器，可以提前下载所需的包，不用下两次
https://github.com/resource-disaggregation/blk-switch
https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.4.43.tar.gz
https://github.com/linux-nvme/libnvme
https://github.com/linux-nvme/nvme-cli

# 编译内核前先装好需要的包
apt install unzip
apt install make
apt install gcc
apt install flex
apt install bison
apt install ncurses-dev
apt install libelf-dev
apt install libssl-dev
apt install bc
apt install sysstat

# 过程中遇到的问题
### 内核编译报错
getting started instruction进行到2.5的时候
```
make modules_install
```
报错
```
cannot stat './modules.builtin.modinfo': No such file or directory
```
这是ubuntu 20.04 LTS上会出现的问题，在Ubuntu 16.04 LTS上没遇到。
编译时只有modules.builtin，没有modules.builtin.modinfo
参考以下链接解决：
https://github.com/frankaemika/libfranka/issues/62
https://askubuntu.com/questions/1329538/compiling-the-kernel-5-11-11
修改.config文件
```
CONFIG_DEBUG_INFO_BTF=y
改为
# CONFIG_DEBUG_INFO_BTF is not set

CONFIG_SYSTEM_TRUSTED_KEYS="debian/canonical-certs.pem"
改为
CONFIG_SYSTEM_TRUSTED_KEYS=""
```
并执行
```
scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
make clean
```
再重新进行2.5

### 修改启动内核
getting started instruction进行到2.6
可以在以下文件看到新编译内核的名字
```
boot/grub/grub.cfg
```

### 安装nvme-cli
getting started instruction进行到3.Host configuration.1
```
make
make install
```
之前需要先安装libnvme，并配置lib包路径
见：https://github.com/linux-nvme/nvme-cli

### 安装libnvme
见：https://github.com/linux-nvme/libnvme
```
meson -C .build
```
会报错
根据：https://github.com/pistacheio/pistache/issues/880
因为Ubuntu 20.04 LTS上的meson版本低，不支持这个命令
可以用以下命令代替
```
ninja -C .build
```
安装完成后还需要在/etc/ld.so.conf.d/路径下创建任意一个.conf文件，把lib文件的路径写在里面
并更新缓存
```
sudo ldconfig
```