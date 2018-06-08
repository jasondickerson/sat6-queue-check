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
passenger-status | head -n 13
echo

rpm -q satellite > /dev/null
IS_SATELLITE=$?
if [ ${IS_SATELLITE} -eq 0 ] ; then 
	echo -en "\e[1;41;33mMonitor Event Queue Task backlog:\e[0m  "
	echo "select count(*) from katello_events" | su - postgres -c "psql foreman"|head -n3|tail -n1|tr -s " "|cut -d\  -f2
	echo
	echo -en "\e[1;41;33mListen on candlepin events Task backlog:\e[0m  "
	qpid-stat --ssl-certificate /etc/pki/katello/certs/java-client.crt --ssl-key /etc/pki/katello/private/java-client.key -b "amqps://localhost:5671" -q katello_event_queue|grep queue-depth|tr -s " "|cut -d\  -f3
	echo
	echo -ne "\e[1;41;33mForeman Total tasks:\e[0m\\t"
	cat << EOF | su - postgres -c 'psql foreman -t'|head -n1
select
  count(*)
  from foreman_tasks_tasks
where
  label not in ('Actions::Katello::EventQueue::Monitor', 'Actions::Candlepin::ListenOnCandlepinEvents', 'Actions::Insights::EmailPoller') and
  state!='stopped';
EOF

	for STATE in planning planned running paused ; do
  		echo -ne "\e[1;41;33mForeman tasks ${STATE}:\e[0m\\t"
  		cat << EOF | su - postgres -c 'psql foreman -t'|head -n1
select
  count(*)
  from foreman_tasks_tasks
where
  label not in ('Actions::Katello::EventQueue::Monitor', 'Actions::Candlepin::ListenOnCandlepinEvents', 'Actions::Insights::EmailPoller') and
  state='${STATE}';
EOF

		cat <<EOF | su - postgres -c 'psql foreman -t'|head -n1
select
  count(label) as outstanding_task_count,
  label as task_name
from
  foreman_tasks_tasks
where
  ended_at is null and
  label not in ('Actions::Katello::EventQueue::Monitor', 'Actions::Candlepin::ListenOnCandlepinEvents', 'Actions::Insights::EmailPoller') and
  state='${STATE}'
group by
  task_name
order by
  outstanding_task_count;
EOF
	done
fi

RUNNING=$(mongo pulp_database --eval "db.task_status.find({'state': {\$eq: 'running' }}).count()"|tail -n1)
WAITING=$(mongo pulp_database --eval "db.task_status.find({'state': {\$eq: 'waiting' }}).count()"|tail -n1)

echo -e "\e[1;41;33mPulp tasks Running:\e[0m  "${RUNNING}
echo -e "\e[1;41;33mPulp tasks Waiting:\e[0m  "${WAITING}
echo

if [ ${RUNNING} -ne 0 ] ; then
  RUNNING_TYPES=$(mongo pulp_database --eval "db.task_status.distinct( 'task_type', {'state': {\$eq: 'running' }}).forEach(printjson)"|tail -n +3|sed -e s/\"//g)
  echo -e "\e[1;41;33mRunning Tasks by Type:\e[0m"
  for TYPE in ${RUNNING_TYPES} ; do
    COUNT=$(mongo pulp_database --eval "db.task_status.find({'state': {\$eq: 'running' }, 'task_type': {\$eq: '${TYPE}'}}).count()"|tail -n1)
    echo -e ${COUNT}\\t: ${TYPE}
  done
  echo
fi

if [ ${WAITING} -ne 0 ] ; then
  WAITING_TYPES=$(mongo pulp_database --eval "db.task_status.distinct( 'task_type', {'state': {\$eq: 'waiting' }}).forEach(printjson)"|tail -n +3|sed -e s/\"//g)
  echo -e "\e[1;41;33mWaiting Tasks by Type:\e[0m"
  for TYPE in ${WAITING_TYPES} ; do
    COUNT=$(mongo pulp_database --eval "db.task_status.find({'state': {\$eq: 'waiting' }, 'task_type': {\$eq: '${TYPE}'}}).count()"|tail -n1)
    echo -e ${COUNT}\\t: ${TYPE}
  done
fi

echo
echo -en "\e[1;41;33mSatellite QPID\e[0m "
qpid-stat -q --ssl-certificate=/etc/pki/katello/qpid_client_striped.crt -b amqps://localhost:5671 | grep -v pulp.agent | grep -if qpid_search
echo
echo -en "\e[1;41;33mSatellite Service Status:\e[0m  "
katello-service status 2> /dev/null|tail -n1

if [ ${IS_SATELLITE} -eq 0 ] ; then
	echo
	echo -e "\e[1;41;33mHammer Ping Results:\e[0m  "
	hammer ping
fi
