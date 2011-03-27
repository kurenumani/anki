#!/bin/bash
#
# generate python files based on the designer ui files
#

if [ ! -d "designer" ]
then
    echo "Please run this from the project root"
    exit
fi

mkdir -p aqt/forms

pyuic=`which pyuic4`
pyrcc=`which pyrcc4`

if [ $? != 0 ]; then
  if [ xDarwin = x$(uname) ]
  then
      if [ -e /Library/Frameworks/Python.framework/Versions/2.7/bin/pyuic4 ]
      then
        pyuic=/Library/Frameworks/Python.framework/Versions/2.7/bin/pyuic4
        pyrcc=/Library/Frameworks/Python.framework/Versions/2.7/bin/pyrcc4
      elif [ -e /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/pyuic4 ]
      then
        pyuic=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/pyuic4
        pyrcc=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/pyrcc4
      elif [ -e /System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
      then
        pyuic=/System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
      elif [ -e /Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
      then
        pyuic=/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
      elif [ -f /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
      then
        pyuic=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
      else
        echo 'Unable to find pyuic4. If you use macports try `port install py-pyqt4`. If you use homebrew try `brew install pyqt`.'
        exit 1
      fi
   else
     echo "Unable to find pyuic4 on your path!  Please install it and try this script again."
     exit 1
   fi
fi

init=aqt/forms/__init__.py
temp=aqt/forms/scratch
rm -f $init $temp
echo "# This file auto-generated by build_ui.sh. Don't edit." > $init
echo "__all__ = [" >> $init

echo "Generating forms.."
for i in designer/*.ui
do
    base=$(echo $i | perl -pe 's/\.ui//; s%designer/%%;')
    py=$(echo $i | perl -pe 's/\.ui/.py/; s%designer%aqt/forms%;')
    echo " * "$py
    $pyuic $i -o $py
    echo "	\"$base\"," >> $init
    echo "import $base" >> $temp
    # munge the output to use gettext
    perl -pi.bak -e 's/QtGui.QApplication.translate\(".*?", /_(/; s/, None, QtGui.*/))/' $py
    # remove the 'created' time, to avoid flooding the version control system
    perl -pi.bak -e 's/^# Created:.*$//' $py
    rm $py.bak
done
echo "]" >> $init
cat $temp >> $init
rm $temp

echo "Building resources.."
$pyrcc designer/icons.qrc -o aqt/forms/icons_rc.py
