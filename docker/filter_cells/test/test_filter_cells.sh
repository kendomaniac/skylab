#!/bin/bash

## Description: Unit test for emptyDropsWrapper script

## Test parameters
testDataURL="http://cf.10xgenomics.com/samples/cell-exp/2.1.0/pbmc4k/pbmc4k_raw_gene_bc_matrices.tar.gz"
testDataFileName="pbmc4k_raw_gene_bc_matrices.tar.gz"
testDataInputMatrixPath="raw_gene_bc_matrices/GRCh38"
filterCellsOutput="pbmc4k_filterCells.csv"
rdsFileName="pbmc4k.rds"
md5checksum="ab572acfd7c012496becfd041dc60b33"

# Extra things extracted from the "testDataURL" you want to clean up
extraCleanup="raw_gene_bc_matrices"

## Download some sample data from 10X
printf "Downloading pbmc4k data..."
wget -q $testDataURL
printf "done\n"

## Decompress dataset
printf "Decompressing archive..."
tar xzf $testDataFileName
printf "done\n"

## Prepare RDS files for reading from the the 10X matrix
printf "Converting mtx to rds..."
../../emptydrops/emptyDropsWrapper/test/prepRDS.R --input ${testDataInputMatrixPath} --output ${rdsFileName}
printf "done\n"

## Run filter cells
printf "Running filter_cells..."
../filter_cells.R -i ${rdsFileName} -o ${filterCellsOutput}
printf "done\n"

## Check the output md5 checksum
printf "Verifying checksum..."
if [ "$(uname)" == "Darwin" ]; then
    md5out=`md5 -r ${filterCellsOutput} | cut -f 1 -d ' '`
else
    md5out=`md5sum ${filterCellsOutput} | cut -f 1 -d ' '`
fi

exitCode=0
if [ "$md5out" = "$md5checksum" ];
then
    echo 'PASSED'
    exitCode=0
else
    echo 'FAIL'
    exitCode=1
fi
printf "done\n"

## Cleanup
rm ${filterCellsOutput} ${testDataFileName} ${rdsFileName}
rm -r ${extraCleanup}

exit $exitCode
