#!/usr/bin/bash

## cronjob : At every 6 hours perday
#.0 */6 * * *

## Enter your webhook API address here.
webhook=""

ret_error() {
	if [[ $2 = "true" ]]
	then
		color=65280
	else
		color=16711680
	fi

	### Name seperation
	tmp=$(sudo docker inspect --format="{{.Name}}" "$1")
	IFS='/' read -ra tmp <<< "$tmp"

	name=""
	for i in "${tmp[@]}"
	do
		name="${name} ${i}"
	done

	msg="šš¼š»šš®š¶š»š²šæ šš : $1\nššæš²š®šš²š± šš : $(date -d $(sudo docker inspect --format='{{.State.StartedAt}}' "$1"))"
	if [[ ! $2 == "true" ]]
	then
	msg="$msg\nšš®š¶š¹š²š± šš : $(date -d $(sudo docker inspect --format='{{.State.FinishedAt}}' "$1"))\nššš¶š šš¼š±š² : $(sudo docker inspect --format='{{.State.ExitCode}}' "$1")\n"
	fi

	fmsg="{ \"wait\": true, \"embeds\": [{ \"_\": \"_\", \"title\": \"${name}\", \"description\": \"\", \"color\": \"16711680\", \"timestamp\": \"$(date -u --iso-8601=seconds)\", \"author\": { \"_\": \"_\", \"name\":\"Docker Report\", \"icon_url\": \"https://imgur.com/axp9PKK.png\"}, \"thumbnail\": {  }, \"image\": { \"_\": \"_\" }, \"footer\": { \"_\":\"_\" } }], \"embeds\": [{ \"_\": \"_\", \"title\": \"\", \"description\": \"${msg}\", \"color\":\"${color}\", \"timestamp\": \"$(date -u --iso-8601=seconds)\", \"author\": { \"_\": \"_\", \"name\":\"${name}\", \"icon_url\": \"https://imgur.com/axp9PKK.png\"}, \"thumbnail\": {  }, \"image\": { \"_\": \"_\" }, \"footer\": { \"_\":\"_\", \"text\": \"Made with ā¤ļø\"} }] }"

	curl -H "Content-Type: application/json" -H "Expect: application/json" -X POST "${webhook}" -d "${fmsg}" 2>/dev/null
}

sudo docker ps -aq > LOG.log

while IFS= read -r line
do
	ret_error "${line}" "$(sudo docker inspect "${line}" --format='{{.State.Running}}')"
done < LOG.log
