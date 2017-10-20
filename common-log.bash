#!/usr/bin/env bash

##############################################################################
##
##  common script for UN*X
##
##############################################################################
# 公共枚举定义
APP_LOG_ENV=false
APP_LOG_STACKTRACE=false
# APP_LOG_LEVELS=(debug info warn error)
declare -A APP_LOG_LEVELS=([debug]=10 [info]=20 [warn]=30 [error]=40)
APP_LOG_LEVEL=info

fn_debug(){
  _level=${APP_LOG_LEVELS[$APP_LOG_LEVEL]}
  _debug=${APP_LOG_LEVELS[debug]}
  if (( _level <= _debug )) ; then
   echo -e "DEBUG - task(${APP_TASK_CURRENT_NAME}) - $*"
  fi
}

fn_info(){
  _level=${APP_LOG_LEVELS[$APP_LOG_LEVEL]}
  _info=${APP_LOG_LEVELS[info]}
  if (( _level <= _info )) ; then
    echo -e "INFO  - task(${APP_TASK_CURRENT_NAME}) - $*"
  fi
}

fn_warn(){
  _level=${APP_LOG_LEVELS[$APP_LOG_LEVEL]}
  _warn=${APP_LOG_LEVELS[warn]}
  if (( _level <= _info )) ; then
    echo -e "WARN  - task(${APP_TASK_CURRENT_NAME}) - $*"
  fi
}

fn_error(){
  _level=${APP_LOG_LEVELS[$APP_LOG_LEVEL]}
  _error=${APP_LOG_LEVELS[error]}
  if (( _level <= _error )) ; then
    echo -e "ERROR - task(${APP_TASK_CURRENT_NAME}) - $*" >&2
  fi
}


fn_trap_on_err() {
  fn_error "traped an error: ↑ , trace: ↓"
  fn_stack
}

fn_log_app_env_info(){
	cat <<- "EOF"
	"#############################
	# app env info
	##############################
	EOF
	set | grep "^APP_"
	echo ""
}

fn_validate_log_level(){
    local _level=$1
    if [[ "${APP_LOG_LEVELS[$_level]}" == "" ]] ; then
        fn_validate_fail "'$_level' 不是有效的logging level，有效值为: ${APP_LOG_LEVELS[@]}";
    fi
}

fn_stack () {
  # if [[ $APP_LOG_STACKTRACE != "true" ]]; then
  #   return 0
  # fi

  local i=0
  local errout
  #  while caller $i >&2
  #  do
  #     i=$((i+1))
  #  done
   while true
   do
      errout=$(caller $i 2>&1 && true) && true
      if [[ $? != 0 ]]; then break ; fi
      echo "  $errout" >&2

      i=$((i+1))
   done
}
