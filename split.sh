#!/bin/bash

for i in {001..999}
do 
 grep -P "^.{10}$i" dsv05_new.seq > ./split/dsv05_new.$i.seq
done

grep -P '^.{10}LDR' dsv05_new.seq > ./split/dsv05_new.ldr.seq
