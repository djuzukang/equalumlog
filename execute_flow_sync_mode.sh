#!/bin/bash

if [[ -z $1 ]]; then
        echo "This script executes a flow in \"batch\" mode. It accepts a flow-id optionally followed by additional eqengine execute-flow arguments. For example:"
        echo "`basename $0` 1005 "
        echo "or"
        echo "`basename $0` 1005 override-flowVariables.var1=my_value perf-parallelism=1"
        exit 1
fi

SLEEP_INTERVAL_SEC=30
FLOWS_MANAGER_STATUS=`eqengine flows-manager status | grep -o "Flows\-Manager Status.*"`
FLOWS_MANAGER_STATUS=`echo $FLOWS_MANAGER_STATUS | awk '{print $NF}'`
if [[ $FLOWS_MANAGER_STATUS != "active" ]]; then
        echo "Flows-Manager's status is not active, cannot execute flow, exiting..."
        exit 1
fi
COUNT=1
STATUS=false
FLOW_ID=$1
ADDITIONAL_OPTIONS=$2
EXECUTION_ID=`eqengine execute-flow flow-id=$FLOW_ID $ADDITIONAL_OPTIONS mode=batch | grep "execution id"`
EXECUTION_ID=`echo $EXECUTION_ID | awk '{print $NF}'`

echo "Getting execution status for execution-id: $EXECUTION_ID..."
while [[ $STATUS != "cancel" ]] && [[ $STATUS != "failed" ]] && [[ $STATUS != "done" ]]; do
        #echo "Poll #$COUNT"
        STATUS=`eqengine get-execution-status $EXECUTION_ID | grep "Execution Status"`
        STATUS=`echo $STATUS | awk '{print $NF}'`
        sleep $SLEEP_INTERVAL_SEC
        ((COUNT++))
done

echo "Execution $EXECUTION_ID has finished with status: $STATUS"
if [[ $STATUS == "cancel" ]] || [[ $STATUS == "failed" ]]; then
        exit 1
else
        exit 0
fi
