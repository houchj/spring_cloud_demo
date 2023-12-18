
# How to create Nexus server on kube


### Create deployment 
microk8s kubectl create -f deployment.yaml

### Create service to expose on NodePort 
microk8s kubectl create -f service.yaml

### delete it and create again in case of OOM
microk8s kubectl delete deployments nexus -n devops-tools

### Get default "admin" user's password 
microk8s kubectl -n devops-tools get pods
microk8s kubectl exec nexus-7dfb94f99c-6hchm  -n devops-tools cat /nexus-data/admin.password

### check the logs of the pod
microk8s kubectl -n devops-tools logs nexus-7dfb94f99c-6hchm

### if sess this message, the means the server is started successfully:

2023-12-18 07:28:45,918+0000 INFO  [jetty-main-1] *SYSTEM org.sonatype.nexus.bootstrap.jetty.JettyServer -
-------------------------------------------------

Started Sonatype Nexus OSS 3.63.0-01

-------------------------------------------------

### access the Nexus in following URL
http://192.168.1.7:32000/#browse/welcome



