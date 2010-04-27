rm -f CoreMIDI.so
python setup.py build_ext || exit
find . -name CoreMIDI.so -exec mv {} . \;
