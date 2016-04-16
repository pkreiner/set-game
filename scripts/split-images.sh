#!/bin/bash

for i in `seq 0 20`; do
    input="../images/pages/pages-$i.png"
    output_base="../images/cards"
    output1=$output_base"/card-$i-1.png"
    output2=$output_base"/card-$i-2.png"
    output3=$output_base"/card-$i-3.png"
    output4=$output_base"/card-$i-4.png"
    
    convert $input -crop 296x421+0+0 $output1
    convert $input -crop 296x421+297+0 $output2
    convert $input -crop 296x421+0+422 $output3
    convert $input -crop 296x421+297+422 $output4
done    
