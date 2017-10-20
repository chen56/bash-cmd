#!/usr/bin/env bash

##############################################################################
##
##  common script for UN*X
##
##############################################################################

fn_ensure_dir(){
  local _path=$1;

  ! [[ -f $_path ]] || fn_assert_fail "您期望为目录的路径存在一个普通文件: '$_path'"

  # 此路径若存在，就不再创建了
  if [[ -e $_path ]]; then
    return 0
  fi
  # 是否要判断目录权限，有时候没权限创建不了？
  mkdir -p "$_path"
}

fn_eval_text_file() (
  local _file=$1
  local _default=$2

  if ! [[ -r $_file ]]; then
    echo "$_default"
    return 0;
  fi

  # 需要这样设置IFS吗
  OLD_IFS=${IFS}
  IFS=""       # make newlines the only separator
  for line in `cat $_file`
  do
    eval "echo \"$line\" "
  done
  IFS=${OLD_IFS}
)


# Usage: fn_resovle_path [OPTIONS] <path>
#
# 解析一个路径.
#
# Options:
#   -a      把参数<path>解析为绝对路径
#   -l      若参数<path>为软链接，则递归解析为实际路径
#
# Example:
#   - 获取"./script.bash"的绝对路径
#   fn_resovle_path -a "./script.bash"
#
#   - 获取"./script.bash"的绝对路径，如果其为软链接，也解析其实际路径
#   fn_resovle_path -a -l "./script.bash"
function fn_resovle_path(){
  local _absolute=false
  local _readlink=false
  OPTIND=1
  while getopts "al"  opt; do
    case "$opt" in
      a)              _absolute_path=true;;
      l)              _readlink=true;;
    esac
  done
  shift $((OPTIND-1))

  local _path=$1
  [[ $_path != "" ]]  || fn_assert_fail "fn_resovle_path need a path arg : fn_resovle_path [OPTIONS] <path> "


  if [[ $_readlink == "true" ]];then
    while [ -h "$_path" ] ; do
        ls=`ls -ld "$_path"`
        link=`expr "$ls" : '.*-> \(.*\)$'`
        if expr "$link" : '/.*' > /dev/null; then
            _path="$link"
        else
            _path=`dirname "$_path"`"/$link"
        fi
    done
  fi
  if [[ _absolute == "true" ]];then
    _path=$( cd `dirname $_path` ; pwd -P )/"`basename $_path`"
  fi
  echo $_path
}
