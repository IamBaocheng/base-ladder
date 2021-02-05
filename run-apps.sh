# check ss-config.json
if [ -e ss-config.json ]
then
    # check kcptun-config.json
    if [ -e kcptun-config.json ]
    then
        echo "Shadowsocks w/ kcptun"
        kcptun -c kcptun-config.json &
    else
        echo "Shadowsocks Directly w/o kcptun"
    fi
    sslocal -c ss-config.json &
    privoxy --no-daemon /etc/privoxy/config
else
    sslocal --help
    kcptun --help
    echo "At least a ss-config.json is needed"
fi

