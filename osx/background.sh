#!/bin/bash

 sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '/Library/Desktop Pictures/Solid Colors/Solid Gray Pro Ultra Dark.png'";
 killall Dock;
