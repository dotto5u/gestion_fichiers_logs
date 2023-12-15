#!/bin/bash

# on suppose que les fichiers sont toujours construits de la même façon

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
                    if [ -d $year/$month/ ] ; then files=$(ls $year/$month/ | grep $day'_access.log') ; fi
                elif [ $choice == 2 ] ; then
                    if [ -d $year/$month/ ] ; then files=$(ls $year/$month/ | grep '_access.log') ; fi
                else
                    echo "- Veuillez choisir un paramètre correct" ; sleep 2
                fi
            done
            
            if [[ ! -z $files ]] ; then
                cd $year/$month/
                touch stat2_3.txt
                launch=1
                while [ $launch == 1 ] ; do
                    clear
                    > stat2_3.txt
                    for choice in "1) Nombre de requêtes différentes d'une IP" "2) Nombre de requêtes différentes par heure" "3) Nombre de code statut différent d'un utilisateur" "4) Affichage des IP différentes d'un utilisateur" "5) Quitter" ; do
                        echo $choice
                    done

                    read -p "- Choisir une action : " choice
                    case $choice in

                        1)  read -p "- Choisir une adresse IP valide : " IP
                            while [[ ! $IP =~ ^([0-9]{1,3}[.]){3}[0-9]{1,3}$ ]] ; do
                                read -p "- Attention, veuillez choisir une adresse IP valide : " IP
                            done

                            for file in $files ; do
                                cat $file | grep -w $IP | cut -d '"' -f 2 >> stat2_3.txt
                            done
                            count=$(sort -u stat2_3.txt | wc -l)
                            echo "- Il y'a $count requêtes différentes avec l'adresse '$IP'" ; sleep 4 ;;


                        2)  for file in $files ; do 
                                cat $file | grep -E -o "$day/.../$year:[0-9]{2}" | cut -d ':' -f 2 >> stat2_3.txt
                            done
                            hours=$(sort -u stat2_3.txt)
                            
                            for hour in $hours ; do
                                > stat2_3.txt
                                for file in $files ; do
                                    cat $file | grep "$day/.../$year:$hour" | cut -d '"' -f 2 >> stat2_3.txt
                                done
                                count=$(sort -u stat2_3.txt | wc -l)
                                echo "- Nombre de requêtes différentes à $hour h : $count"
                            done ; sleep 4 ;;


                        3)  read -p "- Choisir un nom d'utilisateur valide : " UN
                            while [[ ! $UN =~ ^[a-zA-Z]{1,20}$ ]] ; do
                                read -p "- Attention, veuillez choisir un nom d'utilisateur valide : " UN
                            done

                            for file in $files ; do
                                cat $file | grep -w -i "[-]$UN[-]" | grep -o '"[GP].*' | cut -d ' ' -f 4 >> stat2_3.txt
                            done
                            count=$(sort -u stat2_3.txt | wc -l)
                            echo "- Nombre de code statut différent pour l'utilisateur '$UN' : $count" ; sleep 5 ;;
                                

                        4)  read -p "- Choisir un nom d'utilisateur valide : " UN
                            while [[ ! $UN =~ ^[a-zA-Z]{1,20}$ ]] ; do
                                read -p "- Attention, veuillez choisir un nom d'utilisateur valide : " UN
                            done
                            
                            for file in $files ; do
                                cat $file | grep -w -i "[-]$UN[-]" | cut -d ' ' -f 1 >> stat2_3.txt
                            done
                            echo "- IP différentes de l'utilisateur '$UN' :"
                            cat stat2_3.txt | sort -u ; sleep 5 ;;


                        5)  launch=0 ;;
                        *)  echo "- Ce choix ne correspond à aucune action" ; sleep 2
                    esac

                done
                rm stat2_3.txt
                cd .. ; cd ..

            else
                echo "- La date saisie ne correspond avec aucun fichier de type 'access_log'" 
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
