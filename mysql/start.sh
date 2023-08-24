docker run \
--detach \
--name=mysql-docker \
--env="MYSQL_ROOT_PASSWORD=Initial0" \
--publish 3306:3306 \
--volume=/home/houchj/git/spring_cloud_demo/mysql/conf.d:/etc/mysql/mysql.conf.d \
--volume=/home/houchj/mysql/mysql-data:/var/lib/mysql \
--volume=/home/houchj/mysql/mysqld:/var/run/mysqld \
--privileged=true \
mysql
