# Log Location on Server
LOG_LOCATION=~/
exec > >(tee -i $LOG_LOCATION/aaaaa.log)
exec 2>&1

echo "correct is called..."


