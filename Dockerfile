########################################################################
# Dockerfile for Oracle JDK 7 on Ubuntu 14.04
########################################################################

# pull base image
FROM ubuntu:14.04

# maintainer details
MAINTAINER zeeshan "zeeshan@mit.edu"

# add a post-invoke hook to dpkg which deletes cached deb files
# update the sources.list
# update/dist-upgrade
# clear the caches


RUN \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  echo "deb http://ap-northeast-1.ec2.archive.ubuntu.com/ubuntu trusty main universe" >> /etc/apt/sources.list && \
  apt-get update -q -y && \
  apt-get dist-upgrade -y && \
  apt-get clean && \
  rm -rf /var/cache/apt/* 

# Install Oracle Java 7
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip python-pip python-sklearn python-pandas python-numpy python-matplotlib software-properties-common python-software-properties && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer && \
  apt-get clean 

# Fetch h2o latest_stable
RUN \
  wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
  wget --no-check-certificate -i latest -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
  cp h2o.jar /opt && \
  /usr/bin/pip install `find . -name "*.whl"` && \
  wget https://raw.githubusercontent.com/h2oai/h2o-3/master/docker/start-h2o-docker.sh

# Get Content
RUN \
  wget http://s3.amazonaws.com/h2o-training/mnist/train.csv.gz && \
  gunzip train.csv.gz && \ 
  wget https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Extraction_Script.py  && \
  wget https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Transformation_Script.py && \
  wget https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Modeling_Script.py


# Define a mountable data directory
#VOLUME \
#  ["/data"]

# Define the working directory
#WORKDIR \
#  /data

EXPOSE 54321
EXPOSE 54322


ENTRYPOINT ["java", "-Xmx4g", "-jar", "/opt/h2o.jar"]
# Define default command

# WORKDIR "/opt"

# CMD \
#  ["java -Xmx1g -jar h2o.jar"]



