#!/usr/bin/env bash

NUMBERED_LIST=$(mktemp)

TOTAL=$(
  # get blame for all the files, skip submodules
  git ls-files -z | xargs -0n1 git blame -w --show-email 2>/dev/null |
  # remove everything but the emails
  perl -n -e '/^.*\(<(.*?)>\s+.*/; print $1, "\n"' |
  # sort
  sort -f |
  # count unique entries
  uniq -c |
  # sort by the biggest number
  sort -n -r |
  # store the intermediate result in a temporary file
  tee $NUMBERED_LIST |
  # print only first column
  perl -lae '{print $F[0]}' |
  # merge with +
  paste -sd+ |
  # calculate the total
  bc)

echo Number of lines: $TOTAL

echo -e "\n\nBreakdown:\n"

# calculate percentages
cat $NUMBERED_LIST |
  perl -lae '{printf ("%6.2f%", ($F[0]/'$TOTAL'*100)); print( " ", join(" ", @F))}'

rm $NUMBERED_LIST
