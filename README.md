# sat6-queue-check
Script to provide a quick view of Satellite queues including foreman, katello, pulp, and qpid.  

v2.0 supports Satellite with Remote Databases and is tested against Red Hat Satellite 6.6.  

v3.0 accounts for changes made in Satellite 6.7

v4.0 includes some housekeeping improvements and is tested against Satellite 6.9

v4.1 minor improvments, eliminated the qpid_search file, added lots of comments

v5.0 Added Puma Status for 6.10 and above, and added support for pulp3.

v5.1 Added support for 6.11 and 6.12.  Updated pulp3 check.  Disabled qpid-stat for 6.11 and above.

Example Output:

```
Uptime and Load Average:
 15:58:25 up  6:50,  2 users,  load average: 6.74, 3.81, 1.63

Puma Status
1401 (/usr/share/foreman/tmp/puma.state) Uptime:  6h49m | Phase: 0 | Load: 1[█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]30 | Req: 2130
 └  2725 CPU:   0.0% Mem:  713 MB Uptime:  6h49m | Load: 0[░░░░░]5 | Req: 201
 └  2730 CPU:   0.0% Mem:  799 MB Uptime:  6h49m | Load: 0[░░░░░]5 | Req: 507
 └  2736 CPU:  80.0% Mem:  830 MB Uptime:  6h49m | Load: 1[█░░░░]5 | Req: 408
 └  2741 CPU:   0.0% Mem:  803 MB Uptime:  6h49m | Load: 0[░░░░░]5 | Req: 318
 └  2743 CPU:   0.0% Mem:  779 MB Uptime:  6h49m | Load: 0[░░░░░]5 | Req: 219
 └  2744 CPU:   0.0% Mem:  798 MB Uptime:  6h49m | Load: 0[░░░░░]5 | Req: 477
Monitor Event Queue Task backlog:       0


Listen on candlepin events Task backlog:  
Foreman Total tasks:	    24

Foreman tasks planning:	     0


Foreman tasks planned:	     0


Foreman tasks running:	    24

                     24 | Actions::Katello::Repository::Sync

Foreman tasks paused:	     0


Pulp tasks Running:   4
Pulp tasks Waiting:   19

Running Tasks by Type:
4	: pulp_rpm.app.tasks.synchronizing.synchronize

Waiting Tasks by Type:
16	: pulpcore.app.tasks.base.general_update
3	: pulp_rpm.app.tasks.synchronizing.synchronize

Satellite QPID Queues
  queue                                            dur  autoDel  excl  msg   msgIn  msgOut  bytes  bytesIn  bytesOut  cons  bind
  ================================================================================================================================
  celery                                           Y                      0    22     22       0   18.1k    18.1k        0     2
  reserved_resource_worker-0@sat6.example.com.dq2  Y                      0     0      0       0      0        0         0     2
  reserved_resource_worker-1@sat6.example.com.dq2  Y                      0     0      0       0      0        0         0     2
  reserved_resource_worker-2@sat6.example.com.dq2  Y                      0     0      0       0      0        0         0     2
  reserved_resource_worker-3@sat6.example.com.dq2  Y                      0     0      0       0      0        0         0     2
  resource_manager                                 Y                      0     0      0       0      0        0         0     2
  resource_manager@sat6.example.com.dq2            Y                      0     0      0       0      0        0         0     2

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
