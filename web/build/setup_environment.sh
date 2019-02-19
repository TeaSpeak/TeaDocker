#!/bin/bash

BASEDIR=$(dirname "$0")
cd ${BASEDIR}

error="unknwon"
function test_code() {
	if [[ $? -ne 0 ]]; then
		echo "${error}"
		echo "$@"
		exit 1
	fi
}

#Setup emscrypten
if [[ ! -d emsdk ]]; then
	git clone https://github.com/juj/emsdk.git
	test_code "Failed to clone emscrypten"
fi

cd emsdk
./emsdk update-tags
./emsdk install latest #emscripten-1.38.27
test_code "Failed to install emscrypten"

./emsdk activate latest #emscripten-1.38.27
test_code "Failed to activate emscrypten emscrypten"

echo "source `pwd`/emsdk_env.sh" >> ~/.bash_profile
echo "emscrypten successfully registered"
cd ..

#Clone and update project
if [[ ! -d TeaWeb ]]; then
	git clone https://github.com/TeaSpeak/TeaWeb
	test_code "Failed to clone"
fi
cd TeaWeb
git pull
test_code "Failed to update"