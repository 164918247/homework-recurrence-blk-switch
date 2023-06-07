# USENIX OSDI 2021 Artifact Evaluation

## 1. Hardware Configurations
Our hardware configurations used in the paper are:
- CPU: 4-socket Intel Xeon Gold 6128 3.4GHz with 6 cores per socket (with hyperthreading disabled)
- RAM: 256GB
- NIC: Mellanox ConnectX-5 Ex VPI (100Gbps)
- NVMe SSD: 1.6TB Samsung PM1725a

[**Caveats of our work**]
- Our work has been evaluated with 100Gbps NICs and 4-socket multi-core CPUs. Performance degradation is expected if the above hardware configuration is not available.
- `system_setup.sh` includes Mellanox NIC-specific configuration (e.g., enabling aRFS).
- As described in the paper, we mainly use 6 cores in NUMA0 and their core numbers, 0, 4, 8, 12, 16, 20, are used through the evaluation scripts. These numbers should be changed if the systems have different number of NUMA nodes:
   ```
   lscpu | grep 'CPU(s)'
   
   CPU(s):                24
   On-line CPU(s) list:   0-23
   NUMA node0 CPU(s):     0,4,8,12,16,20
   ...
   ```

## 2. Detailed Instructions
Now we provide how to use our scripts to reproduce the results in the paper. 

**[NOTE]:**
- If you miss the [getting started instruction](https://github.com/resource-disaggregation/blk-switch#getting-started-guide), please complete "Building blk-swith Kernel" section first and come back.
- If you get an error while running the "Run configuration scripts", please reboot the both servers and restart from the "Run configuration scripts" section.

### Run configuration scripts (with root)
You should be root from now on. If you already ran some configuration scripts below while doing the getting started instruction, you **SHOULD NOT** run those scripts -- `target_null.sh`, `host_tcp_null.sh`, and `host_i10_null.sh`.

**(Don't forget to be root)**

1. At Both Target and Host:  
 Please edit `~/blk-switch/scripts/system_env.sh` to specify Target IP address, Network interface name associated with the Target IP address, and number of cores of your system. You can type "lscpu | grep 'CPU(s)'" to get the number of cores of your system.   
 Then run `system_setup.sh`:
   ```
   sudo -s
   cd ~/blk-switch/scripts/
   ./system_setup.sh
    ```
   **NOTE:** `system_setup.sh` enables aRFS on Mellanox ConnextX-5 NICs. For different NICs, you may need to follow a different procedure to enable aRFS (please refer to the NIC documentation). If the NIC does not support aRFS, the results that you observe could be significantly different. (We have not experimented with setups where aRFS is disabled).
   
   The below error messages from `system_setup.sh` is normal. Please ignore them.
   ```
   Cannot get device udp-fragmentation-offload settings: Operation not supported
   Cannot get device udp-fragmentation-offload settings: Operation not supported
   ```

2. At Target:  
 Check if your Target has physical NVMe SSD devices. Type "nvme list" and see if there is any device (e.g., `/dev/nvme0n1`).  
 If your Target does not have any NVMe SSD devices, you should skip `target_ssd.sh` and configure only RAM device (null-blk) with `target_null.sh`.

   ```
   sudo -s
   cd ~/blk-switch/scripts/
   ./target_null.sh
   (Run below only when your system has NVMe SSD)
   ./target_ssd.sh
   ```   
   If you ran `target_null.sh` twice by mistake and got several errors like "Permission denied", please reboot the both servers and restart from "Run configuration scripts".
   
   
3. At Host:  
 Also we will skip `host_tcp_ssd.sh` and `host_i10_ssd.sh` if your Target server does not have physical NVMe SSD devices.
 After running the scripts below, you will see that 2-4 remote storage devices are created (type `nvme list`).

   ```
   sudo -s
   cd ~/blk-switch/scripts/
   ./host_tcp_null.sh
   ./host_i10_null.sh
   (Run below only when your target has NVMe SSD)
   ./host_tcp_ssd.sh
   ./host_i10_ssd.sh
   ```

### Linux and blk-switch Evaluation (with root)
Now you will run evaluation scripts at Host server. We need to identify newly added remote devices to use the right one for each script.  

We assume your Host server now has 4 remote devices that have different '*Namespace number*' as follows:
- `/dev/nvme0n1`: null-blk device for blk-switch (*Namespace: 10*)
- `/dev/nvme1n1`: null-blk device for Linux (*Namespace: 20*)
- `/dev/nvme2n1`: SSD device for blk-switch (*Namespace: 30*)
- `/dev/nvme3n1`: SSD device for Linux (*Namespace: 40*)

Type `nvme list` and check if the device names are matching the Namespace above. If this is your case, then you are safe to go. The default configurations in our scripts are:  

For Figures 7, 8, 9, 11 (null-blk scenario):
- blk-switch: `$nvme_dev = /dev/nvme0n1` (*whose Namespace is 10*)
- Linux: `$nvme_dev = /dev/nvme1n1` (*whose Namespace is 20*)

For Figure 10 (SSD scenario):
- blk-switch:
   - `$nvme_dev = /dev/nvme0n1` (*whose Namespace is 10*)
   - `$ssd_dev = /dev/nvme2n1` (*whose Namespace is 30*)
- Linux:
   - `$nvme_dev = /dev/nvme1n1` (*whose Namespace is 20*)
   - `$ssd_dev = /dev/nvme3n1` (*whose Namespace is 40*)

But if this is not the case for your Host system (e.g., *Namespace 10* is `/dev/nvme1n1`), please EDIT all the scripts below with right device names before running them.

1. Figure 2 (Single-core Linux): Increasing L-app load (5 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig2.pl
   ```

2. Figure 3a (Single-core Linux): Increasing T-app I/O size (5 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig3a.pl
   ```
   
3. Figure 7: Increasing L-app load (6 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig7.pl
   ./blk-switch_fig7.pl
   ```

4. Figure 8: Increasing T-app load (12 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig8.pl
   ./blk-switch_fig8.pl
   ```

5. Figure 9: Varying number of cores (20 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig9.pl
   ./blk-switch_fig9.pl
   ```

6. Figure 10: SSD results corresponding to Figure 7 (6 mins):

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig10.pl
   ./blk-switch_fig10.pl
   ```

7. Figure 11: Increasing read ratio (10 mins):   

   **NOTE:** The scripts below require to ssh Target server without password (for host-side root). Please refer to [this](http://www.linuxproblem.org/art_9.html).   
   And also please edit `~/blk-switch/osdi21_artifact/blk-switch/read_ratio.pl` to modify `$target = "osdi21\@192.168.10.115"`, so that it includes your account name and the Target IP address (i.e., 'account_name@target_ip_address').  

   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./linux_fig11.pl
   ./blk-switch_fig11.pl
   ```

### Figure 13: blk-switch Performance Breakdown (~1 min)
To reproduce Figure 13 results, we will run four experiments named "**Linux**", "**Linux+P**", "**Linux+P+RS**", "**Linux+P+RS+AS**", and "**(Extra)**". The (Extra) is nothing but performed to print out kernel logs as the request-steering logs appear when a new experiment starts.
   ```
   cd ~/blk-switch/osdi21_artifact/blk-switch/
   ./blk-switch_fig13.pl
   ```

After all is done, type "dmesg" to see the kernel logs. The last 6 lines are for "**Linux+P+RS+AS**" (Figure 13f) and the 7th line shows how L-app moves. The next last 6 lines are for "**Linux+P+RS**" (Figure 13e). For each core, the kernel logs mean:
- gen: how many T-app requests are generated on that core.
- str: how many T-app requests are steered to other cores on that core.
- prc: how many T-app requests came from other cores are processed on that core.


[Note] The log messages are not in the order of core number; please check the core number of each log message. Please ignore the result showing '0'.

### Other Systems
In our paper, we also evaluate against two other systems, SPDK and Caladan, as baselines.
Instructions to setup and run our evaluation experiments on these systems are available in the READMEs in spdk/ and caladan/ folders repsectively.

#### SPDK
Refer to README in [spdk/](spdk/) directory.

#### Caladan
Refer to README in [caladan/](caladan/) directory.

