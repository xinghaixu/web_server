#!/bin/bash
source echo_color.sh

function process(){
    path=$1

    echo_green_more "请输入网址，上传文件" "http://XXXXXXXXXXXXXXXXX:8001/"
    echo_yellow "上传成功后，请输入文件名";read filename

    # 异常捕获
    trap "kill $pid;rm ${root_dir}/${filename};echo_red '异常退出';exit -1" 1 2

    grep 'upload success' ../log/${logName}|grep "${root_dir}/${filename}"
    if [ $? -eq 0 ];then
        echo ""
        echo_green "上传到服务器成功,请check文件信息【check成功，数据进行copy】"
        ls -l ./|grep -w ${filename}
        echo_yellow "请输入y/n：";read check_result 2>/dev/null;
        if [ "$check_result" == "Y" ] || [ "$check_result" == "y" ];then
            mv -i ${root_dir}/${filename} ${path}/
            if [ $? -eq 0 ];then
                echo_green "文件上传成功！"
            else
                echo_red "文件上传失败，请重新上传！"
            fi
        else
            echo_red "文件check不成功，请重新上传！"
        fi
    else
        echo_red "上传失败，请重新上传！"
    fi
}

root_dir="/home/work/.web_server/data"
dateTime=`date +%s`
logName="httpfileserver_${dateTime}.log"

# 记录当前path
work_path=`pwd`

# 启动
cd ${root_dir}
nohup SimpleHTTPServerWithUpload.py >../log/${logName} 2>&1 &
pid=`ps -ef|grep SimpleHTTPServerWithUpload.py|grep -v grep|awk '{print $2}'`
echo_red "进程pid：$pid"
echo ""

# 异常捕获
trap "kill $pid;echo_red '异常退出';exit -1" 1 2

# 处理
process ${work_path} ${pid}

# 关闭
kill $pid

cd - > /dev/null
