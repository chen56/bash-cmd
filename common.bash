#!/usr/bin/env bash

##############################################################################
##
##  common script for UN*X
##
##############################################################################
# 公共枚举定义
APP_ENUM_ENABLES=(enable disable)
APP_ENUM_BOOLEANS=(true false)
APP_CONFIG_DIR="$HOME/.ccc"

# 打印断言失败，并退出
# assert_fail: 表示断言失败，视为bug，例如：
#    - 一个除法函数，不接受为零的除数，这是契约，违约传入为零的除数，即视为调用者违约bug
#    - 一个加法函数'plus'，期望其能处理负数，即调用'plus 2 -3'希望得到'-1',调用后，做一个check，希望结果为'-1',如果得不到，则视为bug
# assert 和 validate 的区别是，check是bug检查，出错即认为出现故障，而validate出错退出，只是用户输入或环境不适配的检查，不是bug
fn_assert_fail() {
  fn_error "🆘  - $*"
  fn_stack
  exit 1
}

# 打印业务失败，并退出
# validate_fail: 表示验证失败，不视为故障或bug，例如：
#    - 程序需要bash4，检查不满足后退出。
#    - 比如一个录入用户个人信息的程序，要求姓名长度不能超过20个字符，如果超过则提示退出。
# check 和 validate 的区别是，check是bug检查，出错即认为出现故障，而validate出错退出，只是用户输入或环境不适配的检查，不是bug
fn_validate_fail() {
  fn_error "🔞  - $*"
  fn_stack
  exit 2
}

# 打印系统失败，并退出
# system_fail: 表示系统失败，属于不可预料的系统故障，不视为bug，和环境有关，例如：
#    - 数据库连接中断。
# check 和 validate 的区别是，check是bug检查，出错即认为出现故障，而validate出错退出，只是用户输入或环境不适配的检查，不是bug
fn_system_fail() {
  fn_error "❓  - $*"
  fn_stack
  exit 2
}

# TODO deprecated fn_run,remove later
fn_run(){
  fn_info "▶︎ ◼︎ $@"
  eval "$@"
}

fn_run_with_progress(){
  local start=`date +%s `
  fn_info "▶︎   $*"
  $*
  local end=`date +%s `
  local elapsed=$(( end - start ))
  fn_info "◼︎   $* --- elapsed ${elapsed}s"
}

# 实验特性，可以配置一些参数，覆盖掉某些值？这样，可以不修改主代码，既可以加入一些行为。
fn_config_init(){
  [[ ! "$APP_NAME" == "" ]] || fn_assert_fail "未指定APP_NAME"
  mkdir -p "$APP_CONFIG_DIR"
  local _config="$APP_CONFIG_DIR/$APP_NAME.config"
  if [[ ! -f "$_config" ]]; then
      fn_info "init $_config"
      echo "# config you app like .bash_profile " > "$_config"
  else 
      fn_debug "read $_config"
      . "$_config"
  fi
}

# trap DEBUG信号，以输出执行的是什么命令,类似 `set -x`，不过定制了打印内容
# 用在subshell里，打印特别重要的命令，范例：
# ```bash
# #/bin/bash
# (
#   fn_trap_show
#   rm -rf build
# )
fn_verbose_on(){
    trap 'fn_info "▶︎ ◼︎ $BASH_COMMAND"' DEBUG
}

# usage:  getopts_long short_optstring long_optstring name <args>
#
# getopts_long behaviour same as getopts , except add long options.
#
# long_opt_string example: "long_opt1,long_opt2:,long_opt3".
#                                              ^
# if long option require a argument, ends with a ":".
#
#
# copy from : help getopts:
# ------------------------------------------------------------------
# getopts reports errors in one of two ways.  If the first character
# of OPTSTRING is a colon, getopts uses silent error reporting.  In
# this mode, no error messages are printed.  If an invalid option is
# seen, getopts places the option character found into OPTARG.  If a
# required argument is not found, getopts places a ':' into NAME and
# sets OPTARG to the option character found.  If getopts is not in
# silent mode, and an invalid option is seen, getopts places '?' into
# NAME and unsets OPTARG.  If a required argument is not found, a '?'
# is placed in NAME, OPTARG is unset, and a diagnostic message is
# printed.
#
# If the shell variable OPTERR has the value 0, getopts disables the
# printing of error messages, even if the first character of
# OPTSTRING is not a colon.  OPTERR has the value 1 by default.
getopts_long(){
  local _short=$1
  local _long=$2
  local _opt_name=$3
  # echo "{ getopts_long -- OPTIND=$OPTIND  '$_short'  '$_long' '$_opt_name' $*"
  set -f    # avoid globbing (expansion of *).
  local _long_array=(${_long//,/ })
  # echo "parsed long opt array:  ${#_long_array[*]} - (${_long_array[*]})"
  set +f

  getopts "$_short" "$_opt_name" $* || return 1;

  echo "after getopts -- $_opt_name:${!_opt_name}, OPTARG=$OPTARG OPTIND:$OPTIND"

  # if short then return
  ! [[ "${!_opt_name}" == "-" ]] && return 0;

  # not contains long-opt and not contains long-opt:
  if ! { array_contains _long_array[@] "${!_opt_name}" ||
         array_contains _long_array[@] "${!_opt_name}:"; } ; then

    eval "$_opt_name=?";
    unset OPTARG;
    echo "invild option $? -- ${!_opt_name}";
  fi
  # echo "} getopts_long -- $_opt_name:${!_opt_name}, OPTARG=$OPTARG"
}
