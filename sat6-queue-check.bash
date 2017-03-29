#!/bin/bash
if [ ! -f qpid_search ] ; then
        echo """queue
celery
pulp
resource
=""" > qpid_search
fi

echo -e "\e[1;41;33mUptime and Load Average:\e[0m"
uptime
echo
echo -e "\e[1;41;33mPassenger Status\e[0m"
passenger-status | head -n 12
echo
echo -en "\e[1;41;33mForeman Task Queue:\e[0m  "
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label ~ *' STATES=running,pending,planning,planned VERBOSE=true NOOP=true 2> /dev/null | grep deleted |cut -d\  -f2
echo
echo -en "\e[1;41;33mMonitor Event Queue Task backlog:\e[0m  "
echo "select count(*) from katello_events" | su - postgres -c "psql foreman"|head -n3|tail -n1|tr -s " "|cut -d\  -f2
echo
echo -en "\e[1;41;33mListen on candlepin events Task backlog:\e[0m  "
qpid-stat --ssl-certificate /etc/pki/katello/certs/java-client.crt --ssl-key /etc/pki/katello/private/java-client.key -b "amqps://localhost:5671" -q katello_event_queue|grep queue-depth|tr -s " "|cut -d\  -f3
echo
echo -e "\e[1;41;33mPulp Tasks Count by State:\e[0m"
PULP_RESULT=$(pulp-admin tasks list |grep State|uniq -c)
if [ -n "${PULP_RESULT}" ] ; then
        echo ${PULP_RESULT}
else
        echo "No Pulp Tasks Running."
fi
echo
echo -en "\e[1;41;33mSatellite QPID\e[0m "
qpid-stat -q --ssl-certificate=/etc/pki/katello/qpid_client_striped.crt -b amqps://localhost:5671 | grep -v pulp.agent | grep -if qpid_search
echo
