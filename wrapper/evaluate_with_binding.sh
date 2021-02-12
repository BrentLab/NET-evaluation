#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                 p_net)
                 
            esac;;
    esac
done
