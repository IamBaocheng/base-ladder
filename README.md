# base-ladder

integrated SS, KCPTUN and privoxy

run SS with KCPTUN:
```bash
docker run -v /path/to/ss-config.json:/app/ss-config.json \
    -v /path/to/kcptun-config.json:/app/kcptun-config.json \
    -p 5001:1080 -p 5001:1080/udp -p 6001:8118 -d --restart=always --name ss-xxxx base-ladder
```

run SS only:
```bash
docker run -v /path/to/ss-config.json:/app/ss-config.json \
    -p 5001:1080 -p 5001:1080/udp -p 6001:8118 -d --restart=always --name ss-xxxx base-ladder
```
