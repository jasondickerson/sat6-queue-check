#!/bin/bash

# Determine the correct qpid certificate, 6.6+, 6.2 - 6.5, or 6.0 - 6.1
if [ -f /etc/pki/pulp/qpid/client.crt ] ; then
  QPID_CERT="/etc/pki/pulp/qpid/client.crt"
elif [ -f /etc/pki/katello/qpid_client_striped.crt ] ; then
  QPID_CERT="/etc/pki/katello/qpid_client_striped.crt"
else 
  QPID_CERT="/etc/pki/katello/certs/java-client.crt"
fi

# Is this a satellite or capsule?
rpm -q satellite > /dev/null
IS_SATELLITE=$?

# Display Uptime
echo -e "\e[1;41;33mUptime and Load Average:\e[0m"
uptime
echo

# Perform Satellite only actions
if [ ${IS_SATELLITE} -eq 0 ] ; then
  # Only check passenger status on 6.0 - 6.8.
  # In future versions, will check puma status instead, but that is not available in Satellite as yet.
  SATELLITE_MAJOR_VERSION=$(rpm -q satellite --qf %{VERSION} | cut -d. -f1)
  SATELLITE_MINOR_VERSION=$(rpm -q satellite --qf %{VERSION} | cut -d. -f2)
  if [[ ${SATELLITE_MAJOR_VERSION} -eq 6 && ${SATELLITE_MINOR_VERSION} -lt 9 ]] ; then
    echo -e "\e[1;41;33mPassenger Status\e[0m"
    passenger-status | head -n 13
    echo
  fi
  # Find postgresql host
  FDB_HOST=$(grep host: /etc/foreman/database.yml | tr -s " " | cut -d" " -f3)
  if [ -z ${FDB_HOST} ] ; then
    FDB_HOST="localhost"
  fi
  # Find foreman db user
    FDB_USER=$(grep username: /etc/foreman/database.yml | tr -s " " | cut -d" " -f3)
  # Check for .pgpass file
  if [ -f ~/.pgpass ] ; then
    # if necessary configure .pgpass entry for auto login to foreman db
    grep ${FDB_HOST}:5432:foreman:${FDB_USER}: ~/.pgpass &> /dev/null
    if [ $? -ne 0 ] ; then
      FDB_PASS=$(grep password: /etc/foreman/database.yml | tr -s " " | cut -d\" -f2)
      echo ${FDB_HOST}:5432:foreman:${FDB_USER}:${FDB_PASS} >> ~/.pgpass
    fi
  else
    #create .pgpass file with foreman db entry
    FDB_PASS=$(grep password: /etc/foreman/database.yml | tr -s " " | cut -d\" -f2)
    echo ${FDB_HOST}:5432:foreman:${FDB_USER}:${FDB_PASS} >> ~/.pgpass
    chmod 600 ~/.pgpass
  fi

  # Display any Monitor Event queue backlog
  echo -en "\e[1;41;33mMonitor Event Queue Task backlog:\e[0m  "
  echo "select count(*) from katello_events" | psql -h ${FDB_HOST} -U ${FDB_USER} -t foreman
  echo
  # Display any Candlepin Events backlog
  echo -en "\e[1;41;33mListen on candlepin events Task backlog:\e[0m  "
  qpid-stat --ssl-certificate ${QPID_CERT} -b "amqps://localhost:5671" -q katello_event_queue | grep queue-depth | tr -s " " | cut -d\  -f3
  echo
  # Report Foreman Tasks queue
  echo -ne "\e[1;41;33mForeman Total tasks:\e[0m\\t"
  cat << EOF | psql -h ${FDB_HOST} -U ${FDB_USER} -t foreman
select
  count(*)
  from foreman_tasks_tasks
where
  label not in ('Actions::Katello::EventQueue::Monitor', 'Actions::Candlepin::ListenOnCandlepinEvents', 'Actions::Insights::EmailPoller') and
  state!='scheduled' and
  state!='stopped';
EOF
  # Breakdown what the tasks and tasks states are
  for STATE in planning planned running paused ; do
    echo -ne "\e[1;41;33mForeman tasks ${STATE}:\e[0m\\t"
    cat << EOF | psql -h ${FDB_HOST} -U ${FDB_USER} -t foreman
select
  count(*)
  from foreman_tasks_tasks
where
  label not in ('Actions::Katello::EventQueue::Monitor', 'Actions::Candlepin::ListenOnCandlepinEvents', 'Actions::Insights::EmailPoller') and
  state='${STATE}';
EOF
    cat <<EOF | psql -h ${FDB_HOST} -U ${FDB_USER} -t foreman
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

# configure Mongo authentication
MONGO_HOST=$(grep ^seeds: /etc/pulp/server.conf | cut -d\  -f2)
MONGO_USER=$(grep ^username: /etc/pulp/server.conf | cut -d\  -f2)
MONGO_PASS=$(grep ^password: /etc/pulp/server.conf | cut -d\  -f2)
MONGO_REMOTE=""
if [ ! -z ${MONGO_HOST} ] ; then
  MONGO_REMOTE="--host ${MONGO_HOST}"
  if [ ! -z ${MONGO_USER} ] ; then
    MONGO_REMOTE="${MONGO_REMOTE} -u ${MONGO_USER}"
    if [ ! -z ${MONGO_PASS} ] ; then
      MONGO_REMOTE="${MONGO_REMOTE} -p ${MONGO_PASS}"
    fi
  fi
fi

#Find total Running and Waiting tasks in pulp
RUNNING=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.find({'state': {\$eq: 'running' }}).count()")
WAITING=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.find({'state': {\$eq: 'waiting' }}).count()")
echo -e "\e[1;41;33mPulp tasks Running:\e[0m  "${RUNNING}
echo -e "\e[1;41;33mPulp tasks Waiting:\e[0m  "${WAITING}
echo

# Breakdown Running pulp Tasks
if [ ${RUNNING} -ne 0 ] ; then
  RUNNING_TYPES=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.distinct( 'task_type', {'state': {\$eq: 'running' }}).forEach(printjson)" | sed -e s/\"//g)
  echo -e "\e[1;41;33mRunning Tasks by Type:\e[0m"
  for TYPE in ${RUNNING_TYPES} ; do
    COUNT=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.find({'state': {\$eq: 'running' }, 'task_type': {\$eq: '${TYPE}'}}).count()")
    echo -e ${COUNT}\\t: ${TYPE}
  done
  echo
fi

# Breakdown Waiting pulp Tasks
if [ ${WAITING} -ne 0 ] ; then
  WAITING_TYPES=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.distinct( 'task_type', {'state': {\$eq: 'waiting' }}).forEach(printjson)" | sed -e s/\"//g)
  echo -e "\e[1;41;33mWaiting Tasks by Type:\e[0m"
  for TYPE in ${WAITING_TYPES} ; do
    COUNT=$(mongo --quiet ${MONGO_REMOTE} pulp_database --eval "db.task_status.find({'state': {\$eq: 'waiting' }, 'task_type': {\$eq: '${TYPE}'}}).count()")
    echo -e ${COUNT}\\t: ${TYPE}
  done
fi
echo

# Display pulp server qpid queues, not to be confused with katello agent queues
echo -en "\e[1;41;33mSatellite QPID\e[0m "
qpid-stat --ssl-certificate ${QPID_CERT} -b amqps://localhost:5671 -q | grep -v pulp.agent | grep -e ueue -e celery -e pulp -e resource -e = |grep -v katello_event_queue
echo

# display health of server, services running, services pinging, etc...
foreman-maintain health check --whitelist check-tftp-storage

# echo -en "\e[1;41;33mSatellite Service Status:\e[0m  "
# if [ -x /usr/bin/foreman-maintain ] ; then
#   /usr/bin/foreman-maintain service status 2> /dev/null | grep "All services are running" &> /dev/null
#   if [ $? -eq 0 ] ; then
#     echo Success!
#   else
#     echo Failure!
#   fi
# else
#   katello-service status 2> /dev/null|tail -n1
# fi
# if [ ${IS_SATELLITE} -eq 0 ] ; then
#   echo
#   echo -e "\e[1;41;33mHammer Ping Results:\e[0m  "
#   hammer ping
# fi
