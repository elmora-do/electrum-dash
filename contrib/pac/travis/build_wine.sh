#!/bin/bash

source ./contrib/pac/travis/electrum_PAC_version_env.sh;
echo wine build version is $PAC_ELECTRUM_VERSION

mv /opt/zbarw $WINEPREFIX/drive_c/

mv /opt/x11_hash $WINEPREFIX/drive_c/

mv /opt/libsecp256k1/libsecp256k1-0.dll \
   /opt/libsecp256k1/libsecp256k1.dll
mv /opt/libsecp256k1 $WINEPREFIX/drive_c/

cd $WINEPREFIX/drive_c/electrum-PAC

rm -rf build
rm -rf dist/electrum-PAC

cp contrib/pac/deterministic.spec .
cp contrib/pac/pyi_runtimehook.py .
cp contrib/pac/pyi_tctl_runtimehook.py .

wine pip install --upgrade pip
export PYINSTALLER_TAG=dev180610
wget https://github.com/zebra-lucky/pyinstaller/archive/$PYINSTALLER_TAG.tar.gz
wine pip install $PYINSTALLER_TAG.tar.gz
rm $PYINSTALLER_TAG.tar.gz

wine pip install eth-hash==0.1.2
wine pip install -r contrib/pac/requirements-win.txt

wine pip install cython
wine pip install hidapi
wine pip install pycryptodomex==3.6.1
wine pip install btchip-python==0.1.27
wine pip install keepkey==4.0.2
wine pip install safet==0.1.3
wine pip install trezor==0.10.2

mkdir $WINEPREFIX/drive_c/Qt
ln -s $PYHOME/Lib/site-packages/PyQt5/ $WINEPREFIX/drive_c/Qt/5.11.2

wine pyinstaller -y \
    --name electrum-pac-$PAC_ELECTRUM_VERSION.exe \
    deterministic.spec

if [[ $WINEARCH == win32 ]]; then
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files/NSIS/makensis.exe"
else
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe"
fi

wine "$NSIS_EXE" /NOCD -V3 \
    /DPRODUCT_VERSION=$PAC_ELECTRUM_VERSION \
    /DWINEARCH=$WINEARCH \
    contrib/pac/electrum-pac.nsi
