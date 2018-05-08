
# Rook Performance tests

## Prerequisites

### Build fio in docker

```
cd fio
docker build -t alex202/fio:3.6.4 .
docker push alex202/fio:3.6.4
cd ..
```

### Additional components

In Azure only:

Install

```
sudo apt install -qy ceph-common ceph-fs-common
```

on every node in cluster


## Rook Setup

Make 

    cd aws 
    
or

    cd azr
    
depending in what cluster you are working.

Do the following steps:

1. Install rook operator

    kubectl apply -f rook-operator.yaml


2. Watch rook-operator logs

    kubectl logs -f -n rook-system <rook-operator-pod>
    
3. Install rook cluster

    helm install -n rook --namespace rook -f rook-filefs.yaml ../app-rook
    
Make sure that node-selector and affinity values correspond your cluster labels.
    
Setup will take some time, afret that rook-operator log should be like
    
```
2018-05-08 07:48:46.803346 I | rook: starting Rook v0.7.1 with arguments '/usr/local/bin/rook operator'
2018-05-08 07:48:46.803385 I | rook: flag values: --help=false, --log-level=INFO, --mon-healthcheck-interval=45s, --mon-out-timeout=5m0s
2018-05-08 07:48:46.804043 I | rook: starting operator
2018-05-08 07:48:49.465892 I | op-k8sutil: cluster role rook-agent already exists. Updating if needed.
2018-05-08 07:48:49.484286 I | op-agent: getting flexvolume dir path from FLEXVOLUME_DIR_PATH env var
2018-05-08 07:48:49.484299 I | op-agent: flexvolume dir path env var FLEXVOLUME_DIR_PATH is not provided. Defaulting to: /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
2018-05-08 07:48:49.484303 I | op-agent: discovered flexvolume dir path from source default. value: /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
2018-05-08 07:48:49.493207 I | op-agent: rook-agent daemonset started
2018-05-08 07:48:49.495087 I | operator: rook-provisioner started
2018-05-08 07:48:49.495101 I | op-cluster: start watching clusters in all namespaces
2018-05-08 08:04:19.351850 I | op-cluster: starting cluster in namespace rook
2018-05-08 08:04:25.367538 I | op-mon: start running mons
2018-05-08 08:04:25.369611 I | exec: Running command: ceph-authtool --create-keyring /var/lib/rook/rook/mon.keyring --gen-key -n mon. --cap mon 'allow *'
2018-05-08 08:04:25.388695 I | exec: Running command: ceph-authtool --create-keyring /var/lib/rook/rook/client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mgr 'allow *' --cap mds 'allow'
2018-05-08 08:04:25.413734 I | op-mon: creating mon secrets for a new cluster
2018-05-08 08:04:25.426543 I | op-mon: saved mon endpoints to config map map[data: maxMonId:-1 mapping:{"node":{},"port":{}}]
2018-05-08 08:04:25.426743 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:25.426816 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:25.445563 I | op-mon: Found 6 running nodes without mons
2018-05-08 08:04:25.461698 I | op-mon: mon rook-ceph-mon0 running at 10.0.196.217:6790
2018-05-08 08:04:25.470809 I | op-mon: saved mon endpoints to config map map[data:rook-ceph-mon0=10.0.196.217:6790 maxMonId:2 mapping:{"node":{"rook-ceph-mon0":{"Name":"ip-172-21-49-176.ec2.internal","Hostname":"ip-172-21-49-176","Address":"172.21.49.176"},"rook-ceph-mon1":{"Name":"ip-172-21-52-185.ec2.internal","Hostname":"ip-172-21-52-185","Address":"172.21.52.185"},"rook-ceph-mon2":{"Name":"ip-172-21-55-61.ec2.internal","Hostname":"ip-172-21-55-61","Address":"172.21.55.61"}},"port":{}}]
2018-05-08 08:04:25.470997 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:25.471076 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:25.471451 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:25.471522 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:25.479931 I | op-mon: mons created: 1
2018-05-08 08:04:25.479948 I | op-mon: waiting for mon quorum
2018-05-08 08:04:25.480001 I | exec: Running command: ceph mon_status --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/956404946
2018-05-08 08:04:35.653016 I | op-mon: Ceph monitors formed quorum
2018-05-08 08:04:35.684878 I | op-mon: mon rook-ceph-mon0 running at 10.0.196.217:6790
2018-05-08 08:04:35.697143 I | op-mon: mon rook-ceph-mon1 running at 10.6.209.180:6790
2018-05-08 08:04:35.708071 I | op-mon: saved mon endpoints to config map map[data:rook-ceph-mon0=10.0.196.217:6790,rook-ceph-mon1=10.6.209.180:6790 maxMonId:2 mapping:{"node":{"rook-ceph-mon0":{"Name":"ip-172-21-49-176.ec2.internal","Hostname":"ip-172-21-49-176","Address":"172.21.49.176"},"rook-ceph-mon1":{"Name":"ip-172-21-52-185.ec2.internal","Hostname":"ip-172-21-52-185","Address":"172.21.52.185"},"rook-ceph-mon2":{"Name":"ip-172-21-55-61.ec2.internal","Hostname":"ip-172-21-55-61","Address":"172.21.55.61"}},"port":{}}]
2018-05-08 08:04:35.708288 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:35.708358 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:35.708812 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:35.708892 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:35.716256 I | op-mon: replicaset rook-ceph-mon0 already exists
2018-05-08 08:04:35.722141 I | op-mon: mons created: 2
2018-05-08 08:04:35.722153 I | op-mon: waiting for mon quorum
2018-05-08 08:04:35.722211 I | exec: Running command: ceph mon_status --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/637645321
2018-05-08 08:04:35.892016 W | op-mon: failed to find initial monitor rook-ceph-mon1 in mon map
2018-05-08 08:04:40.892227 I | exec: Running command: ceph mon_status --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/978686932
2018-05-08 08:04:42.369699 I | op-mon: Ceph monitors formed quorum
2018-05-08 08:04:42.441216 I | op-mon: mon rook-ceph-mon0 running at 10.0.196.217:6790
2018-05-08 08:04:42.463254 I | op-mon: mon rook-ceph-mon1 running at 10.6.209.180:6790
2018-05-08 08:04:42.475514 I | op-mon: mon rook-ceph-mon2 running at 10.6.141.55:6790
2018-05-08 08:04:42.486536 I | op-mon: saved mon endpoints to config map map[data:rook-ceph-mon0=10.0.196.217:6790,rook-ceph-mon1=10.6.209.180:6790,rook-ceph-mon2=10.6.141.55:6790 maxMonId:2 mapping:{"node":{"rook-ceph-mon0":{"Name":"ip-172-21-49-176.ec2.internal","Hostname":"ip-172-21-49-176","Address":"172.21.49.176"},"rook-ceph-mon1":{"Name":"ip-172-21-52-185.ec2.internal","Hostname":"ip-172-21-52-185","Address":"172.21.52.185"},"rook-ceph-mon2":{"Name":"ip-172-21-55-61.ec2.internal","Hostname":"ip-172-21-55-61","Address":"172.21.55.61"}},"port":{}}]
2018-05-08 08:04:42.486745 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:42.486812 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:42.487441 I | cephmon: writing config file /var/lib/rook/rook/rook.config
2018-05-08 08:04:42.487507 I | cephmon: generated admin config in /var/lib/rook/rook
2018-05-08 08:04:42.494853 I | op-mon: replicaset rook-ceph-mon0 already exists
2018-05-08 08:04:42.501204 I | op-mon: replicaset rook-ceph-mon1 already exists
2018-05-08 08:04:42.507517 I | op-mon: mons created: 3
2018-05-08 08:04:42.507530 I | op-mon: waiting for mon quorum
2018-05-08 08:04:42.507576 I | exec: Running command: ceph mon_status --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/143757091
2018-05-08 08:04:42.676558 W | op-mon: failed to find initial monitor rook-ceph-mon2 in mon map
2018-05-08 08:04:47.676764 I | exec: Running command: ceph mon_status --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/981373478
2018-05-08 08:04:48.838814 I | op-mon: Ceph monitors formed quorum
2018-05-08 08:04:48.882031 I | op-cluster: creating initial crushmap
2018-05-08 08:04:48.882047 I | cephclient: setting crush tunables to firefly
2018-05-08 08:04:48.882102 I | exec: Running command: ceph osd crush tunables firefly --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format plain --out-file /tmp/819349837
2018-05-08 08:04:49.074442 I | exec: adjusted tunables profile to firefly
2018-05-08 08:04:49.074509 I | cephclient: succeeded setting crush tunables to profile firefly: 
2018-05-08 08:04:49.074591 I | exec: Running command: crushtool -c /tmp/091197512 -o /tmp/062956807
2018-05-08 08:04:49.088345 I | exec: Running command: ceph osd setcrushmap -i /tmp/062956807 --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/660054714
2018-05-08 08:04:50.120143 I | exec: 3
2018-05-08 08:04:50.120254 I | op-cluster: created initial crushmap
2018-05-08 08:04:50.126077 I | op-mgr: start running mgr
2018-05-08 08:04:50.128331 I | exec: Running command: ceph auth get-or-create-key mgr.rook-ceph-mgr0 mon allow * --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/182604497
2018-05-08 08:04:50.323456 I | exec: Running command: ceph mgr module enable prometheus --force --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/223702524
2018-05-08 08:04:50.529913 I | op-mgr: rook-ceph-mgr0 service started
2018-05-08 08:04:50.541150 I | op-mgr: rook-ceph-mgr0 deployment started
2018-05-08 08:04:50.541167 I | op-api: starting the Rook api
2018-05-08 08:04:50.569868 I | op-api: API service running at 10.7.198.12:8124
2018-05-08 08:04:50.582799 I | op-k8sutil: creating role rook-api in namespace rook
2018-05-08 08:04:50.613175 I | op-api: api deployment started
2018-05-08 08:04:50.613191 I | op-osd: start running osds in namespace rook
2018-05-08 08:04:50.619598 I | op-k8sutil: creating role rook-ceph-osd in namespace rook
2018-05-08 08:04:50.667131 I | exec: Running command: ceph osd set noscrub --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/972971307
2018-05-08 08:04:51.553934 I | exec: noscrub is set
2018-05-08 08:04:51.554036 I | exec: Running command: ceph osd set nodeep-scrub --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/069648526
2018-05-08 08:04:52.541385 I | exec: nodeep-scrub is set
2018-05-08 08:04:52.582705 I | op-osd: osd daemon set started
2018-05-08 08:04:52.582782 I | exec: Running command: ceph osd unset noscrub --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/343424661
2018-05-08 08:04:53.571266 I | exec: noscrub is unset
2018-05-08 08:04:53.571378 I | exec: Running command: ceph osd unset nodeep-scrub --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/649528048
2018-05-08 08:04:54.574585 I | exec: nodeep-scrub is unset
2018-05-08 08:04:54.574659 I | op-cluster: Done creating rook instance in namespace rook
2018-05-08 08:04:54.582269 I | op-pool: start watching pool resources in namespace rook
2018-05-08 08:04:54.582284 I | op-object: start watching object store resources in namespace rook
2018-05-08 08:04:54.582290 I | op-file: start watching filesystem resource in namespace rook
2018-05-08 08:04:54.589661 I | op-cluster: added finalizer to cluster rook
2018-05-08 08:04:54.589765 I | op-cluster: update event for cluster rook
2018-05-08 08:04:54.589780 I | op-cluster: update event for cluster rook is not supported
2018-05-08 08:04:54.589789 I | op-cluster: update event for cluster rook
2018-05-08 08:04:54.589794 I | op-cluster: update event for cluster rook is not supported
2018-05-08 08:04:54.589832 I | op-cluster: update event for cluster rook
2018-05-08 08:04:54.589841 I | op-cluster: update event for cluster rook is not supported
2018-05-08 08:04:54.590043 I | cephmds: Creating file system file-fs
2018-05-08 08:04:54.590110 I | exec: Running command: ceph fs get file-fs --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/750448527
2018-05-08 08:04:54.773617 I | exec: Error ENOENT: filesystem 'file-fs' not found
2018-05-08 08:04:54.773731 I | exec: Running command: ceph osd crush rule create-simple file-fs-metadata default host --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/484375458
2018-05-08 08:04:55.615325 I | exec: Running command: ceph osd pool create file-fs-metadata 0 replicated file-fs-metadata --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/725893785
2018-05-08 08:04:56.659519 I | exec: pool 'file-fs-metadata' created
2018-05-08 08:04:56.659621 I | exec: Running command: ceph osd pool set file-fs-metadata size 2 --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/411236644
2018-05-08 08:04:57.650422 I | exec: set pool 1 size to 2
2018-05-08 08:04:57.650539 I | exec: Running command: ceph osd pool application enable file-fs-metadata cephfs --yes-i-really-mean-it --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/649992243
2018-05-08 08:04:58.693332 I | exec: enabled application 'cephfs' on pool 'file-fs-metadata'
2018-05-08 08:04:58.693411 I | cephclient: creating pool file-fs-metadata succeeded, buf: 
2018-05-08 08:04:58.696830 I | exec: Running command: ceph osd crush rule create-simple file-fs-data0 default host --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/529052150
2018-05-08 08:04:59.687925 I | exec: Running command: ceph osd pool create file-fs-data0 0 replicated file-fs-data0 --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/298381533
2018-05-08 08:05:00.680885 I | exec: pool 'file-fs-data0' created
2018-05-08 08:05:00.680994 I | exec: Running command: ceph osd pool set file-fs-data0 size 2 --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/480980120
2018-05-08 08:05:01.722894 I | exec: set pool 2 size to 2
2018-05-08 08:05:01.723021 I | exec: Running command: ceph osd pool application enable file-fs-data0 cephfs --yes-i-really-mean-it --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/443370263
2018-05-08 08:05:02.714095 I | exec: enabled application 'cephfs' on pool 'file-fs-data0'
2018-05-08 08:05:02.714171 I | cephclient: creating pool file-fs-data0 succeeded, buf: 
2018-05-08 08:05:02.714231 I | exec: Running command: ceph fs flag set enable_multiple true --yes-i-really-mean-it --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/965419914
2018-05-08 08:05:02.910593 I | exec: Running command: ceph fs new file-fs file-fs-metadata file-fs-data0 --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/121989985
2018-05-08 08:05:03.122029 I | exec: new fs with metadata pool 1 and data pool 2
2018-05-08 08:05:03.122108 I | cephmds: created file system file-fs on 1 data pool(s) and metadata pool file-fs-metadata
2018-05-08 08:05:03.122155 I | exec: Running command: ceph fs get file-fs --cluster=rook --conf=/var/lib/rook/rook/rook.config --keyring=/var/lib/rook/rook/client.admin.keyring --format json --out-file /tmp/598867276
2018-05-08 08:05:03.303271 I | op-mds: start running mds for file system file-fs
2018-05-08 08:05:03.312697 I | op-mds: mds deployment rook-ceph-mds-file-fs started
```

  `kubectl get pods -n rook` should look like
  
```
rook-api-7994fb8785-fcp65               1/1       Running   0          <invalid>
rook-ceph-mds-file-fs-95958fd97-2kkkl   1/1       Running   0          <invalid>
rook-ceph-mds-file-fs-95958fd97-69mmp   1/1       Running   0          <invalid>
rook-ceph-mgr0-7799b6695b-8qsxs         1/1       Running   0          <invalid>
rook-ceph-mon0-277lf                    1/1       Running   0          <invalid>
rook-ceph-mon1-xc9gb                    1/1       Running   0          <invalid>
rook-ceph-mon2-2nsnz                    1/1       Running   0          <invalid>
rook-ceph-osd-4j4hf                     1/1       Running   1          <invalid>
rook-ceph-osd-fr6tx                     1/1       Running   0          <invalid>
rook-ceph-osd-hdj7n                     1/1       Running   1          <invalid>
rook-ceph-osd-jt2p9                     1/1       Running   1          <invalid>
rook-ceph-osd-r2ndr                     1/1       Running   1          <invalid>
rook-ceph-osd-znfzs                     1/1       Running   1          <invalid>
rook-tools-6c55744c9b-gx4b7             2/2       Running   0          <invalid>
```

## Ckecking status of ceph cluster

```
kubectl exec -it -n rook <rook-tools-pod> bash
ceph status
ceph mon_status
ceph quorum_status
ceph osd status
ceph osd tree
ceph df
rados df
ceph -w # watch the logs
ceph mon stat
ceph pg dump
ceph node ls  
ceph osd lspools
rbd ls <name_of_pool>
rbd -p <name_of_pool> info <name_of_object>
```

## Monitoring (optional)


```
cd ../monitoring
kubectl create ns monitoring
kubectl apply -f prometheus-operator.yaml

kubectl apply -f service-monitor.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f prometheus-service.yaml
kubectl apply -f grafana.yaml
kubectl apply -f grafana-service.yaml
```

Add http://prometheus-operated:9090 as datasource

Import dashboards:
  - 2842
  - 5336
  - 5342


## Testing

### Ceph-fs

```
kubectl apply -f test-rook-filesystemfs.yaml
```

Please check and modify `replicas` and `nodeSelector` parametes in the spec. 

Watch test results by

    k8stail --namespace default



### RBD

Install ceph cluster with 

    helm install -n rook --namespace rook -f rook-rbd.yaml ../app-rook
    
on the step 3.

Run

```
kubectl apply -f test-rook-block-50-gi.yaml
```

Parameter`replicas` should be 1.

Watch the results by

    k8stail --namespace default



## Teardown

```
helm delete --purge rook && sh rook-restart.sh
```