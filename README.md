Appellancy
=====================

----------

Appellancy is a next-generation face recognition tweak for your iDevice that supports all iPhones, iPods, and iPads running iOS 7. It is nearly flawless in its recognition, and it integrates into the native look and feel of iOS 7 so well that you’ll wonder why it isn't a native feature. It currently supports all iPods, iPhones, and iPads running iOS 7.

There is a simple API for other developers to integrate Appellancy into their projects, more details available at https://github.com/mlnlover11/Appellancy-API, so Appellancy is not limited to the lockscreen, it is possible to integrate into many app locking tweaks.

Because Appellancy uses the camera, it will have an effect on the battery life. However, Appellancy only uses the camera when it needs to, which minimizes the effect on the battery, so battery usage should be almost unnoticeable.

Some people may ask, "Isn’t face recognition inherently insecure? Couldn’t someone hold up a picture of my face?"
Yes, facial recognition is somewhat inherently insecure. A picture could dupe it. However, what makes Appellancy so much more secure is that it, by default, includes a database entry of random faces to populate a deny entry. This causes Appellancy to deny nearly any face except yours. By enhancing this database and the facial recognition methods in the future it will become even more secure. 
If you find a face that matches when it shouldn't, simply scan it into the deny entry Appellancy has to cause Appellancy to learn from that mistake.

It is currently compatible with most known lockscreen tweaks, including, but not limited to: ClassicLockScreen, Convergance, AndroidLock XT, and iCaughtU. 

On older/weaker devices (such as the iPod 5 and iPhone 4) it is recommended to have no more than 20 scanned photos or it may result in instability. 

License: BSD

Installation instructions:
- Change the app’s build script to point to wherever you downloaded the appellancy source code.
- run “make package install THEOS_DEVICE_IP=192.168.X.XXX” to build and install on your device
- ???
- Profit

Screenshots: 
![Settings app][1]
![Face scanner][2]

TODO
- save/load FaceRecognizer from xml/yml
- require password as well
- Make imageView movable
- option to make the “37” denied entries appear as “0”
- imageView isn’t work with Stride 2
- Fix Ah! Ah! ah! support
- view/remove stored images
- Manually add images
- Choose to allow/deny certain profiles

----------

  [1]: https://github.com/mlnlover11/Appellancy/raw/master/Screenshot4.png
  [2]: https://github.com/mlnlover11/Appellancy/raw/master/Screenshot1.png

