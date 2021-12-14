#!/bin/bash

if [ -d "/opt/MEIC_41920/data" ] 
then
    echo "Directory /opt/MEIC_41920/data exists :)" 
else
    sudo mkdir -p /opt/MEIC_41920/data
fi

sudo chown vroot:vroot /opt/MEIC_41920
sudo chmod -R 775 /opt/MEIC_41920/data

