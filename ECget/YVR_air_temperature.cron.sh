# cron script to download hourly YVR air temperature data for SOG
#
# make sure that this file has mode 744
# and that MAILTO is set in crontab

VENV=/data/dlatorne/.virtualenvs/ecget
RUN_DIR=/data/dlatorne/SOG-projects/SOG-forcing/ECget

cd $RUN_DIR && . $VENV/bin/activate && $VENV/bin/ecget air temperature -q >> $RUN_DIR/YVR_air_temperature
