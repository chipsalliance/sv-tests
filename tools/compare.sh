#!/bin/bash

rm -rf ./tests/generated
make generate-tests

for i in $(seq 0 $1); do
	DATE=$(date --date="`date` -$i week" '+%Y-%m-%d')

	rm -rf ./out/
	rm -rf ./third_party/tools

	git submodule update

	echo $DATE

	for d in ./third_party/tools/*/ ; do
		pushd $d
		git checkout `git rev-list -n 1 --first-parent --before="$DATE" HEAD`
		popd
	done

	make runners -j`nproc`

	make -j`nproc`

	cp ./out/report/report.csv $DATE.csv
done

./tools/csv-analyzer *.csv
