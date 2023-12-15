#!/bin/bash

# on suppose que les fichiers sont toujours construits de la même façon

function change_month {
    case $month in
        Jav) month=$((01));;
        Feb) month=$((02));;
        Mar) month=$((03));;
        Apr) month=$((04));;
        May) month=$((05));;
        Jun) month=$((06));;
        Jul) month=$((07));;
        Aug) month=$((08));;
        Sep) month=$((09));;
        Oct) month=$((10));;
        Nov) month=$((11));;
        Dec) month=$((12));;
          *) month=$((00));;
    esac
}


function create_file {
    if [ ! -d $year ] ; then
        mkdir $year
        echo "- Le dossier '$year' a été créé"
    fi
    cd $year

    if [ ! -d $month ] ; then
        mkdir $month
        echo "- Le dossier '$month' a été créé"
    fi
    cd $month

    touch $sorted_file
    cd .. ; cd ..
    cat $file > $year/$month/$sorted_file
    > $file
}


if [ $# = 1 ] && [ $1 = "base" ] && [ -d $1 ] ; then
    cd base

    for file in $(ls | grep .log) ; do
        if [[ -s $file && $file == *access* ]] ; then
            date=$(cat $file | grep -E -o -m1 "[0-9]{2}/[A-Z a-z]{3}/[0-9]{4,}")

            year=$(echo $date | cut -d '/' -f 3)
            month=$(echo $date | cut -d '/' -f 2)
            day=$(echo $date | cut -d '/' -f 1)
            sorted_file=$day"_access.log"

            change_month
            create_file

        elif [[ -s $file && $file == *error* ]] ; then
            date=$(cat $file | tr '[]' ' ' | cut -d ' ' -f 1-6 | tail -n 1)

            year=$(echo $date | cut -d ' ' -f 5)
            month=$(echo $date | cut -d ' ' -f 2)
            day=$(echo $date | cut -d ' ' -f 3)
            sorted_file=$day"_error.log"

            change_month
            create_file

        else
            echo "- Impossible de faire une archive du fichier '$file'"
        fi

    done
    echo "Fin de la tâche"
   
else
    echo "Erreur, 1 seul paramètre est nécessaire : le répertoire 'base'"
fi

exit
