#credit for the golang installer goes to https://github.com/canha/golang-tools-install-script/
#wget https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh
./goinstall.sh --64

source /root/.bashrc
rm -rf $GOPATH/src/github.com
#dependencies
go get github.com/caddyserver/builds
go get github.com/mholt/caddy/caddy

#plugins
go get github.com/caddyserver/forwardproxy
go get github.com/pyed/ipfilter

#adding plugins references to be compiled
echo Adding forwardproxy plugin...
awk '/imported/ { print; print "\t_ \"github.com/caddyserver/forwardproxy\""; next }1' $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go > $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go.new
/usr/bin/mv $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go.new $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go
echo Adding ipfilter plugin...
awk '/imported/ { print; print "\t_ \"github.com/pyed/ipfilter\""; next }1' $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go > $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go.new
/usr/bin/mv $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go.new $GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go

echo Compiling...
cd $GOPATH/src/github.com/mholt/caddy/caddy
go run build.go

if [ -f $GOPATH/src/github.com/mholt/caddy/caddy/caddy ]; then
   echo "Build successful.  Installing..."
else
   echo "Build failed.  Exiting."
   exit
fi

systemctl stop caddy
/usr/bin/mv /usr/local/bin/caddy /usr/local/bin/caddy.old
/usr/bin/mv $GOPATH/src/github.com/mholt/caddy/caddy/caddy /usr/local/bin/caddy
sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy
systemctl start caddy
rm -rf /tmp/goinstall.sh 
