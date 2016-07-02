#!/bin/bash

photo_source=~/Pictures/Foton/upload
photo_temp=~/.phototemp/
photo_dest=~/Pictures/Foton

mkdir -p $photo_temp
mkdir -p $photo_dest

echo $photo_source

function copy_iphone {
    find $photo_source/$1/. -type f ! -executable \( -name "*.JPG" -o -name "*.MOV" \) | while read line
    do
	if cp -p "$line" $photo_temp
	then chmod +x "$line"
	else exit $?
	fi
    done
}

function move_generic {
    find $photo_source/$1/. -type f \( -name "*.JPG" -o -name "*.MOV" -o -name "*.MTS" \) | while read line
    do
	mv "$line" $photo_temp
    done
}

echo "Copying from dags_iphone"
copy_iphone "dags_iphone"
echo "Copying from idas_iphone"
copy_iphone "idas_iphone"
echo "Copying from idas_iphone6"
copy_iphone "idas_iphone6"

echo "Moving from sdcard"
move_generic "sdcard"

chown -R :www-data $photo_temp

echo "Moving files to proper locations"
exiftool -r -v3 -P -d "$photo_dest/%Y/%m.%B/img_%Y-%m-%d_%H.%M.%S" -ext JPG '-filename<${Exif:CreateDate}_$Make.$Model%-c.%le' "$photo_temp"
exiftool -r -v3 -P -d "$photo_dest/%Y/%m.%B/mov_%Y-%m-%d_%H.%M.%S" -ext MOV '-filename<${QuickTime:CreateDate}_${QuickTime:Make-swe}.${QuickTime:Model-swe}%-c.%le' "$photo_temp"
exiftool -r -v3 -P -d "$photo_dest/%Y/%m.%B/img_%Y-%m-%d_%H.%M.%S%%-c.%%le" -ext JPG '-filename<FileModifyDate' "$photo_temp"
exiftool -r -v3 -P -d "$photo_dest/%Y/%m.%B/mov_%Y-%m-%d_%H.%M.%S%%-c.%%le" -ext MTS -ext MOV '-filename<FileModifyDate' "$photo_temp"


