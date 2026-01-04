# Triển khai thông báo của cụm ceph về telegram

Cần 1 node Relay để đảm bảo an toàn

# 1. Trên node relay

```zsh
docker run -d \
  --name telegram-webhook \
  -p 9119:9119 \
  -e TG_CHAT_ID="-5000713182" \
  -e TG_BOT_TOKEN="6073261344:AAEWZ83zFaVYEXW_vAQB0jLiNyl2pmV-E5k" \
  -e BASIC_AUTH_USERNAME="admin" \
  -e BASIC_AUTH_PASSWORD="JW5pdkGoexgjGLnk" \
  papko26/alertmanager-webhook-telegram:v5
```


# 2. Trên node ceph

```zsh
ceph orch apply prometheus --placement 'count:3'
ceph orch apply grafana --placement 'count:3'
ceph orch apply alertmanager --placement 'count:3'
```

Alertmanager:

```zsh
nano /tmp/alertmanager-add-telegram.yml.j2
```

```zsh
ceph config-key set mgr/cephadm/services/alertmanager/alertmanager.yml -i /tmp/alertmanager-add-telegram.yml.j2
```

```zsh
{% raw %}
{{ upstream | indent(0) }}

# ---- thêm phần Telegram relay receiver ----
receivers:
{{- with upstream.receivers }}
{{ to_yaml . | indent(2) }}
{{- end }}

- name: webhook-relay
  webhook_configs:
  - url: "http://10.30.30.73:9119/alert"
    send_resolved: true
    http_config:
      basic_auth:
        username: "admin"
        password: "JW5pdkGoexgjGLnk"

# ---- thêm route mới để gửi tất cả alert tới webhook-relay ----
{{ $oldRoutes := upstream.route.routes }}
route:
  receiver: ceph-dashboard
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

  routes:
  {{- range $oldRoutes }}
  - {{ to_yaml . | trim | indent(4) }}
  {{- end }}

  - receiver: webhook-relay
    match_re:
      alertname: ".*"
    group_wait: 10s
    group_interval: 10s
    repeat_interval: 1h
{% endraw %}
```


```zsh
ceph orch reconfig alertmanager
```


Prometheus:

```zsh
ceph orch reconfig prometheus
```

```zsh
groups:
- name: custom-ceph-osd
  rules:
  - alert: CephOSDDownDetailed
    expr: ceph_osd_up == 0
    # nếu muốn báo "ngay" khi metric thấy down, đặt for: 0m hoặc bỏ for
    labels:
      severity: critical
    annotations:
      summary: "OSD {{ $labels.ceph_daemon }} down"
      description: "OSD {{ $labels.ceph_daemon }} (instance={{ $labels.instance }}) is down. Check 'ceph osd tree' and 'ceph -s'."
```

```zsh
nano /tmp/am-with-relay.yml
```

```zsh
global:
  resolve_timeout: 5m

route:
  receiver: default
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

  routes:
  - receiver: ceph-dashboard
    group_by:
      - alertname
      - severity
      - instance
    continue: true
    group_wait: 10s
    group_interval: 10s
    repeat_interval: 1h

  - receiver: webhook-relay
    group_by:
      - alertname
      - severity
      - instance
    group_wait: 10s
    group_interval: 10s
    repeat_interval: 1h

receivers:
- name: default

- name: ceph-dashboard
  webhook_configs:
  - send_resolved: true
    url: https://s3-ceph01:8443/api/prometheus_receiver
    http_config:
      tls_config:
        insecure_skip_verify: true
  - send_resolved: true
    url: https://s3-ceph02:8443/api/prometheus_receiver
    http_config:
      tls_config:
        insecure_skip_verify: true
  - send_resolved: true
    url: https://s3-ceph03:8443/api/prometheus_receiver
    http_config:
      tls_config:
        insecure_skip_verify: true

- name: webhook-relay
  webhook_configs:
  - url: "http://10.30.30.73:9119/alert"
    send_resolved: true
    http_config:
      basic_auth:
        username: "admin"
        password: "JW5pdkGoexgjGLnk"

templates: []
```


```zsh
ceph config-key set mgr/cephadm/services/alertmanager/alertmanager.yml -i /tmp/am-with-relay.yml

ceph orch reconfig alertmanager
```

