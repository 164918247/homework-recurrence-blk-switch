#!/usr/bin/perl

######################################
# Figure 11 setting
######################################
@read_ratio = (0, 25, 50, 75, 100);

######################################
# Linux setting
######################################
$nvme_dev = "/dev/nvme1n1";
$tapp_bs = "64k";
$tapp_qd = 32;
$prio_on = 0;

######################################
# script variables
######################################
$n_input = @read_ratio;
$repeat = 1;

# Run
system("echo 0 > /sys/module/blk_mq/parameters/blk_switch_on");
print("## Figure 11. Linux ##\n\n");

for($i=0; $i<$n_input; $i++)
{
        for($j=0; $j<$repeat; $j++)
        {
                system("./read_ratio.pl $nvme_dev $tapp_bs $tapp_qd $read_ratio[$i] $prio_on");
        }
}

print("All done.\n");
