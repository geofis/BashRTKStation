# BashRTKStation

**Base-rover GNSS-RTK multi-band system, based on the u-blox ZED-F9P receiver, Raspberry Pi and RTKLIB** <br>
*José Ramón Martínez Batlle, Universidad Autónoma de Santo Domingo (UASD), jmartinez19@uasd.edu.do*


## The problem

When it comes to open-source apps for processing the u-blox ZED-F9P data, there are several solutions which concentrates in only one task. For example, either for transmitting corrections via TCP or for saving solutions. But so far, I have been missing a complete field workflow solution using a cell phone; this repo aims to fill that gap.

## My simple solution

The repo contains simple Bash scripts to provide a "complete" solution for operating a base-rover GNSS-RTK multi-band system, using a u-blox ZED-F9P receiver, a cell phone, a Raspberry Pi and ancillary apps.

The basic hardware required is listed below:

- A u-blox ZED-F9P chip, which deals with the GNSS constellations and generates the RTK solutions.

- A Raspberry Pi 3B+ (other models will work as well) which enables the connectivity between devices and applications.

- A cell phone.

A complete list of the parts needed can be found [here](https://github.com/geofis/TouchRTKStation).

The software comprises the following:

- Of course, the collection of scripts from this repo. The Bash scripts are used to establish connections between devices, and also provide a storing and visualization interface. "It is not user-friendly, but it works".

- Ancillary apps: on the server side (a Raspberry Pi), RTKLIB package; on the client side (an Android mobile phone): VNC Viewer, SW Maps and Lefebure NTRIP Client

## Installation

1. Turn on your Raspberry Pi and connect it to the Internet. Update to the latest version of Raspberry OS. If you are using the old Raspbian Stretch, the compilation of RTKLIB will likely fail because of a `gfortran` issue.

2. In the Raspberry Pi configuration app (`sudo raspi-config`), be sure to:

    - Set a good resolution for your screen; a good resolution must be enough to fit windows without cropping them. I tested my RPi with 720x480.
    - In the Interface options, activate VNC.
    - In the Interface options, select Serial Port, disable login shell over serial port and finally enable serial port.

3. Download BashRTKStation:

```
cd /home/pi/
git clone https://github.com/geofis/BashRTKStation.git
```
4. Install the app and the ancillalry packages.

```
cd /home/pi/BashRTKStation/install
sudo sh install.sh
```

Installation goes through updating the RPi, installing gfortran, xterm, gpsd, python gpsd, and compiling RTKLIB apps. Lastly, the credentials folder is created, as well as the Desktop shortcuts.

## How to use

Below I demonstrate (2X video) how I run the application. The demo was recorded indoors using a laptop to integrate the windows all together, but the workflow is fully executed from the cell phone. The upper-left window shows an instance of VNC Viewer, which is used to control the RPi. The lower-left window is an instance of RTKPLOT (from RTKLIB), showing the position in real time. On the right half, a window shows the cell phone screen.

![](img/showcase.gif)

I usually start by opening VNC Viewer and connect to the RPi desktop. From there, I launch the [`rover.sh`](rover.sh) script, and select the option for sending RTCM messages from the base to the receiver (oprtion #2). Automatically, the receiver generates RTK-fix solutions internally, and it send them back as NMEA messages. Simultaneously, I forward the NMEA messages via TCP from the RPi. This functionality allows the cell phone (or other devices capable of reading the TCP stream and connected to the same network) to display the precise position in real time. It is also possible to save the stream in a file locally, so all the dataflow can be stored for future use.

After starting the streaming, I leave VNC Viewer running, launch the NTRIP Client (Lefebure Design), and connect it to the TCP port. The NTRIP Client generates a mock location and also shows details regarding the GNSS transmission, i.e. the status of the transmission, RTK solution type, *DOP, etc. I then launch SW Maps, which shows the position over a reference image (e.g. Google Satellite) in real time; the dot in the app changes its color depending on the type of fix: orange means "RTK-float", green means "RTK-fix".

After all of the above is up and running, and RTK-fix mode is achieved, I switch back to the RPi via the VNC Viewer, and launch the same script again ([`rover.sh`](rover.sh)), but this time I select one of the data collection modes. In the example, I select the option #5, which saves, in the RPI's microSD card, the solutions (NMEA messages) and the raw observations (UBX format) coming from the receiver into a single file. There are many reasons for storing the raw observations in the RPi, but the main one is to do post-processing (PPK) if necessary.

When the script runs in collection mode, it reports two useful things in real time: 1) Collection time in seconds (with this receiver, you don't have to spend your whole life gripping the pole, 30 secs is usually enough); 2) Number of fixed solutions that are being saved.

When I am done, I end the Bash scripts by pressing CTRL+C. This shortcut can be used to stop the storing terminal as well as the RTCM stream. I also disconnect de NTRIP Client in the cell phone.

My receiver is configured at 2 Hz (2 epochs per second), and since the u-blox internal solution is so efficient&mdash;convergence time is instantaneous in the open&mdash;, nearly each epoch becomes a fixed solution. So, if I collect data for 60 seconds in RTK mode in the open, and the receiver is already in RTK-fix mode, I will be able to store ~120 fixed solutions. I may set the receiver to collect at 5 Hz to help reduce the recording time at each station, but for me it is OK to have it at 2 Hz.

As a side note, I claim that the dual-frequency receivers far outperform the old single-frequency units. I recall that with my SF units, the number of float solutions far exceeded the number of fixed solutions, the opposite of what I get with the DF. Also, with the SF, I could never achieve enough fixed solutions in challenging conditions (e.g. closed canopy cover), but with the DF, even in closed canopy cover the fix ratio is pretty good.

## Capabalities

Presently, the Bash scripts have the following capabilities:

- Rover:

  - Receive corrections from an NTRIP server and send them to the receiver. Optionally, both the solutions generated by the receiver and the raw observations can be streamed synchronously to TCP + file.
  - Asynchronously receive RTK solutions and raw observations from the receiver, and save them in file(s).
  - Receive raw observations in single mode and stream them to TCP and/or file.
  - Create credentials and define mountpoints.

## Materials

The same materials as described [here](https://github.com/geofis/TouchRTKStation), but replacing the NEO-M8T receivers by ZED-F9P receivers.

## TO-DO list:

- Base:
  - Create workflow for generating base coordinates.
  - Add capabilities for streaming corrections via telemetry and NTRIP protocol.

- Rover:
  - Add capabilities for receiving corrections via telemetry.
