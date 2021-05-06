# sat6-queue-check
Script to provide a quick view of Satellite queues including foreman, katello, pulp, and qpid.  

v2.0 supports Satellite with Remote Databases and is tested against Red Hat Satellite 6.6.  

v3.0 accounts for changes made in Satellite 6.7

v4.0 includes some housekeeping improvements and is tested against Satellite 6.9

v4.1 minor improvments, eliminated the qpid_search file, added lots of comments

Example Output:

```
Uptime and Load Average:
 12:15:09 up  2:08,  1 user,  load average: 0.00, 0.01, 0.05

Monitor Event Queue Task backlog:       0


Listen on candlepin events Task backlog:  0

Foreman Total tasks:	     0

Foreman tasks planning:	     0


Foreman tasks planned:	     0


Foreman tasks running:	     0


Foreman tasks paused:	     0


Pulp tasks Running:  0
Pulp tasks Waiting:  0


Satellite QPID Queues
  queue                                                      dur  autoDel  excl  msg   msgIn  msgOut  bytes  bytesIn  bytesOut  cons  bind
  ==========================================================================================================================================
  celery                                                     Y                      0    26     26       0   21.4k    21.4k        4     2
  pulp.task                                                  Y                      0     0      0       0      0        0         3     1
  reserved_resource_worker-0@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-0@sat6.example.com.dq2            Y                      0     4      4       0   4.24k    4.24k        1     2
  reserved_resource_worker-1@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-1@sat6.example.com.dq2            Y                      0     0      0       0      0        0         1     2
  reserved_resource_worker-2@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-2@sat6.example.com.dq2            Y                      0     0      0       0      0        0         1     2
  reserved_resource_worker-3@sat6.example.com.celery.pidbox       Y                 0     0      0       0      0        0         1     2
  reserved_resource_worker-3@sat6.example.com.dq2            Y                      0     0      0       0      0        0         1     2
  resource_manager                                           Y                      0     2      2       0   2.85k    2.85k        1     2
  resource_manager@sat6.example.com.celery.pidbox                 Y                 0     0      0       0      0        0         1     2
  resource_manager@sat6.example.com.dq2                      Y                      0     0      0       0      0        0         1     2

Running ForemanMaintain::Scenario::FilteredScenario
================================================================================
Clean old Kernel and initramfs files from tftp-boot:                  [SKIPPED]
--------------------------------------------------------------------------------
Check number of fact names in database:                               [OK]
--------------------------------------------------------------------------------
Check for verifying syntax for ISP DHCP configurations:               [OK]
--------------------------------------------------------------------------------
Check whether all services are running:                               [OK]
--------------------------------------------------------------------------------
Check whether all services are running using the ping call:           [OK]
--------------------------------------------------------------------------------
Check for paused tasks:                                               [OK]
--------------------------------------------------------------------------------
Check to verify no empty CA cert requests exist:                      [OK]
--------------------------------------------------------------------------------
Check whether system is self-registered or not:                       [OK]
--------------------------------------------------------------------------------
```
