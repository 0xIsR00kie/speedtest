#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;34m'
PLAIN='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# check python
if  [ ! -e '/usr/bin/python' ]; then
        echo -e
        read -p "${RED}Error:${PLAIN} python is not install. You must be install python command at first.\nDo you want to install? [y/n]" is_install
        if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
            if [ "${release}" == "centos" ]; then
                        yum -y install python
                else
                        apt-get -y install python
                fi
        else
            exit
        fi

fi

# check wget
if  [ ! -e '/usr/bin/wget' ]; then
        echo -e
        read -p "${RED}Error:${PLAIN} wget is not install. You must be install wget command at first.\nDo you want to install? [y/n]" is_install
        if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
                if [ "${release}" == "centos" ]; then
                        yum -y install wget
                else
                        apt-get -y install wget
                fi
        else
                exit
        fi
fi

# install speedtest
if  [ ! -e '/tmp/speedtest.py' ]; then
    wget --no-check-certificate -P /tmp https://raw.github.com/sivel/speedtest-cli/master/speedtest.py > /dev/null 2>&1
fi
chmod a+rx /tmp/speedtest.py

speed_test(){
        if [[ "$1" == "" ]]; then
                temp=$(python /tmp/speedtest.py --share 2>&1)
        else
                temp=$(python /tmp/speedtest.py --server $1 --share 2>&1)
        fi
        
        is_down=$(echo "$temp" | grep 'Download')
        if [[ ${is_down} ]]; then
        local REDownload=$(echo "$temp" | awk -F ':' '/Download/{print $2}')
        local reupload=$(echo "$temp" | awk -F ':' '/Upload/{print $2}')
        local relatency=$(echo "$temp" | awk -F ':' '/Hosted/{print $2}')
        temp=$(echo "$relatency" | awk -F '.' '{print $1}')
        if [[ ${temp} -gt 1000 ]]; then
            relatency=" 000.000 ms"
        fi
        local nodeName=$2

        printf "${YELLOW}%-17s${GREEN}%-25s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
        else
        local cerror="ERROR"
        fi
}

echo ""
printf "%-14s%-25s%-20s%-12s\n" "Node Name" "Upload Speed" "Download Speed" "Latency"
start=$(date +%s)

speed_test '' '本地测试'
speed_test '27810' '兰宁电信'
speed_test '5674' '兰宁联通'
speed_test '32155' '香港移动'
speed_test '37639' '香港移动'
speed_test '16192' '深圳联通'
speed_test '27594' '广州电信'
speed_test '26678' '广州联通'
speed_test '37834' '厦门联通'
speed_test '4884' '福州电信'
speed_test '28225' '湖南电信5G'
speed_test '4870' '湖南联通5G'
speed_test '19036' '香港数码通'
speed_test '37695' '香港联通国际'

end=$(date +%s)
rm -rf /tmp/speedtest.py
echo ""
time=$(( $end - $start ))
if [[ $time -gt 60 ]]; then
	min=$(expr $time / 60)
	sec=$(expr $time % 60)
	echo -ne "花费时间：${min} 分 ${sec} 秒"
else
	echo -ne "花费时间：${time} 秒"
fi
echo -ne "\n当前时间: "
echo $(date +%Y-%m-%d" "%H:%M:%S)
echo "全面测试完成！"
