WebPlot
==============

ブラウザ上でプロットを行えるサービス

~~http://rodin.ikulab.org:8000/~~
（現在動作させていません）


## 必要なもの

* plplot
* g++
* node
* npm
* make
* coffee-script

## インストール
    git clone https://github.com/nyaocat/WebPlot.git
    cd WebPlot
    npm install
    make
    coffee -bc .
    node app.js

### 動作確認した環境

* Ubuntu server 12.04 LTS
* FreeBSD 9.1 Release
