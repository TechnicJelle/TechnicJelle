---
tags: [ Code, Arduino, Android, Networking, Physical ]
original: https://technicjelle.tumblr.com/post/697768327172521984/custom-android-to-arduino-communication
atom-id: "019dc1ff-801e-7900-b5a7-e40f25e2a45a"
---

# Custom Android to Arduino Communication

Today I spent the evening (~6 hours) writing a custom Android app to connect
my Arduino to with a custom program for that one too, so I can read and graph the values from its joystick:

<video src="VID_20221010_235628739.webm" controls autoplay muted loop playsinline></video>

No PC required! Just power to the Arduino.

It works over Wi-Fi with Web Sockets, with the phone being the server, and the Arduino being the client.

The code of this project is quite horrible, so I’m not publishing it this time.
Also because it’s basically just two library examples mashed together plus one of my lecture code samples,
so hardly any of this is actually my own code.
