wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
yes | apt-get update
yes | apt-get install elixir esl-erlang build-essential git

# Only required on the controller
wget http://tsung.erlang-projects.org/dist/tsung-1.7.0.tar.gz
tar -xvf tsung-1.7.0.tar.gz
cd tsung-1.7.0/
./configure
make
make install
cd ..

echo "root soft nofile 4000000" >> /etc/security/limits.conf
echo "root hard nofile 4000000" >> /etc/security/limits.conf

sysctl -w fs.file-max=12000500
sysctl -w fs.nr_open=20000500
ulimit -n 4000000
sysctl -w net.ipv4.tcp_mem='10000000 10000000 10000000'
sysctl -w net.ipv4.tcp_rmem='1024 4096 16384'
sysctl -w net.ipv4.tcp_wmem='1024 4096 16384'
sysctl -w net.core.rmem_max=16384
sysctl -w net.core.wmem_max=16384
