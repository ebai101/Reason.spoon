#!/usr/bin/env bash

# FILES=$(mdfind 'kMDItemDisplayName == *.reason' -0)
# DATA=$(mdls -name kMDItemFSContentChangeDate -name kMDItemFSName $(echo)
# xargs -0 mdls -name kMDItemFSContentChangeDate -name kMDItemFSName
# while read -r file; do
#     data=$(mdls -name kMDItemFSContentChangeDate -name kMDItemFSName $file)
#     printf "%s %s\n" "$data" "$file"
# done < <(mdfind 'kMDItemDisplayName == *.reason')

FILES=$(mdfind 'kMDItemDisplayName == *.reason' -0 | ghead -z)
# echo $FILES
parallel ::: "$FILES" ::: mdls -raw -name kMDItemFSContentChangeDate -name kMDItemFSName "{}"
