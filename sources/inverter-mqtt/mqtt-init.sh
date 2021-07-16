##!/bin/bash
#
# Simple script to register the MQTT topics when the container starts for the first time...

MQTT_SERVER=`cat /etc/inverter/mqtt.json | jq '.server' -r`
MQTT_PORT=`cat /etc/inverter/mqtt.json | jq '.port' -r`
MQTT_TOPIC=`cat /etc/inverter/mqtt.json | jq '.topic' -r`
MQTT_DEVICENAME=`cat /etc/inverter/mqtt.json | jq '.devicename' -r`
MQTT_MANUFACTURER=`cat /etc/inverter/mqtt.json | jq '.manufacturer' -r`
MQTT_MODEL=`cat /etc/inverter/mqtt.json | jq '.model' -r`
MQTT_SERIAL=`cat /etc/inverter/mqtt.json | jq '.serial' -r`
MQTT_VER=`cat /etc/inverter/mqtt.json | jq '.ver' -r`
MQTT_USERNAME=`cat /etc/inverter/mqtt.json | jq '.username' -r`
MQTT_PASSWORD=`cat /etc/inverter/mqtt.json | jq '.password' -r`

registerTopic () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
	-i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
        -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1/config" \
        -r \
        -m "{
            \"name\": \"$1_"$MQTT_DEVICENAME"\",
            \"uniq_id\": \""$MQTT_SERIAL"_$1\",
            \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
            \"unit_of_meas\": \"$2\",
            \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1\",
            \"icon\": \"mdi:$3\"
        }"
}

registerInverterRawCMD () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/COMMANDS/config" \
		-r \
        -m "{
            \"name\": \""$MQTT_DEVICENAME"_COMMANDS\",
            \"uniq_id\": \""$MQTT_DEVICENAME"_"$MQTT_SERIAL"\",
            \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
            \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/COMMANDS\"
	    }"
}

registerTopic "AC_grid_voltage" "V" "power-plug"
registerTopic "AC_grid_frequency" "Hz" "current-ac"
registerTopic "AC_out_voltage" "V" "power-plug"
registerTopic "AC_out_frequency" "Hz" "current-ac"
registerTopic "PV_in_voltage" "V" "solar-panel-large"
registerTopic "PV_in_current" "A" "solar-panel-large"
registerTopic "PV_in_watts" "W" "solar-panel-large"
registerTopic "PV_in_watthour" "Wh" "solar-panel-large"
registerTopic "SCC_voltage" "V" "current-dc"
registerTopic "Load_pct" "%" "brightness-percent"
registerTopic "Load_watt" "W" "chart-bell-curve"
registerTopic "Load_watthour" "Wh" "chart-bell-curve"
registerTopic "Load_va" "VA" "chart-bell-curve"
registerTopic "Bus_voltage" "V" "details"
registerTopic "Heatsink_temperature" "" "details"
registerTopic "Battery_capacity" "%" "battery-outline"
registerTopic "Battery_voltage" "V" "battery-outline"
registerTopic "Battery_charge_current" "A" "current-dc"
registerTopic "Battery_discharge_current" "A" "current-dc"
registerTopic "Load_status_on" "" "power"
registerTopic "SCC_charge_on" "" "power"
registerTopic "AC_charge_on" "" "power"
registerTopic "Battery_recharge_voltage" "V" "current-dc"
registerTopic "Battery_under_voltage" "V" "current-dc"
registerTopic "Battery_bulk_voltage" "V" "current-dc"
registerTopic "Battery_float_voltage" "V" "current-dc"
registerTopic "Max_grid_charge_current" "A" "current-ac"
registerTopic "Max_charge_current" "A" "current-ac"
registerTopic "Mode" "" "solar-power" # 1 = Power_On, 2 = Standby, 3 = Line, 4 = Battery, 5 = Fault, 6 = Power_Saving, 7 = Unknown
registerTopic "Out_source_priority" "" "grid"
registerTopic "Charger_source_priority" "" "solar-power"
registerTopic "Battery_redischarge_voltage" "V" "battery-negative"

# Add in a separate topic so we can send raw commands from assistant back to the inverter via MQTT (such as changing power modes etc)...
registerInverterRawCMD
