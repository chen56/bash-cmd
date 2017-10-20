#!/usr/bin/env bash

function fn_task_current_init(){
  APP_TASK_CURRENT_DIR=$1
  APP_TASK_CURRENT_NAME=$2
  APP_TASK_CURRENT_CHILDREN=(`ls -F "$APP_TASK_CURRENT_DIR" | grep /$ | grep -v ^_ | sed 's/\///g' `)
}

function fn_task_run(){
  if (( $# == 0)) ; then
    fn_help && exit 0;
  fi

  local _task=$1

  
  _fn_task_contains $_task || fn_validate_fail "task'$_task'不存在, 查看帮助: ccc -h ";


  local _task_dir=${APP_TASK_CURRENT_DIR}/$_task
  local _task_script="${_task_dir}/task.sh";
  shift #remove current task
  fn_task_current_init "${_task_dir}" "$_task"

  # 只有任务目录，但没定义脚本
  # 帮他一把，给个默认行为
  if [[ ! -f $_task_script ]] ; then
    # 取option
    OPTIND=1
    while getopts "hx"  opt; do
    case "$opt" in
      h)                        fn_help; exit 0;;
      ?)                        fn_stack
                                exit 1
                                ;;
    esac
    done
    shift $((OPTIND-1))

    fn_task_run $@
    return 0
  fi

  . $_task_script $@


}

function _fn_task_contains(){
  fn_array_contains APP_TASK_CURRENT_CHILDREN[@] $1 && true # && true预防set -o errexit
}


fn_help(){
  _fn_subtasks_list(){
    # 先求任务名最长字符串的长度
    local _task_name_max_length=0;
    local i="";
    for i in ${APP_TASK_CURRENT_CHILDREN[*]}; do
      local str_length=${#i};
      if ((str_length>_task_name_max_length)); then _task_name_max_length=$str_length ; fi
    done

    for i in ${APP_TASK_CURRENT_CHILDREN[*]}; do
      local _desc_file="${APP_TASK_CURRENT_DIR}/$i/desc.txt"
      local _desc=`fn_eval_text_file $_desc_file "..."`
      printf "  %-${_task_name_max_length}s  %s \n"  "$i" "$_desc"
    done
  }
  _current_task_info=`fn_eval_text_file "${APP_TASK_CURRENT_DIR}/help.txt"`
  _current_subtasks_info=`_fn_subtasks_list`

  echo "$_current_task_info"
  if [[ $_current_subtasks_info ]]; then
    echo "
Subtasks:
$_current_subtasks_info
"
  fi
}
