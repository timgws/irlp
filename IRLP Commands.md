# Explanation of some of the standard binaries

## Files in /home/irlp/bin/

* `aux*`  software-controlled switches using MOSFET's. The three outputs are active LOW. They can sink several amps of current, so beware. DO NOT sink more than about 500mA though.  The commands are: `aux1off`, `aux1on`, `aux2off`, `aux2on`, `aux3off`, `aux3on`.  
* `cosstate`  COSSTATE is FALSE (equals 1) when there is a local signal being detected by the IRLP board (COS is high)
* `dial`, `dtmf`  responsible for interpreting DTMFs received by the (link) radio. You can kill this process if you're having trouble w/ unauthorized people sending DTMF commands and your node won't hear commands any more but will still respond to keyboard commands and can still make and receive connections.
* `forcekey` / `forceunkey` see key / unkey
* `key` / `unkey` cause your radio to key and unkey (ptt) -- invoked automatically by incoming signals from other nodes or reflectors, or can be executed from the console (keyboard). If you are running an ID script that plays and ID when your node is already keyed by IRLP activity, if the IRLP activity drops in the middle of your ID the ID will be interrupted. The forcekey command was created for use in these circumstances to keep your node keyed if activity drops (ptt is then brought down with the forceunkey command). From VE7LTD: " So, if you use forcekeys for anything, make DARN sure that there is a forceunkey to accompany it! Or else you will have smoldering plastic if your radio can not handle it."
* `pttstate`  PTTSTATE is FALSE (equals 1) when there is a transmit signal being sent from the IRLP board to your radio.
* `readinput`  Mean for troubleshooting, it will display everything that comes across; PTT ACTIVE, PTT INACTIVE, COS ACTIVE, COS INACTIVE, DTMF 1, etc
* `imike` takes your voice from the mic input on the sound card and digitizes it into UDP voice packets and sends them out over the internet to any IP address and port number that you choose whenever pin 11 on the parallel printer port is shorted to ground.  (`imike` is the modified version of `sfmike`)
* `ispeaker` listens for UDP voice packets from the internet on any port you choose and turns them back into analog and puts that audio out the speaker jack on the sound card. When valid UDP packets are received pin 3 on the parallel printer port goes high.  (`ispeaker` is the modified version of `sfspeaker`)

(Copied from http://www.qsl.net/kb9mwr/projects/voip/irlp-repeater.html)