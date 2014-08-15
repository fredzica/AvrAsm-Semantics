#!/bin/bash

for f in UnitTests/*
do
    echo "Running UnitTests on $f"
    result=$(krun --parser ./parser.sh $f | grep -Pzo "<state>\n.*FINISHED\n.*</state>")
    if [ -n "$result" ];
        then 
            echo "Success"
    else
        echo "------------------ Failure! On testing file $f. ---------------------------"
        failure=true
    fi
done

