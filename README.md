# resin-wifi-connect
An app to allow WiFi configuration to be set via a captive portal. It checks whether WiFi is connected, tries to join the saved network, and if this fails, it opens an access point to which you can connect using a laptop or mobile phone and input new WiFi credentials.

## Warning
The latest version of resin-wifi-connect adds support for Network Manager which is replacing connman in ResinOS 2.0 onwards. Although this app still supports connman, there have been some breaking changes made to the control flow and subsequently the commands used to start the app. Please ensure you test resin-wifi-connect with your device and code base to ensure there are no issues before deploying to your fleet.

## How to use this
This is a [resin.io](http://resin.io) application. Check out our [Getting Started](http://docs.resin.io/#/pages/installing/gettingStarted.md) guide if it's your first time using Resin.

This project is meant to be integrated as part of a larger application (that is, _your_ application). An example on how to use this on a Python project can be found [here](https://github.com/resin-io-projects/resin-wifi-connect-python-example).

If you need to add dependencies, add the corresponding statements in the [Dockerfile](./Dockerfile.template) template. You can add the commands that run your app in the [start](./start) script. 

The app can be run in 2 modes; `--retry=true` and `--retry=false`. In the first mode the app will always remove the saved credentials and open an access point if it cannot connect to the saved network or there is no saved network available (we recomend this mode for initial setup and when moving your device to a new location). In the second mode the app will never remove the saved credentials or open an access point if there is a saved network, however it will open an Access point if there is no saved network (we recomend this mode during normal use).

This app only exits after a successful connection (unless `--retry=false` mode is used), so if you add your app after [line 3](./start#L3) you ensure that everything happens after wifi is correctly configured.

This is a node.js application, but your app can be any language/framework you want as long as you install it properly - if you need help, check out our [Dockerfile guide](http://docs.resin.io/#/pages/using/dockerfile.md). This project uses a Resin feature called "Dockerfile template": the base image is chosen depending on the architecture, specified by the `%%RESIN_ARCH%%` variable (see [line 1](./Dockerfile.template#L1) in the template).

## Supported boards / dongles
**For the Intel Edison version of this software, check the [edison branch](https://github.com/resin-io/resin-wifi-connect/tree/edison) in this repository.**

This software has been successfully tested on Raspberry Pi's A+ and 2B using the following WiFi dongles:

Dongle                                     | Chip
-------------------------------------------|-------------------
[TP-LINK TL-WN722N](http://bit.ly/1P1MdAG) | Atheros AR9271
[ModMyPi](http://bit.ly/1gY3IHF)           | Ralink RT3070
[ThePiHut](http://bit.ly/1LfkCgZ)          | Ralink RT5370

The software has also been successfully tested on RaspberryPi 3 with its onboard wifi.

Given these results, it is probable that most dongles with *Atheros* or *Ralink* chipsets will work.

The following dongles are known **not** to work (as the driver is not friendly with access point mode and Connman):
* Official Raspberry Pi dongle (BCM43143 chip)
* Addon NWU276 (Mediatek MT7601 chip)
* Edimax (Realtek RTL8188CUS chip)
Dongles with similar chipsets will probably not work.

The software is expected to work with other Resin supported boards as long as you use the correct dongles.
Please [contact us](https://resin.io/contact/) or raise [an issue](https://github.com/resin-io/resin-wifi-connect/issues) if you hit any trouble.

## How it works
This app interacts with either connman or Network Manager in ResinOS. It checks whether the wifi has been previously provisioned, and if it hasn't, it opens an access point to which you can connect using a laptop or mobile phone.

The access point's name (SSID) is, by default, "ResinAP". You can change this by setting the `PORTAL_SSID` environment variable. By default, the network is unprotected, but you can add a WPA2 passphrase by setting the `PORTAL_PASSPHRASE` environment variable.

When you connect to the access point, any web page you open will be redirected to our captive portal page, where you can select the SSID and passphrase of the WiFi network to connect to. After this, the app will disable the access point and try to connect. If it succeeds, the network will be saved. If it fails and `--retry=true` mode is used it will enable the access point for you to try again.

An important detail is that in `--retry=false` mode, the project will not attempt to enter access point mode if a successful configuration has happened in the past. This means that if you go through the process and then move the device to a different network, it will be trying to connect forever. It is left to the user application to decide which is the appropriate condition to re-enter access point mode. This can be "been offline for more than 1 day" or "user pushed the reset button" or something else. To re-enter access point mode, simply run `node app.js --retry=true` as done in the provided [start](https://github.com/resin-io/resin-wifi-connect/blob/master/start) script.
