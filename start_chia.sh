#!/bin/bash

CHIA_DIR=/home/warren/Documents/chia-blockchain
DRY_RUN=true
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-t|--thread)
			THREAD="$2"
			shift
			shift
			;;
		-d|--dir)
			CHIA_DIR="$2"
			shift
			shift
			;;
		-p|--prod)
			DRY_RUN=false
			shift
			;;
	esac
done

if [ -z ${THREAD} ]
then
	echo "ID is unset, exit"
	return 0
fi

echo "Number of threads: $THREAD"
echo "Chia blockchain absolute path: $CHIA_DIR"
echo "Is dry run mode: $DRY_RUN"  

for ((i=i;i<$THREAD;i++))
do

SESSION_NAME=test$i
echo "Session name is: $SESSION_NAME"

# Open a new tmux session in the back ground
tmux new -s $SESSION_NAME -d

# Open chia blockchain folder
tmux send -t $SESSION_NAME "cd $CHIA_DIR" ENTER

# Start chia
if [ "$DRY_RUN" = true ]
then
	echo "====== execute command ======"
	echo ". ./activate && sleep ${THREAD}h && chia plots create -k 32 -b 6500 -e -r 2 -u 128 -n 8 -t /mnt/ssd0/tmp${THREAD} -d /mnt/hdd2/chia_final |tee /home/warren/Documents/chialogs/chia${THREAD}.log"
	echo "============ end ============"
	tmux kill-session -t $SESSION_NAME
else
	# Clean up temp folder, it might contains residual.
	rm -r /mnt/ssd/tmp$ID
	mkdir -p /mnt/ssd0/tmp$ID
	mkdir -p $CHIA_DIR/chialogs
	tmux send -t $SESSION_NAME ". ./activate && sleep ${THREAD}h && chia plots create -k 32 -b 6500 -e -r 2 -u 128 -n 8 -t /mnt/ssd0/tmp${THREAD} -d /mnt/hdd2/chia_final |tee ${CHIA_DIR}/chialogs/chia${THREAD}.log" ENTER
fi

done
