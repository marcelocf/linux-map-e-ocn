#!/bin/bash
# this will run speedtest-cli in CSV mode outputting to markdown table and
# removing any PII.




function to_markdown() {
  cut -d, -f 1,6,7,8 | sed 's/,/ | /g' | while read LINE
 do
   echo "| ${LINE} |"
 done
}

speedtest --csv-header | to_markdown
echo "| --- | --- | --- | --- |"
for i in `seq 1 15`
do
        speedtest --csv | to_markdown
        sleep 5
done

