#!/bin/bash

# Turn each filename 'card-a-b.png' into 'c.png', where c = 4*a + b - 1, so c
# ranges from 0 to 80 inclusive.

cards_dir="../images/cards"
for filename in $(ls $cards_dir); do
    IFS='-' read blah a end <<< $filename
    IFS='.' read b blah <<< $end
    c=$((4*a+b-1))
    mv $cards_dir/$filename $cards_dir/$c".png"
done


# Remove the last three pngs, which are blank.
rm $cards_dir/81.png $cards_dir/82.png $cards_dir/83.png
