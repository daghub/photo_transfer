#!/bin/bash

photo_source=/home/htpc/Pictures/upload
photo_temp=/home/htpc/.phototemp/
photo_dest="/home/htpc/Pictures/Foton"
photo_dest_olivia="/home/htpc/Pictures/OliviasFoton"
photo_dest_malte="/home/htpc/Pictures/MaltesFoton"
exif_tool=exiftool
mkdir -p $photo_temp

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

function copy_android {
    find $photo_source/$1/. -type f ! -executable \( -name "*.jpg" -o -name "*.mp4" \) | while read line
    do
            if cp -p "$line" $photo_temp
              then chmod +x "$line"
              else exit $?
            fi
    done
}

function move_generic {
    find $photo_source/$1/. -type f \( -name "*.AVI" -o -name "*.JPG" -o -name "*.MOV" -o -name "*.MTS" \) | while read line
    do
	    mv "$line" $photo_temp
    done
}

function move_to_dest {
    echo Moving files to proper locations "$1"
    mkdir -p $1
    chown -R :www-data $photo_temp
    $exif_tool -r -v3 -P -d "$1/%Y/%m.%B/img_%Y-%m-%d_%H.%M.%S" -ext JPG -ext jpg '-filename<${Exif:CreateDate}_$Make.$Model%-c.%le' "$photo_temp"
    $exif_tool -r -v3 -P -d "$1/%Y/%m.%B/mov_%Y-%m-%d_%H.%M.%S" -ext MOV -ext mov -ext mp4 '-filename<${QuickTime:CreateDate}_${QuickTime:Make-swe}.${QuickTime:Model-swe}%-c.%le' "$photo_temp"
    $exif_tool -r -v3 -P -d "$1/%Y/%m.%B/img_%Y-%m-%d_%H.%M.%S%%-c.%%le" -ext JPG '-filename<FileModifyDate' "$photo_temp"
    # catch all for movie clips
    $exif_tool -r -v3 -P -d "$1/%Y/%m.%B/mov_%Y-%m-%d_%H.%M.%S%%-c.%%le" -ext MTS -ext MOV -ext mp4 -ext avi -ext AVI '-filename<FileModifyDate' "$photo_temp"
}

echo "Copying from dags_iphone"
copy_iphone "dags_iphone"
echo "Copying from dags_android"
copy_android "dags_android"
echo "Copying from idas_iphone"
copy_iphone "idas_iphone"

echo "Moving from sdcard"
move_generic "sdcard"

move_to_dest $photo_dest

echo "Moving from olivia"
move_generic "olivia"
echo "Copying from olivias_iphone"
copy_iphone "olivias_iphone"

move_to_dest $photo_dest_olivia

echo "Moving from malte"
move_generic "malte"

move_to_dest $photo_dest_malte



