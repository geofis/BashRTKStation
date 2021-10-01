#!/bin/bash

/home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://ttyACM0:230400:8:n:1 -out tcpsvr://localhost:3001
