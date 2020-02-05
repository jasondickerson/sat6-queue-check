# sat6-queue-check
Script to provide a quick view of Satellite queues including foreman, katello, pulp, and qpid.  

v2.0 supports Satellite with Remote Databases and is tested again Red Hat Satellite 6.6

Example Output:

```
Uptime and Load Average:
 16:19:18 up 20 min,  1 user,  load average: 0.02, 0.14, 0.19

Passenger Status
Version : 4.0.18
Date    : 2018-05-25 16:19:18 -0500
Instance: 1398
----------- General information -----------
Max pool size : 12
Processes     : 2
Requests in top-level queue : 0

----------- Application groups -----------
/usr/share/foreman#default:
  App root: /usr/share/foreman
  Requests in queue: 0
  * PID: 2268    Sessions: 0       Processed: 9       Uptime: 19m 35s

Foreman Task Queue:  2

Monitor Event Queue Task backlog:  0

Listen on candlepin events Task backlog:  0

Pulp Tasks Count by State:
No Pulp Tasks Running.

Total pulp tasks queued:  23

Satellite QPID Queues
  queue                                                      dur  autoDel  excl  msg   msgIn  msgOut  bytes  bytesIn  bytesOut  cons  bind
  ==========================================================================================================================================
  celery                                                     Y                      0     4      4       0   3.33k    3.33k        4     2
  katello_event_queue                                        Y                      0     0      0       0      0        0         1     6
  pulp.task                                                  Y                      0     0      0       0      0        0         3     1
  reserved_resource_worker-0@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-0@sat6.example.com.dq             Y    Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-1@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-1@sat6.example.com.dq             Y    Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-2@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-2@sat6.example.com.dq             Y    Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-3@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-3@sat6.example.com.dq             Y    Y                 0     0      0       0      0        0         1     2
  resource_manager                                           Y                      0     0      0       0      0        0         1     2
  resource_manager@sat6.example.com.celery.pidbox                 Y                 0     0      0       0      0        0         1     2
  resource_manager@sat6.example.com.dq                       Y    Y                 0     0      0       0      0        0         1     2

Satellite Service Status:  Success!

Hammer Ping Results:  
candlepin:      
    Status:          ok
    Server Response: Duration: 24ms
candlepin_auth: 
    Status:          ok
    Server Response: Duration: 14ms
pulp:           
    Status:          ok
    Server Response: Duration: 27ms
pulp_auth:      
    Status:          ok
    Server Response: Duration: 14ms
foreman_tasks:  
    Status:          ok
    Server Response: Duration: 904ms
```
