import SimpleOpenNI.*;
SimpleOpenNI  kinect;

import ddf.minim.*;
Minim minim; 
AudioPlayer player;


boolean isClapping = false;
boolean wasClapping = false;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.setMirror(true);
  
  
  // turn on user tracking
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  size(640, 480);
  
   //initialize the minim object 
   minim = new Minim(this);
   // and load the clap file
   player = minim.loadFile("clap.wav");
  
}

void draw() {
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);

  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);

  // if we found any users
  if (userList.size() > 0) {
    // get the first user
    int userId = userList.get(0);
    
    // if we're successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      
      
      // make a vector to store the left hand
      PVector leftHand = new PVector();
      // put the position of the left hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);

      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedLeftHand = new PVector();
      kinect.convertRealWorldToProjective(leftHand, convertedLeftHand);
      // and display it     
     fill(255,0,0); 
      ellipse(convertedLeftHand.x, convertedLeftHand.y, 10, 10);   
  
  
       // make a vector to store the left hand
      PVector rightHand = new PVector();
      // put the position of the left hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);

      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedRightHand = new PVector();
      kinect.convertRealWorldToProjective(rightHand, convertedRightHand);
      // and display it   
     fill(0,255,0);   
      ellipse(convertedRightHand.x, convertedRightHand.y, 10, 10);   
  
    stroke(0,0,255);
    line(convertedRightHand.x, convertedRightHand.y, convertedLeftHand.x, convertedLeftHand.y);
    
    float distance_between_hands = sqrt(    pow(convertedRightHand.x - convertedLeftHand.x, 2) + pow(convertedRightHand.y - convertedLeftHand.y,2));
    
    
    
     println(distance_between_hands);
     
     // Figure out if a clap just occurred
     if ((!wasClapping && distance_between_hands < 60) || (wasClapping && distance_between_hands < 80)) {
       isClapping =true;
      } else {
        isClapping = false; 
      }
     
     
     if (!wasClapping && isClapping && !player.isPlaying()){
       player.play(); 
     } else {
       player.rewind();    
      player.pause();
     }

  wasClapping = isClapping;  
    }
}
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}


void stop() { 
    player.close(); 
    minim.stop();
    super.stop();
}

