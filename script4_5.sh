#!/bin/bash

# on suppose que les fichiers sont toujours construits de la même façon

function change_day {
    sed -i -e "s/Mon/Lun/g" stat4_5.txt
    sed -i -e "s/Tue/Mar/g" stat4_5.txt
    sed -i -e "s/Wed/Mer/g" stat4_5.txt
    sed -i -e "s/Thu/Jeu/g" stat4_5.txt
    sed -i -e "s/Fri/Ven/g" stat4_5.txt
    sed -i -e "s/Sat/Sam/g" stat4_5.txt
    sed -i -e "s/Sun/Dim/g" stat4_5.txt
}


function change_month {
    sed -i -e "s/Jav/Jan/g" stat4_5.txt
    sed -i -e "s/Feb/Fev/g" stat4_5.txt
    sed -i -e "s/Apr/Avr/g" stat4_5.txt
    sed -i -e "s/May/Mai/g" stat4_5.txt
    sed -i -e "s/Jun/Juin/g" stat4_5.txt
    sed -i -e "s/Jul/Juil/g" stat4_5.txt
    sed -i -e "s/Aug/Août/g" stat4_5.txt
}


if [ $# = 2 ] ; then
    if [[ $1 = 'base' && -d $1 ]] ; then
        if [[ $2 =~ ^([0-9]{2}/){2}[0-9]{4,}$ ]] ; then
            ./script1.sh base > /dev/null
            cd base
            
            year=$(echo $2 | cut -d '/' -f 3)
            month=$(echo $2 | cut -d '/' -f 2)
            day=$(echo $2 | cut -d '/' -f 1)

            choice=""
            while [[ $choice != 1 && $choice != 2 ]] ; do
                clear
                files=""
                read -p "Voulez-vous faire une requête en fonction du jour (1) ou du mois (2) ? : " choice 
                if   [ $choice == 1 ] ; then
                    if [ -d $year/$month/ ] ; then files=$(ls $year/$month/ | grep $day'_error.log') ; fi
                elif [ $choice == 2 ] ; then
                    if [ -d $year/$month/ ] ; then files=$(ls $year/$month/ | grep '_error.log') ; fi
                else
                    echo "- Veuillez choisir un paramètre correct" ; sleep 2
                fi
            done
            
            if [[ ! -z $files ]] ; then
                cd $year/$month/
                touch stat4_5.txt
                launch=1
                while [ $launch == 1 ] ; do
                    clear
                    > stat4_5.txt
                    for action in "1) Totalité des erreurs mises en forme" "2) Totalité des erreurs mises en forme sous fichier .imp " "3) Nombre d'erreurs" "4) Nombre de type d'erreurs différents" "5) Affichage des erreurs par IP" "6) Affichage des erreurs par PID" "7) Affichage des messages d'erreurs différents par type d'erreur" "8) Quitter"; do
                        echo $action
                    done

                    read -p "- Choisir une action : " action
                    case $action in

                        1)  for file in $files ; do
                                cat $file | tr '[]' ' ' | awk '{print $1" "$3" "$2" "$5" "$4" "$0}' | cut -d ' ' -f 1-6,12- >> stat4_5.txt
                            done
                            change_day
                            change_month

                            cat stat4_5.txt | column -t -s ' ' | tr '[],:' ' ' > stat4_5.txt
                            echo "- Erreurs mises en forme :"
                            cat stat4_5.txt ; sleep 5 ;;


                        2)  for file in $files ; do
                                cat $file | tr '[]' ' ' | awk '{print $1" "$3" "$2" "$5" "$4" "$0}' | cut -d ' ' -f 1-6,12- >> stat4_5.txt
                            done
                            change_day
                            change_month

                            if [ ! -d ../../sortie ] ; then
                                cd .. ; cd ..
                                mkdir sortie
                                echo "- Le dossier 'sortie' a été créé"
                                cd $year/$month
                            fi

                            if [ $choice == 1 ] ; then
                                error_file='error_'$day'_'$month'_'$year.imp
                            else
                                error_file='error_'$month'_'$year.imp
                            fi
                            
                            cat stat4_5.txt | column -t -s ' ' | tr '[],:' ' ' > ../../sortie/$error_file
                            echo "- Le dossier 'sortie' a été mis à jour : ajout ou modification du fichier '$error_file'" ; sleep 5 ;;

    
                        3)  for file in $files ; do
                                cat $file >> stat4_5.txt
                            done
                            count=$(cat stat4_5.txt | wc -l)
                            echo "- Nombre d'erreurs : $count" ; sleep 4 ;;


                        4)  for file in $files ; do
                                cat $file | grep -E -o "[a-z_0-9]{1,}:error" | cut -d ':' -f 1 >> stat4_5.txt
                            done
                            count=$(cat stat4_5.txt | sort -u | wc -l)
                            echo "- Nombre de type d'erreurs différents : $count" ; sleep 4 ;;


                        5)  read -p "- Choisir une adresse IP valide : " IP
                            while [[ ! $IP =~ ^([0-9]{1,3}[.]){3}[0-9]{1,3}$ ]] ; do
                                read -p "- Attention, veuillez choisir une adresse IP valide : " IP
                            done

                            for file in $files ; do
                                cat $file | grep -w "client $IP" >> stat4_5.txt 
                            done
                            echo "- Erreurs par l'adresse '$IP' :"
                            cat stat4_5.txt ; sleep 5 ;;


                        6)  read -p "- Choisir un PID valide : " PID
                            while [[ ! $PID =~ ^[0-9]{1,}$ ]] ; do
                                read -p "- Attention, veuillez choisir un PID valide : " PID
                            done

                            for file in $files ; do
                                cat $file | grep -w "pid $PID" >> stat4_5.txt 
                            done
                            echo "- Erreurs avec le PID '$PID' :"
                            cat stat4_5.txt ; sleep 5 ;;


                        7)  read -p "- Choisir un type d'erreur valide : " TE
                            while [[ ! $TE =~ ^[a-z_0-9]{1,}$ ]] ; do
                                read -p "- Attention, veuillez choisir un type d'erreur valide : " TE
                            done

                            for file in $files ; do
                                cat $file | grep -w "$TE:error" | cut -d ']' -f 5 >> stat4_5.txt 
                            done
                            echo "- Messages différents avec le type d'erreur '$TE' :"
                            cat stat4_5.txt | sort -u  ; sleep 5 ;;


                        8)  launch=0 ;;
                        *)  echo "- Ce choix ne correspond à aucune action" ; sleep 2
                    esac

                done
                rm stat4_5.txt
                cd .. ; cd ..

            else
                echo "- La date saisie ne correspond avec aucun fichier de type 'error_log'" 
            fi
            echo "Fin de la tâche"

        else
            echo "- Erreur, une date de type 'dd/mm/yyyy' est nécessaire en 2ème paramètre"
        fi

    else
        echo "- Erreur, le répertoire 'base' est nécessaire en 1er paramètre"     
    fi

else
    echo "- Erreur, le script doit contenir 2 paramètres"
fi

exit
