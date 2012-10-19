import SimpleOpenNI.*;
SimpleOpenNI  kinect;

import rwmidi.*;

MidiOutput output;


// variables for note generation from keystrike
// variables for note generation from keystrike
int aChannel,  sChannel,  dChannel,  fChannel;
int aNote,     sNote,     dNote,     fNote;
int aVelocity, sVelocity, dVelocity, fVelocity;
int aSuccess,  sSuccess,  dSuccess,  fSuccess;

boolean isClapping = false;
boolean wasClapping = false;
boolean beatOn = false;
boolean wasInEffectBox = false;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.setMirror(true);
  
  
  // turn on user tracking
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  size(640, 480);
  
  // just like serial ports, you can list the devices if you like
  println("output devices");
  println(RWMidi.getOutputDevices());
  println("\ninput devices");
  println(RWMidi.getInputDevices());


  // creates a connection to IAC as an output
  output = RWMidi.getOutputDevices()[0].createOutput();  // talks to MIDI  
  
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
    
    
    println(convertedRightHand.x + " " + convertedRightHand.y);
    
    // Draw toggle box
     noFill();
    strokeWeight(3);
    stroke(0,0,255);
    rect(590,10,40,40);
    
    
    // println(distance_between_hands);
     
     // Figure out if a clap just occurred
     if ((!wasClapping && distance_between_hands < 60) || (wasClapping && distance_between_hands < 100)) {
       isClapping =true;
      } else {
        isClapping = false; 
      }
     
     // If this is a new clap, toggle the state of the beat
     if (!wasClapping && isClapping){
       if (beatOn)
       {  
         // Turn off beat
         output.sendNoteOff(0, 3, 3);
         beatOn = false;
         println("Beat turned off");
       } else {
         // Turn beat on
         output.sendNoteOn(0, 3, 3);
          beatOn = true; 
          println("Beat turned on");
          
       }
     } 
     
     // If the beat is on, control the volume
     if (beatOn)
     {
        // Control the volume
        int volume = min(int(map(max(distance_between_hands,40), 0, 500, 0, 127)), 127); 
        output.sendController(1, 1, volume);
        println("Volume is: " + volume);
        
        
            // Calculate angle of hands
      leftHand.sub(rightHand);
      leftHand.normalize();
      PVector handOrientation = new PVector(1,0,0);
     float angle = degrees(acos(handOrientation.dot(leftHand)));
       println("Angle: " + angle);
       
       
       
       if (convertedRightHand.x >= 590 && convertedRightHand.x <= 630 && convertedRightHand.y <= 50 && convertedRightHand.y >= 10)
       {
         
         if (!wasInEffectBox)
         {
             output.sendNoteOn(2, 1, 1);
             println("Just entered effect box");
         } 
          wasInEffectBox = true; 
       } else {
          wasInEffectBox = false; 
       }
       
        
        // Show the indicator
        stroke(255,0,0);
        fill(255,0,0);
        rect(10,10,40,40);
     } else {
        // Show an empty indicator -- beat is off
        noFill();
        strokeWeight(3);
        stroke(255,0,0);
        rect(10,10,40,40);
     }
       
  

  wasClapping = isClapping;  
    }
}
}



void keyPressed(){

  if (key == 'a' || key == 'A' ) {
    // Toggle effect
    output.sendNoteOn(2, 1, 1);
  }

  if (key == 's' || key == 'S' ) {
    sChannel = 1;
    sNote = 61;
    sVelocity = 127;
    sSuccess = output.sendNoteOn(sChannel, sNote, sVelocity); // note return a variabel of type INT
  }

  if (key == 'd' || key == 'D' ) {
    dChannel = 1;
    dNote = 62;
    dVelocity = 127;
    dSuccess = output.sendNoteOn(dChannel, dNote, dVelocity); // note return a variabel of type INT

  }

  if (key == 'f' || key == 'F' ) {
    fChannel = 1;
    fNote = 63;
    fVelocity = 127;
    fSuccess = output.sendNoteOn(fChannel, fNote, fVelocity); // note return a variabel of type INT

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



