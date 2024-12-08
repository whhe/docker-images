#!/bin/bash

set -x

sudo apt-get install -y curl wget alien
mirrors="https://mirrors.aliyun.com/oceanbase/community/stable/el/8/$(uname -m)"
ob_version=""
if [ -z "$OCEANBASE_VERSION" ]; then
  latest_rpm=$(wget -q -O - $mirrors | grep -oP 'href="\K[^"]*oceanbase-ce-[0-9][^"]*\.rpm' | sort -V | tail -n 1)
  ob_version=$(echo $latest_rpm | grep -P '(\d*\.\d*\.\d*\.\d*-\d*)' --only-matching)
else
  ob_version=$OCEANBASE_VERSION
fi
oceanbase_ce_rpm="oceanbase-ce-$ob_version.el8.$(uname -m).rpm"
oceanbase_ce_libs_rpm="oceanbase-ce-libs-$ob_version.el8.$(uname -m).rpm"
obclient_rpm=$(wget -q -O - $mirrors | grep -oP 'href="\K[^"]*obclient-[0-9][^"]*\.rpm' | sort -V | tail -n 1)
wget $mirrors/$oceanbase_ce_rpm
wget $mirrors/$oceanbase_ce_libs_rpm
sudo alien --scripts -i oceanbase-ce-*.rpm

wget $mirrors/$obclient_rpm
sudo alien --scripts -i obclient-*.rpm

DATABASE_PASSWORD=123456
sudo sed -i "s/^root_pwd=\".*\"/root_pwd=\"$DATABASE_PASSWORD\"/" /etc/oceanbase.cnf

sudo chown root /home/admin/oceanbase/etc
sudo systemctl start oceanbase
journalctl -u oceanbase.service -f
