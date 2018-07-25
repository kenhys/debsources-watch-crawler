#!/bin/bash

DATABASE_DIR=db
DATABASE_FILE=debian-watch.db
DUMP_FILE=data/dump-201807231000.grn

case $1 in
    rebuild)
	rm -fr $DATABASE_DIR/
	mkdir $DATABASE_DIR
	groonga -n $DATABASE_DIR/$DATABASE_FILE < $DUMP_FILE
	;;
    *)
	;;
esac
      
