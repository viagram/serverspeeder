#!/bin/bash
#
# 本脚本修改自91yun: https://www.91yun.org/archives/683
# 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

[ $(id -u) != "0" ] && echo "Error: 请用root用户运行此脚本." && exit 1

#定义变量
#授权文件自动生成url
APX=https://dnsdian.com/api/apxkey.php
#安装包下载地址
INSTALLPACK=https://raw.githubusercontent.com/viagram/serverspeeder/master/serverspeeder.tar.gz
#bin下载地址
BIN=downloadurl
BinURL=https://raw.githubusercontent.com/viagram/serverspeeder/master

cur_dir=`pwd`/serverspeeder-tmp
if [ ! -d "${cur_dir}" ]; then
    mkdir -p ${cur_dir}
fi
cd ${cur_dir}

#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        ver3='x64'
    else
        ver3='x32'
    fi
}

Get_Dist_Name

#安装相应的软件
if [ "$DISTRO" == "CentOS" ]; then
    yum install -y redhat-lsb curl net-tools
elif [ "$DISTRO" == "Debian" ]; then
    apt-get update
    apt-get install -y lsb-release curl
elif [ "$DISTRO" == "Ubuntu" ]; then
    apt-get update
    apt-get install -y lsb-release curl
else
    echo "一键脚本暂时只支持centos，ubuntu和debian的安装."
    exit 1
fi

release=$DISTRO
#发行版本
if [ "$release" == "Debian" ]; then
    ver1str="lsb_release -rs | awk -F '.' '{ print \$1 }'"
else
    ver1str="lsb_release -rs | awk -F '.' '{ print \$1\".\"\$2 }'"
fi
ver1=$(eval $ver1str)
#ver11=`echo $ver1 | awk -F '.' '{ print $1 }'`

#内核版本
ver2=`uname -r`
#锐速版本
ver4=3.10.61.0

echo "================================================="
echo "操作系统：$release "
echo "发行版本：$ver1 "
echo "内核版本：$ver2 "
echo "内核位数：$ver3 "
echo "锐速版本：$ver4 "
echo "================================================="

#下载支持的bin列表
curl -s "$BinURL/serverspeederbin.txt" -o serverspeederbin.txt || { echo "文件下载失败, 自动退出.";;exit 1;}

#判断内核版本
grep -q "$release/$ver11[^/]*/$ver2/$ver3" serverspeederbin.txt
if [ $? == 1 ]; then
        #echo "没有找到内核"
    if [ "$release" == "CentOS" ]; then
        ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
        ver22=`echo $ver2 | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
        #cat serverspeederbin.txt | grep -q  "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"
        cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"

        if [ $? == 1 ]; then
            echo -e "\r\n"
            echo "锐速自动安装暂不支持该内核，程序退出."
            exit 1
        fi
        echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
        echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
        cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
    fi


    if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
        ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
        ver22=`echo $ver2 | awk -F '-' '{ print $2 }'`
        cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"

        if [ $? == 1 ]; then
            echo -e "\r\n"
            echo "锐速自动安装暂不支持该内核，程序退出."
            exit 1
        fi
        echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
        echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
        cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
    fi


    echo "请选择（输入数字序号）："
    read cver2
    if [ "$cver2" == "" ]; then
        echo "未选择任何内核版本，脚本退出"
        exit 1
    fi

    if [ "$release" == "CentOS" ]; then
        cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' | awk 'NR==1{print \$1}'"
    fi
    if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
        cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' awk 'NR==1{print \$1}'"
    fi
    ver2=$(eval $cver2str)
    if [ "$ver2" == "" ]; then
        echo "脚本获得不了内核版本号，错误退出"
        exit 1
    fi
    #根据所选的内核版本，再回头确定大版本

fi
#判断锐速版本
grep -q "$release/$ver1/$ver2/$ver3/$ver4" serverspeederbin.txt
if [ $? == 1 ]; then
    grep -q "$release/$ver11[^/]*/$ver2/$ver3/$ver4" serverspeederbin.txt
    if [ $? == 1 ]; then
        echo -e "\r\n"
        echo -e "我们用的锐速安装文件是\033[41;37m 3.10.60.0  \033[0m，但这个内核没有匹配的，请选择一个接近的锐速版本号尝试，不确保一定可用,(如果有版本号重复的选项随便选一个就可以)"
        cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver2/$ver3/"  | awk -F '/' '{ print NR"："$5 }'
        echo "请选择锐速版本号（输入数字序号）："
            read cver4
        if [ "$cver4" == "" ]; then
            echo "未选择任何锐速版本，脚本退出"
            exit 1
        fi
            cver4str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver2/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$5 }' | awk -F '：' '/"$cver4："/{ print \$2 }' | awk 'NR==1{print \$1}'"
            ver4=$(eval $cver4str)
        if [ "$ver4" == "" ]; then
            echo "没取到锐速版本，程序出错退出。"
            exit 1
        fi
    fi
    #根据锐速版本，内核版本，再回头确定使用的大版本。
    cver1str="cat serverspeederbin.txt | grep '$release/$ver11[^/]*/$ver2/$ver3/$ver4' | awk -F '/' 'NR==1{ print \$2 }'"
    ver1=$(eval $cver1str)
fi

BINFILESTR="cat serverspeederbin.txt | grep '$release/$ver1/$ver2/$ver3/$ver4' | awk -F '/' '{ print \$6 }'"
BINFILE=$(eval $BINFILESTR)
BIN="$BinURL/Bin/$release/$ver1/$ver2/$ver3/$ver4/$BINFILE"
rm -rf serverspeederbin.txt

#先取外网ip，根据取得ip获得网卡，然后通过网卡获得mac地址。
# if [ "$1" == "" ]; then
    # IP=$(curl ipip.net | awk -F ' ' '{print $2}' | awk -F '：' '{print $2}')
    # NC="ifconfig | awk -F ' |:' '/$IP/{print a}{a=\$1}'"
    # NETCARD=$(eval $NC)
# else
    # NETCARD=eth0
# fi
# MACSTR="LANG=C ifconfig $NETCARD | awk '/HWaddr/{ print \$5 }' "
# MAC=$(eval $MACSTR)
# if [ "$MAC" = "" ]; then
# MACSTR="LANG=C ifconfig $NETCARD | awk '/ether/{ print \$2 }' "
# MAC=$(eval $MACSTR)
# fi
# echo IP=$IP
# echo NETCARD=$NETCARD

if [ "$1" == "" ]; then
    MACSTR="LANG=C ifconfig eth0 | awk '/HWaddr/{ print \$5 }' "
    MAC=$(eval $MACSTR)
    if [ "$MAC" == "" ]; then
        MACSTR="LANG=C ifconfig eth0 | awk '/ether/{ print \$2 }' "
        MAC=$(eval $MACSTR)
    fi
    if [ "$MAC" == "" ]; then
        #MAC=$(ip link | awk -F ether '{print $2}' | awk NF | awk 'NR==1{print $1}')
        echo "本破解只支持eth0名的网卡, 如果你的网卡不是eth0, 请修改网卡名(https://www.91yun.org/archives/1217)"
        exit 1
    fi
else
    MAC=$1
fi
echo MAC=$MAC

#如果自动取不到就要求手动输入
if [ "$MAC" = "" ]; then
echo "无法自动取得mac地址，请手动输入："
read MAC
echo "手动输入的mac地址是$MAC"
fi

#下载安装包
echo "======================================"
echo "开始下载安装包。。。。"
echo "======================================"
wget -o /dev/null --no-check-certificate $INSTALLPACK -O serverspeeder.tar.gz -c 2> /dev/null
tar xfz serverspeeder.tar.gz || { echo "下载安装包失败，请检查";;exit 1;}

#下载授权文件
echo "开始下载授权文件。。。。"
echo "======================================"
#expDate=`expr $toDate + 1`
expDate=$(($(date +%Y)+1))$(date +%m)$(($(date +%d)-1))
curl -s "$APX?mac=$MAC" -o "serverspeeder/apxfiles/etc/apx-${expDate}.lic" 2> /dev/null || { echo "下载授权文件失败，请检查$APX?mac=$MAC";;exit 1;;}


#取得序列号
echo "开始修改配置文件。。。。"
echo "======================================"
SNO=$(curl -s "$APX?mac=$MAC&sno") || { echo "生成序列号失败，请检查";;exit 1;}
echo "序列号：$SNO"
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" serverspeeder/apxfiles/etc/config
sed -i "s/expDateTime/${expDate}/g" serverspeeder/apxfiles/etc/config
rv=$release"_"$ver1"_"$ver2
sed -i "s/Debian_7_3.2.0-4-amd64/$rv/g" serverspeeder/apxfiles/etc/config
# sed -i "s/accppp=\"1\"/accppp=\"0\"/g" serverspeeder/apxfiles/etc/config

#下载bin文件
echo "======================================"
echo "开始下载bin文件。。。。"
echo "======================================"
curl -s $BIN -o "serverspeeder/apxfiles/bin/acce-3.10.61.0-["$release"_"$ver1"_"$ver2"]" 2> /dev/null || { echo "下载bin运行文件失败，请检查";;exit 1;}

#切换目录执安装文件
cd serverspeeder

# Restore license permission to read and write if it exist for re-install.
if [ -f "/serverspeeder/etc/apx-${expDate}.lic" ]; then
    chattr -i "/serverspeeder/etc/apx-${expDate}.lic"
fi

echo "开始执行安装。。。。"
echo "======================================"
bash install.sh

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
#CentOS7添加开机启动
# if [ "$release" == "CentOS" ] && [ "$ver11" == "7" ]; then
    # chmod +x /etc/rc.d/rc.local
    # echo "/serverspeeder/bin/serverSpeeder.sh start" >> /etc/rc.local
# fi
#安装完显示状态
cd ${cur_dir}
cd ..
rm -rf ${cur_dir}

echo "程序运行状态:"
echo "======================================"
bash /serverspeeder/bin/serverSpeeder.sh status
rm -f $0
