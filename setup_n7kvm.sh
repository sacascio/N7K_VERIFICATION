#!/bin/sh

# Prework fix
cd output/N7K_PREWORK/
for j in `ls dc*outer*`
do
echo Fixing $j
sed -i.bak 's/Ethernet5/Ethernet2/g' $j
sed -i.bak 's/Ethernet2\/25/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/26/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/27/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/28/Ethernet2\/6/g' $j
rm $j.bak
done

for j in `ls dc*inner*`
do
echo Fixing $j
sed -i.bak 's/Ethernet2\/15/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/16/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/17/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/18/Ethernet2\/6/g' $j
rm $j.bak
done
cd ../..

# Cut over fix
cd output/N7K_CUTOVER/
for i in `ls -d */ `
do
cd $i
for j in `ls dc*outer*`
do
sed -i.bak 's/Ethernet5/Ethernet2/g' $j
sed -i.bak 's/Ethernet2\/25/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/26/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/27/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/28/Ethernet2\/6/g' $j
rm $j.bak
done

for j in `ls dc*inner*`
do
echo Fixing $j
sed -i.bak 's/Ethernet2\/15/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/16/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/17/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/18/Ethernet2\/6/g' $j
rm $j.bak
done

cd ..
done
cd ../..

# Cleanup fix
cd output/N7K_NEXT_CLEANUP/
for i in `ls -d  */ `
do
cd $i
for j in `ls dc*outer*`
do
sed -i.bak 's/Ethernet5/Ethernet2/g' $j
sed -i.bak 's/Ethernet2\/25/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/26/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/27/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/28/Ethernet2\/6/g' $j
sed -i.bak 's/Ethernet2\/6/Ethernet2\/9/g' $j
sed -i.bak 's/Ethernet2\/14/Ethernet2\/10/g' $j
rm $j.bak
done

for j in `ls dc*inner*`
do
echo Fixing $j
sed -i.bak 's/Ethernet2\/15/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/16/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/17/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/18/Ethernet2\/6/g' $j
sed -i.bak 's/Ethernet2\/29/Ethernet2\/9/g' $j
sed -i.bak 's/Ethernet2\/30/Ethernet2\/10/g' $j
rm $j.bak
done

cd ..
done
pwd
cd ../..

# Rollback Cleanup fix
cd output/N7K_NEXT_CLEANUP_ROLLBACK/
for i in `ls -d  */ `
do
cd $i
for j in `ls dc*outer*`
do
sed -i.bak 's/Ethernet5/Ethernet3/g' $j
sed -i.bak 's/Ethernet2/Ethernet3/g' $j
sed -i.bak 's/Ethernet2\/25/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/26/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/27/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/28/Ethernet2\/6/g' $j
rm $j.bak
done

for j in `ls dc*inner*`
do
echo Fixing $j
sed -i.bak 's/Ethernet2/Ethernet4/g' $j
sed -i.bak 's/Ethernet2\/15/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/16/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/17/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/18/Ethernet2\/6/g' $j
rm $j.bak
done

cd ..
done
pwd
cd ../..

# Rollback
cd output/N7K_ROLLBACK/
for i in `ls -d  */ `
do
cd $i
for j in `ls dc*outer*`
do
sed -i.bak 's/Ethernet5/Ethernet2/g' $j
sed -i.bak 's/Ethernet2\/25/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/26/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/27/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/28/Ethernet2\/6/g' $j
rm $j.bak
done

for j in `ls dc*inner*`
do
echo Fixing $j
sed -i.bak 's/Ethernet2\/15/Ethernet2\/3/g' $j
sed -i.bak 's/Ethernet2\/16/Ethernet2\/4/g' $j
sed -i.bak 's/Ethernet2\/17/Ethernet2\/5/g' $j
sed -i.bak 's/Ethernet2\/18/Ethernet2\/6/g' $j
rm $j.bak
done

cd ..
done
pwd
cd ../..
exit
# Push N7K initial configs
echo 'pushing inner1'
./push_to_n7k.py -f inner1 -c inner1_creds
cat inner1_creds > output/dc1dcinxc1soeinner_creds
 
echo 'pushing inner2'
./push_to_n7k.py -f inner2 -c inner2_creds
cat inner2_creds > output/dc1dcinxc2soeinner_creds

echo 'pushing inner3'
./push_to_n7k.py -f inner3 -c inner3_creds
cat inner3_creds > output/dc1dcinxc3soeinner_creds

echo 'pushing inner4'
./push_to_n7k.py -f inner4 -c inner4_creds
cat inner4_creds > output/dc1dcinxc4soeinner_creds

echo 'pushing outer1'
./push_to_n7k.py -f outer1 -c outer1_creds
cat outer1_creds > output/dc1dcinxc1dciouter_creds

echo 'pushing outer2'
./push_to_n7k.py -f outer2 -c outer2_creds
cat outer2_creds > output/dc1dcinxc2dciouter_creds

echo 'pushing outer3'
./push_to_n7k.py -f outer3 -c outer3_creds
cat outer3_creds > output/dc1dcinxc3dciouter_creds

echo 'pushing outer4'
./push_to_n7k.py -f outer4 -c outer4_creds
cat outer4_creds > output/dc1dcinxc4dciouter_creds

