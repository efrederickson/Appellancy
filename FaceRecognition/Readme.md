# Face Detection & Recognition on iOS
This is an example iPhone application that performs face detection and recognition using the excellent [OpenCV framework](http://opencv.org).

This was adapted for use by Appellancy

Obviously, the app needs the camera to function, and will not work on the simulator.

## Usage
The app was tested on iOS 6 using an iPhone 5. Other iOS versions and devices will probably work, but I can't say for sure. On iPhone 4 you will have to play with the spacing of the buttons.

The first step will be to train the model with some faces. Importing existing images is not supported for various reasons, so you will need to capture face images using the camera. The steps to perform this are as follows:

1. Navigate to the "People" tab, and add a new person.
2. Once the person shows up in the list, tap on their name.
3. Instructions are provided on how to capture images of that person's face for later detection. The app uses either camera.
4. When capturing images, try and move the camera slightly to capture different angles of your face.
5. Alternative you can pick images from the library. You should pick 10 with the face you want the app to learn.
6. Repeat for other people as necessary.

Once the app has at least one person in the database with face images, face recognition can occur.

Navigate to the "Recognize" tab, and the camera will start. If a face is detected, it will be highlighted with a red box. If that face is recognized from the database, it will be highlighted with a green box. The name of that person will appear on top of the image, and a confidence score of the face recognition will be displayed.

### A note about confidence scores
The confidence value provided by the face recognition algorithm is basically a difference score between the input image and what the model knows about a given person's face.

Therefore, a lower confidence score means the model is more confident of its suggested match - because there is less of a difference between the input face and the faces of that person in the database.

## Using different algorithms
The CustomFaceRecognizer class can be initialized using one of 3 different face recognition algorithms. By default it uses an Eigenfaces algorithm, but you can change this easily by using a different initWith method. For a discussion of the various algorithms available, see this [OpenCV tutorial](http://docs.opencv.org/trunk/modules/contrib/doc/facerec/facerec_tutorial.html).

The available algorithms are:

* Eigenfaces (initWithEigenFaceRecognizer)
* Fisherfaces (initWithFisherFaceRecognizer)
* Local Binary Patterns Histogram (initWithLBPHFaceRecognizer)

After you have initialized the recognizer with one of these methods, training and recognition works the same. You can switch algorithms without having to re-train the model.

## Credits
* [Setting up OpenCV in iOS](http://docs.opencv.org/trunk/doc/tutorials/ios/video_processing/video_processing.html)
* [Face detection in OpenCV](https://github.com/aptogo/FaceTracker)
* [Face recognition in OpenCV](http://docs.opencv.org/trunk/modules/contrib/doc/facerec/facerec_tutorial.html)
