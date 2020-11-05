#!/bin/sh

get_bgp_neighbors() {

echo "! NEW BGP NEIGHBORS FOR VRF $3"
for i in `grep -iw neighbor output/N7K_PREWORK/$1dcinxc$2dciouter_$3|awk ' { print $2 } '`
do
grep -w $i x
done   
echo

echo "! OLD BGP NEIGHBORS FOR VRF $3"
dir=`ls -d output/N7K_CUTOVER/*|grep $3|grep -v exe|sed "s/output\/N7K_CUTOVER//g"`
for i in `grep -iw neighbor output/N7K_CUTOVER/$dir/$1dcinxc$2dciouter|awk ' { print $2 } '`
do
grep -w $i x
done  
echo 
}

if [ "$#" -ne 4 ]; then
echo "Usage: $0 VRF inner_svi outer_svi dc"
echo "Example CTL-PA0 26 104 dc1"
exit
fi

vrf=$1
i_svi=$2
o_svi=$3
dc=$4

dc=`echo $dc | tr '[:upper:]' '[:lower:]'`

echo "show ip int br vrf $vrf" > inner_check
echo "show ip bgp summary vrf $vrf" >> inner_check

echo "dc1dcinxc1soeinner"
echo
./check_output.py -c inner1_creds -f inner_check

echo "dc1dcinxc2soeinner"
echo
./check_output.py -c inner2_creds -f inner_check

echo "dc1dcinxc3soeinner"
echo
./check_output.py -c inner3_creds -f inner_check

echo "dc1dcinxc4soeinner"
echo
./check_output.py -c inner4_creds -f inner_check


# Prepare outer VDC check
echo "sh ip int br | inc $o_svi" > outer_check
echo "sh ip int br | inc Eth2/[3-6].$i_svi" >> outer_check
echo "sh ip bgp summary" > bgp_check

echo "dc1dcinxc1dciouter"
echo
./check_output.py -c outer1_creds -f outer_check
./check_output.py -c outer1_creds -f bgp_check > x
get_bgp_neighbors $dc 1 $vrf

echo "dc1dcinxc2dciouter"
echo
./check_output.py -c outer2_creds -f outer_check
./check_output.py -c outer2_creds -f bgp_check > x
get_bgp_neighbors $dc 2 $vrf

echo "dc1dcinxc3dciouter"
echo 
./check_output.py -c outer3_creds -f outer_check
./check_output.py -c outer3_creds -f bgp_check > x
get_bgp_neighbors $dc 3 $vrf

echo "dc1dcinxc4dciouter"
echo
./check_output.py -c outer4_creds -f outer_check
./check_output.py -c outer4_creds -f bgp_check > x
get_bgp_neighbors $dc 4 $vrf

rm inner_check
rm outer_check
rm x
rm bgp_check
