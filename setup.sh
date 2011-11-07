#!/bin/sh -v

# TODO: check for virtualenv
# TODO: verify python is universal 32+64 bit

virtualenv -p /Library/Frameworks/Python.framework/Versions/2.7/bin/python --no-site-packages ${1}/cpdev
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi


. ${1}/cpdev/bin/activate
cd ${1}/cpdev/bin

# Create a 32-bit python (we need it for installing matplotlib in 32-bit land)
/usr/bin/lipo ./python -thin i386 -output ./python32
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

pip install -U pip # to get git+https
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

# put in the wxredirect.pth
python <<EOF
import os
import os.path
import glob
import sys
wxdirs = sorted(glob.glob('/usr/local/lib/wxPython-unicode-2.8*/lib/python2.7'))
assert len(wxdirs) > 0, "No directories matching %s found!" % ('/usr/local/lib/wxPython-unicode-2.8*/lib/python2.7')
dest = os.path.join(os.getenv('VIRTUAL_ENV'), 'lib', 'python2.7', 'site-packages', 'wxredirect.pth')
open(dest, 'w').write("import site; site.addsitedir('%s')\n" % (wxdirs[-1]))
sys.exit(0)
EOF
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

./pip install numpy
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi


./pip install scipy
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi


./pip install PIL
PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/X11R6/lib/pkgconfig:/usr/local/lib/pkgconfig ./python32 ./pip install git+https://github.com/matplotlib/matplotlib.git@a9f3f3a507
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi


HDF5_DIR=`brew --prefix libhdf5-universal` ./pip install h5py
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
