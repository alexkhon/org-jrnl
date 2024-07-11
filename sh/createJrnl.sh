#!/bin/zsh
################################################################################
# createJrnl.sh YYYY-mm
#
# Creates my interstitial journal files for the specified month
# - creates the month as a subdir in current dir (i.e., you can create in tmp)
# - for each file, if not exist, create file with header
#
# Notes:
# - The date parameters maybe OSX Specific
################################################################################
source ./colors.inc.sh

clear
echo -e "${Blue}#################################################################${NC}"
echo -e "${Blue}$0${NC}"
echo -e "${Blue}Create new journal pages for an entire month${NC}"
echo -e "${Blue}#################################################################${NC}"


# Split by delimiter into array
INPUT="2024-07"

arrIN=("${(@s/-/)INPUT}")
YR=${arrIN[1]}
MO=${arrIN[2]}

echo "YEAR     :" $YR
echo "MONTH    :" $MO

# Getting the last day of the month
# https://unix.stackexchange.com/questions/223543/get-the-date-of-last-months-last-day-in-a-shell-script
if [[ "$MO" = "12" ]]
then
    ((NEXT_YEAR = $YR + 1))
    ((NEXT_MONTH = 1))
    LAST_DAY=$(date -v${NEXT_YEAR}y -v${NEXT_MONTH}m -v1d -v-1d +%d)
    echo "LAST DAY :" $LAST_DAY " " $(date -v${NEXT_YEAR}y -v${NEXT_MONTH}m -v1d -v-1d +%Y-%m-%d)
else
    ((NEXT_MONTH = $MO + 1))
    LAST_DAY=$(date -v${YR}y -v${NEXT_MONTH}m -v1d -v-1d +%d)
    echo "LAST DAY :" $LAST_DAY " " $(date -v${YR}y -v${NEXT_MONTH}m -v1d -v-1d +%Y-%m-%d)
fi



echo "-----------------------------------------------------------------"

# Default journal location
JRNL="/Users/alex/Dropbox/Journal/${YR}/${YR}-${MO}"

# Safe output location is the current directory
# NEVER give it the same name as the actual journal directory
OUTPUT_DIR="./${YR}-${MO}-TEMP"

if [[ -d "$OUTPUT_DIR" ]]
then
    echo "Output dir ${OUTPUT_DIR} - Exists"
    vared -c -p "Clobber and re-create? [y/N] " response
else
    echo "Output dir ${OUTPUT_DIR} - Does not exist"
    vared -c -p "Create? [y/N] " response
fi

# Last chance to abort
typeset -l ${response}     # tolower in zsh

if [[ ! "$response" =~ ^(yes|y)$ ]]
then
    echo -e "${Red}abort${NC}"
    exit
fi

# Force deletion of existing output directory and recreate
echo "rm -rf ${OUTPUT_DIR}"
echo "mkdir ${OUTPUT_DIR}"

rm -rf ${OUTPUT_DIR}
mkdir  ${OUTPUT_DIR}

# Create org-mode header info
EMAIL="#+EMAIL:     alex.k.hon@outlook.com"
AUTHOR="#+AUTHOR:    Alex K. Hon"
OPTIONS="#+OPTIONS:   ^:{}"
JOURNAL="#+PROPERTY:  journal :version 1.0.0"
STARTUP="#+STARTUP:   overview"
LINE_TODO="* COMMENT -----------------------------------------------------------------TODO"
LINE_JRNL="* COMMENT -----------------------------------------------------------------JRNL"
LINE_NOTE="* COMMENT -----------------------------------------------------------------NOTE"

# Does the journal already exist?
# If no create all the files, else check for existing files before creating
if [ ! -d "$JRNL" ]; then

    # Loop thorugh the days
    # https://stackoverflow.com/questions/28226229/how-to-loop-through-dates-using-bash
    # https://stackoverflow.com/questions/18460123/how-to-add-leading-zeros-for-for-loop-in-shell
    echo "-----------------------------------------------------------------"
    echo "Journal ${JRNL} - Does not exist"
    echo "-- creating the entire month"
    echo "-----------------------------------------------------------------"

    for i in {01..$LAST_DAY}
    do
        CURRENT_DATE="$YR-$MO-$i"
        DAY=$(date -j -f '%Y-%m-%d' ${CURRENT_DATE} +'%a')
        JRNL_FILE="$CURRENT_DATE.$DAY.jrnl.org"

        # Create file and title
        echo -e "${Green}$JRNL_FILE${NC} [CREATED]"
        touch $OUTPUT_DIR/$JRNL_FILE
        TITLE="#+TITLE:     ${JRNL_FILE}"

        # echo header into file
        echo $TITLE   >> $OUTPUT_DIR/$JRNL_FILE
        echo $EMAIL   >> $OUTPUT_DIR/$JRNL_FILE
        echo $AUTHOR  >> $OUTPUT_DIR/$JRNL_FILE
        echo $OPTIONS >> $OUTPUT_DIR/$JRNL_FILE
	echo $JOURNAL >> $OUTPUT_DIR/$JRNL_FILE
        echo $STARTUP >> $OUTPUT_DIR/$JRNL_FILE
        echo $LINE_TODO >> $OUTPUT_DIR/$JRNL_FILE
	echo $LINE_JRNL >> $OUTPUT_DIR/$JRNL_FILE
	echo $LINE_NOTE >> $OUTPUT_DIR/$JRNL_FILE

    done
else
    echo "-----------------------------------------------------------------"
    echo "Journal ${JRNL} - Exists"
    echo "-- creating only the missing days"
    echo "-----------------------------------------------------------------"

    for i in {01..$LAST_DAY}
    do
        CURRENT_DATE="$YR-$MO-$i"
        DAY=$(date -j -f '%Y-%m-%d' ${CURRENT_DATE} +'%a')
        JRNL_FILE="$CURRENT_DATE.$DAY.jrnl.org"

        if [[ -f "$JRNL/$JRNL_FILE" ]]; then
            # Skip file
            echo "$JRNL_FILE (Exists)"
        else
            # Create file and title
            echo "${Green}$JRNL_FILE${NC} [CREATED]"
            touch $OUTPUT_DIR/$JRNL_FILE
            TITLE="#+TITLE:     ${JRNL_FILE}"

            # echo header into file
            echo $TITLE   >> $OUTPUT_DIR/$JRNL_FILE
            echo $EMAIL   >> $OUTPUT_DIR/$JRNL_FILE
            echo $AUTHOR  >> $OUTPUT_DIR/$JRNL_FILE
            echo $OPTIONS >> $OUTPUT_DIR/$JRNL_FILE
	    echo $JOURNAL >> $OUTPUT_DIR/$JRNL_FILE
            echo $STARTUP >> $OUTPUT_DIR/$JRNL_FILE
            echo $LINE_TODO >> $OUTPUT_DIR/$JRNL_FILE
	    echo $LINE_JRNL >> $OUTPUT_DIR/$JRNL_FILE
	    echo $LINE_NOTE >> $OUTPUT_DIR/$JRNL_FILE
        fi


    done

fi
