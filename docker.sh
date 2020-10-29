#!/usr/bin/env bash
export image_name=omrsregrepo/bahmni_base:76_291020

if sudo docker images | grep ${image_name}; then
   sudo docker rmi $(sudo docker images | grep ${image_name} | tr -s ' ' | cut -d ' ' -f 3)
else
  echo "Image doesn't exists"
fi

docker build --rm -t ${image_name}