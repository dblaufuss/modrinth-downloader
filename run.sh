$PWD/.venv/bin/python $PWD/main.py
mkdir downloads
wget -P downloads/ -i urls.txt
rm urls.txt