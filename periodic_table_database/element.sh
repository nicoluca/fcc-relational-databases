#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_ELEMENT() {
    case $1 in
        [0-9]|[0-9][0-9]) NUMBER_SEARCH $1;;
        [A-Z]|[A-Z][a-z]) SYMBOL_SEARCH $1;;
        *) NAME_SEARCH $1;;
    esac    
}

NUMBER_SEARCH() {
    RESULT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1;")
    EVALUATE_RESULT $RESULT_NUMBER
}

SYMBOL_SEARCH() {
    RESULT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1';")
    EVALUATE_RESULT $RESULT_NUMBER
}

NAME_SEARCH() {
    RESULT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1';")
    EVALUATE_RESULT $RESULT_NUMBER
}

EVALUATE_RESULT() {
    if [[ -z $1 ]]
    then
        echo "I could not find that element in the database."
    else
        DERIVE_INFO $RESULT_NUMBER
    fi
}

DERIVE_INFO() {
    ATOMIC_NUMBER=$1
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;")
    TYPE=$($PSQL "SELECT types.type FROM properties LEFT JOIN types USING (type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")
    MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")
    BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

if [ $# -eq 0 ]
    then
        echo "Please provide an element as an argument."
    else
        GET_ELEMENT $1
fi
