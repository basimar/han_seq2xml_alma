#!/bin/bash

# MARC-Felder sortieren
cp dsv05_new.seq dsv05_new_sorted.seq
sed -i 's/^\(.\{10\}\)FMT/\1001/g' dsv05_new_sorted.seq
sed -i 's/^\(.\{10\}\)LDR/\1002/g' dsv05_new_sorted.seq

sort -n -s  -k1 -k2.1,2.4 dsv05_new_sorted.seq > dsv05_new_sorted.seq2 

sed -i 's/^\(.\{10\}\)001/\1FMT/g' dsv05_new_sorted.seq2
sed -i 's/^\(.\{10\}\)002/\1LDR/g' dsv05_new_sorted.seq2

cp dsv05_new_sorted.seq2 dsv05_new_sorted.seq


# Daten aufteilen
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_ubs.fix < dsv05_new_sorted.seq > dsv05_ubs.xml
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_rzs.fix < dsv05_new_sorted.seq > dsv05_rzs.xml
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_ube.fix < dsv05_new_sorted.seq > dsv05_ube.xml
#Gosteli-Archiv migriert Archivdaten nicht zu SLSP
#catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_rbe.fix < dsv05_new_sorted.seq > dsv05_rbe.xml
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_zbs.fix < dsv05_new_sorted.seq > dsv05_zbs.xml
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_a117.fix < dsv05_new_sorted.seq > dsv05_a117.xml
catmandu convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix split_data_rest.fix < dsv05_new_sorted.seq > dsv05_rest.xml

catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_ubs.xml > dsv05_ubs_items.xml
catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_ubs.xml > dsv05_ubs_holdings.xml

catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_rzs.xml > dsv05_rzs_items.xml
catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_rzs.xml > dsv05_rzs_holdings.xml

catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_ube.xml > dsv05_ube_items.xml
catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_ube.xml > dsv05_ube_holdings.xml

#catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_rbe.xml > dsv05_rbe_items.xml
#catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_rbe.xml > dsv05_rbe_holdings.xml

catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_zbs.xml > dsv05_zbs_items.xml
catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_zbs.xml > dsv05_zbs_holdings.xml

# Bernoulli-Bibligraphie-Aufnahmen: Nur Holding generieren
cp dsv05_a117.xml dsv05_a117_holdings.xml
#catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_items.fix < dsv05_a117.xml > dsv05_a117_items.xml
#catmandu convert MARC --type XML to MARC --type XML --pretty 1 --fix split_data_holdings.fix < dsv05_a117.xml > dsv05_a117_holdings.xml
exit 0
