#!/bin/bash
# this will run speedtest-cli in CSV mode outputting to markdown table and
# removing any PII.




function to_markdown() {
  cut -d, -f 3,6,7,8 | sed 's/,/ | /g' | while read LINE
 do
   echo "| ${LINE} |"
 done
}

speedtest --server 14623 --csv-header | to_markdown
echo "| --- | --- | --- | --- |"
for i in `seq 1 5`
do
        speedtest --server 14623 --csv | to_markdown
        sleep 10
done

