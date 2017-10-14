#!bash -uvx
wget -nc http://downloads.dlang.org/releases/2.x/2.076.1/dmd.2.076.1.linux.tar.xz
tar xvf dmd.2.076.1.linux.tar.xz
rm -rf ~/dmd2
mv dmd2 ~/
echo export PATH=~/dmd2/linux/bin64:$PATH >> ~/.bashrc
echo alias d32='dub' >> ~/.bashrc
