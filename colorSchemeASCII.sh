#!/usr/bin/bash
#
# ANSI color scheme script featuring Space Invaders
#
# Original: http://crunchbang.org/forums/viewtopic.php?pid=126921%23p126921#p126921
# Modified by lolilolicon
#

f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
bld=$'\e[1m'
rst=$'\e[0m'

cat << EOF
$f1★ $f2° $f3. $f7*　　　$f6°　$f4.　$f3°☆ 　$f1. $f6* $f5● $f3¸ $rst
$f3. 　　　$f6★ 　$f2° $f6:. $f5★  　 $f2* $f7• $f5○ $f2° $f1★  　$rst
$f1.　$f3* 　$f5.　$f7. $f5★  　 $f2* $f7•  　 $f2° $f3. $f7* $rst
$f7° 　$f3. $f1● $f5. $f6★ $f7° $f1. $f6*　$f5°　$f2.　°$f7☆ $rst 
$f2　. $f1* $f5● $f7¸ $f1. 　　　$f4★ 　$f5° $f7:$f2●$f1. 　 $f6* $rst
$f4• $f7○ $f6° $f5★  $f4.　 $f3* 　$f2.　 　　　　　$f1.	$rst
 　 $f1° 　$f6. $f3● $f4. $f2★ $f1° $f7. $f6*　　　$f4°　$f2.　$rst
$f2°$f2☆ 　$f1. $f6* $f7● $f3¸ $f4. 　　　$f5★ 　	$rst
$f2° $f7:$f6. 　 $f3* $f6• $f5○ $f4° $f1★  　 $f3.　 $f2* 　.　 $rst
　$f2★  　　　　$f4. 　 $f4° 　$f6.  $f5. 　    $f7★  　$rst 　　
$f1° $f2°$f5☆ 　$f4¸$f7. $f6● $f5. 　　$f4★  　$f3★ 		$rs
$f3° $f4. $f5*　　　$f6°　$f3.　$f2°$f1☆ 　$f2. $f3* $f4● $f5¸ $f2. $rst
$f6★ $f1° $f2. $f5*　　　$f1°　$f4.　$f3°$f5☆ 　$f1. $f3* $f2● $f5¸ $rst
$f3. 　　　$f1★ 　$f5° $f3:$f4. 　 $f1* $f5• $f4○ $f5° $f4★  　 $rst
$f4.　 $f6* 　$f7.　 　$f5★    $f1 ° $f3:$f6.$f5☆  $rst


EOF
