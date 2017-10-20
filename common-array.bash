#!/usr/bin/env bash

#usage: array_contains array[*] word
#array=(a b c)
#array_contains array[*] c
#echo $?     # output: 0
fn_array_contains(){
  local -a _array=("${!1}")
  local _value=$2;

  # echo "array[${#_array[*]}] ( ${_array[*]} ) contains $_value"
  for i in "${_array[@]}" ;
  do
    [[ "$i" == "$_value" ]] &&  return 0 ;
  done
  return 1;
}

fn_array_max_string_length(){
  declare -a _argArray=("${!1}")

  local _max_length=0;
  for i in ${_argArray[@]}; do
    local _length=${#i};
    _max_length=`((_length>_max_length)) && echo $_length || echo $_max_length `
    # _max_length＝$((length>max_length?length:max_length))
    # if ((length>max_length)); then max_length=$length ; fi
  done
  echo $_max_length
}

fn_array_check_contains(){
  declare -a _array=("${!1}")
  local _value=$2;
  # 这里不能利用fn_array_contains，bash 的数组貌似不能传递多次
  for i in "${_array[@]}" ;
  do
    [[ "$i" == "$_value" ]] &&  return 0
  done
  fn_assert_fail "value'$_value'无效，有效值为(${_array[@]})"
}
