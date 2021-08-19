#!/bin/bash

#   Ejecución del Test
    sudo smartctl -t short /dev/sda

#   Esperamos 10 Minutos
    sleep 10m

#   Generamos el reporte
    fecha=$(date +"%Y%m%d-%HH%MM%SS")
    sudo smartctl -a /dev/sda > /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha}

#   Convertimos a PDF
    a2ps /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha} -o /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha}.ps
    ps2pdf /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha}.ps /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha}.pdf

#   Borramos el archivo .ps 
    rm -rf /mnt/nostromo-hdd_cache/smartctl/rPi04/sda_adata_SU650_${fecha}.ps