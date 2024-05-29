#/bin/bash
# get the GISS Surface Temperature Analysis (GISTEMP) data
# seanvw@gmail.com
stem="GLB.Ts+dSST"

csv_file="$stem"".csv" 
tsv_file="$stem"".tsv" 

format="tabledata_v4"
url="https://data.giss.nasa.gov/gistemp/$format/$csv_file"
current_date_time=$(date +%Y-%m-%d_%H-%M)
save_as_csv="$current_date_time"_"$format"_"$csv_file"
save_as_tsv="$current_date_time"_"$format"_"$tsv_file"

echo "Fetching url: $url"
echo "Saving as file: $save_as_csv"

wget $url -O $save_as_csv

perl -ne 's|,|\t|g; s|\*\*\*||g; print if $. != 1' $save_as_csv > $save_as_tsv

echo "Changing download with perl: $save_as_tsv"

echo "Done. See yah :)"






