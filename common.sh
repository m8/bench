#!/bin/bash

function common_benchmark_performance 
{
    common_mem_disable_va_randomization
    # This enables to achieve the peak CPU freq
    common_cpu_turboboost_enable
    common_cpu_performance_max
}

# $1: file
# $2: value
function common_set_file
{
    local time=$(date +%Y%m%d_%H%M%S)
    local file=$1
    local value=$2
    local updates_files="/tmp/file_updates.log"
    local old_value=$(cat $file 2>/dev/null)
    echo "[$time] $file: $old_value -> $value" >> $updates_files
    echo $value | sudo tee $file >/dev/null 2>&1
}



# ======================================
# Memory
# ======================================
function common_machine_mem_on_node 
{
    local node=$1
    sudo numactl --hardware | grep "node $node free" | awk '{print $4}'
}

function common_machine_mem_offline_on_node 
{
    local node=$1
    echo 0 | sudo tee /sys/devices/system/node/node$node/memory*/online >/dev/null 2>&1
}

function common_machine_mem_online_on_node 
{
    local node=$1
    echo 1 | sudo tee /sys/devices/system/node/node$node/memory*/online >/dev/null 2>&1
}

function common_mem_disable_va_randomization
{
    echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
}

function common_mem_enable_va_randomization
{
    echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
}

function common_mem_thp_disable
{
    echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
    echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
}

function common_mem_thp_enable
{
    echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
}

function common_mem_thp_madvise
{
    echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
}

# $1: nodes seperated by :
function common_mem_interleave_set
{
    local weights=($(echo $1 | tr ':' '\n'))
    for i in $(seq 0 $((${#weights[@]} - 1))); do
        echo ${weights[$i]} | sudo tee /sys/kernel/mm/mempolicy/weighted_interleave/node$i
    done
}

function common_mem_interleave_get
{
    local available_nodes=$(ls /sys/kernel/mm/mempolicy/weighted_interleave/node* | wc -l)
    for i in $(seq 0 $(($available_nodes - 1))); do
        echo "Node $i: $(cat /sys/kernel/mm/mempolicy/weighted_interleave/node$i)"
    done
}


# ======================================
# CPU
# ======================================
function common_machine_cpu_offline_on_node 
{
    echo 0 | sudo tee /sys/devices/system/node/node$1/cpu*/online >/dev/null 2>&1
}

function common_machine_cpu_online_on_node  
{
    echo 1 | sudo tee /sys/devices/system/node/node$1/cpu*/online >/dev/null 2>&1
}

function common_cpu_set_freq 
{
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
}

function common_cpu_performance_max 
{
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    echo 2600000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
}

function common_cpu_performance_normal 
{
    sudo cpupower frequency-set --governor powersave
}

function common_cpu_turboboost_disable 
{
    echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
}

function common_cpu_turboboost_enable 
{
    echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
}

# ======================================
# NUMA
# ======================================
function common_numa_disable_tiering 
{
    echo 0 | sudo tee /sys/kernel/mm/numa/demotion_enabled
    echo 0 | sudo tee /proc/sys/kernel/numa_balancing
    echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode
}

function common_numa_enable_tiering 
{
    #!/bin/bash
    # Enables tpp for the machine
    sudo swapoff -a
    sudo sysctl -w vm.drop_caches=3
    sync;

    # Enable tiering
    echo 1 | sudo tee /sys/kernel/mm/numa/demotion_enabled
    echo 2 | sudo tee /proc/sys/kernel/numa_balancing
    echo 1 | sudo tee /proc/sys/vm/zone_reclaim_mode

    # Disable MGLRU
    # mm: vmscan : pgdemote vmstat is not getting updated when MGLRU is enabled.
    # enabled is 0x007
    echo 0x000 | sudo tee /sys/kernel/mm/lru_gen/enabled
}

function common_numa_print_settings 
{
    echo "NUMA settings:"
    echo "numa_balancing: $(cat /proc/sys/kernel/numa_balancing)"
    echo "numa_demotion: $(cat /sys/kernel/mm/numa/demotion_enabled)"
    echo "zone_reclaim_mode: $(cat /proc/sys/vm/zone_reclaim_mode)"
    echo "lru_gen: $(cat /sys/kernel/mm/lru_gen/enabled)"
}

# $1: Node 0
# $2: Node 1
# $3: Ratio of node 0
# $4: Ratio of node 1
# returns numactl command
function common_numa_set_weighted_interleave
{
    if [ $3 -eq 0 ]; then
        echo "numactl --membind=$2"
    elif [ $4 -eq 0 ]; then
        echo "numactl --membind=$1"
    else
        echo $3 | sudo tee /sys/kernel/mm/mempolicy/weighted_interleave/node$1 >/dev/null 2>&1
        echo $4 | sudo tee /sys/kernel/mm/mempolicy/weighted_interleave/node$2 >/dev/null 2>&1
        echo "numactl --weighted-interleave=$1,$2"
    fi
}



# ======================================
# Prefetcher
# ======================================
PREFETCH_REGISTER=0x1a4
PREFETCH_DEFAULT_VAL=0x20

function common_cpu_prefetcher_enable 
{    
    sudo wrmsr -a $PREFETCH_REGISTER $PREFETCH_DEFAULT_VAL
}

function common_cpu_prefetcher_disable 
{
    sudo wrmsr -a $PREFETCH_REGISTER 0x3f
}

# ======================================
# Boot
# ======================================
function common_print_kernel 
{
    sudo grub-mkconfig | grep -iE "menuentry 'Ubuntu, with Linux" | awk '{print i++ " : "$1, $2, $3, $4, $5, $6, $7}' 
}

function common_set_kernel 
{
    if [ -z "$1" ]; then
        echo "Error: Kernel version is empty."
        exit 1
    fi

    #sudo grub-mkconfig | grep -iE "menuentry 'Ubuntu, with Linux" | awk '{print i++ " : "$1, $2, $3, $4, $5, $6, $7}'
    local a=$(sudo grub-mkconfig | grep -iE "menuentry 'Ubuntu, with Linux" | awk '{print i++ " : "$1, $2, $3, $4, $5, $6, $7}' | grep $1 | awk '{printf $1}')
    new_ent="GRUB_DEFAULT=\"1>${a}\""
    echo $new_ent
    sleep 10
    cp /etc/default/grub grub.bk
    sudo sed -i 's/^GRUB_DEFAULT=.*/'"$new_ent"'/' /etc/default/grub
    sudo update-grub
}

# ======================================
# SSH 
# ======================================
ssh_user="ubuntu"
ssh_pass="1234"
ssh_port=4445
ssh_host="localhost"

function ssh_exec 
{
    local cmd=$1
    sshpass -p $ssh_pass ssh -p $ssh_port $ssh_user@$ssh_host "$1"
}

# ======================================
# Helpers
# ======================================
# $1: Total memory
# $2: Ratio (ex: 1:1)
function common_calc_mem_ratio 
{
    local total_mem=$1
    local ratio=$2
    local mem1=$(echo $ratio | cut -d':' -f1)
    local mem2=$(echo $ratio | cut -d':' -f2)
    local mem1_bytes=$(echo "$total_mem * $mem1 / ($mem1 + $mem2)" | bc)
    local mem2_bytes=$(echo "$total_mem * $mem2 / ($mem1 + $mem2)" | bc)
    echo "$mem1_bytes $mem2_bytes"
}

function common_disable_background_works 
{
    # Container stuff
    sudo systemctl stop docker.socket
    sudo systemctl stop docker
    sudo killall containerd
    sudo killall dockerd
    sudo systemctl stop containerd.socket
    sudo systemctl stop container
    sudo systemctl stop snapd.socket
    sudo systemctl stop snapd

    # Kill vscode server
    ps uxa | grep .vscode-server | awk '{print $2}' | xargs kill -9

    # Kill libvirtd
    sudo systemctl stop libvirtd.socket
    sudo systemctl stop libvirtd
    sudo killall libvirtd

    # Drop caches
    echo 3 | sudo tee /proc/sys/vm/drop_caches
}


function common_machine_details 
{
    echo "----------------"
    echo "Machine details:"
    echo "Host: $(hostname)"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "Cores: $(lscpu | grep 'CPU(s):' | awk '{print $2}')"
    echo "Kernel: $(uname -r)"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Performance governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    echo "Scaling min frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)"
    echo "Scaling max frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)"
    echo "Transparent Huge Pages: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
    echo "Numa hardware: $(numactl --hardware)"
    echo "Prefetcher at core 0:" $(sudo rdmsr 0x1a4)
    lscpu
    echo "----------------"
    common_sysctl_print
}

function common_sysctl_print
{
    echo "Sysctl settings:"
    sudo sysctl -a | grep -v "net\."
    echo "----------------"
}


function common_set_perf_event_paranoid 
{
    echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
    echo 0 | sudo tee /proc/sys/kernel/kptr_restrict
    sudo sysctl -w 'kernel.nmi_watchdog=0'
}


# ======================================
# Setups
# ======================================
INSTALL_DIR="/scratch/musa/installs"

function common_setup_ocperf
{   
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    git clone https://github.com/andikleen/pmu-tools
    
    echo "export PATH=$INSTALL_DIR/pmu-tools:$PATH" >> ~/.bashrc
    echo "export PATH=$INSTALL_DIR/pmu-tools:$PATH" >> ~/.zshrc


    common_set_perf_event_paranoid

    echo "source ~/.zshrc"

    popd    
}

function common_setup_pcm
{
    mkdir -p $INSTALL_DIR && cd $INSTALL_DIR

    git clone --recursive https://github.com/intel/pcm
    cd pcm && mkdir build && cd build
    cmake ..
    cmake --build . --parallel

    echo "export PATH=$INSTALL_DIR/pcm:$PATH" >> ~/.bashrc
    echo "export PATH=$INSTALL_DIR/pcm:$PATH" >> ~/.zshrc

    echo "source ~/.bashrc"
    popd
}

function common_setup_cat
{
    # Monitor mem-bandwidth of a program: sudo ./pqos/pqos -I -p 'mbl:9738'
    mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
    git clone https://github.com/intel/intel-cmt-cat
    cd intel-cmt-cat
    make -j
}

function common_setup_mlc 
{
    mkdir -p $INSTALL_DIR/mlc
    pushd $INSTALL_DIR/mlc

    if [ ! -f mlc_v3.10.tgz ]; then
        wget https://downloadmirror.intel.com/763324/mlc_v3.10.tgz
        tar -xvf mlc_v3.10.tgz
    fi

    echo "$INSTALL_DIR/mlc/Linux/mlc"
    popd
}

# ======================================
# Cgroup
# ======================================
function common_cgroup_create 
{
    sudo cgcreate -a $USER:$USER -g memory:memgroup -t $USER:$USER
    sudo chmod o+w /sys/fs/cgroup/cgroup.procs
}

# $1: Memory limit in GB
function common_cgroup_memory_high_set
{
    local mem_limit=$(echo "$1 * 1024 * 1024 * 1024" | bc)
    echo $mem_limit | sudo tee /sys/fs/cgroup/memgroup/memory.high
}

# $1: Memory limit in GB
function common_cgroup_memory_max_set
{
    local mem_limit=$(echo "$1 * 1024 * 1024 * 1024" | bc)
    echo $mem_limit | sudo tee /sys/fs/cgroup/memgroup/memory.max
}

function common_cgroup_get_stats
{
    # get pgdemote_direct, pgdemote_kswapd, pgdemote_direct_failed, pgpromote_success, pgscan, pgscan_kswapd, pgscan_direct
    echo -e $(cgget -g memory:memgroup/ | grep -iE "pgdemote_direct|pgdemote_kswapd|pgdemote_direct_failed|pgpromote_success|pgscan|pgscan_kswapd|pgscan_direct" | awk '{printf "%s %s\\n",$1,$2}')
}


# ======================================
# Helpers
# ======================================
function common_folders()
{
    echo $(ls -d -- */)
}

