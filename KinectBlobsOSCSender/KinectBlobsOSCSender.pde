// Daniel Shiffman
// Depth thresholding example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

// Original example by Elie Zananiri
// http://www.silentlycrashing.net

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import blobDetection.*;
import gab.opencv.*;
import oscP5.*;
import netP5.*;
import controlP5.*;

Kinect kinect;
PGraphics pg;
BlobDetection theBlobDetection;
OpenCV opencv;

OscP5 oscP5;
NetAddress myRemoteLocation;

KinectBlobsCP5 cp5;

// Depth image
PImage depthImg;
PImage delatedImg;
// Which pixels do we care about?
int minDepth =  60;
int maxDepth = 860;
int nbDilatations = 10;
PVector maxBlobSize = new PVector(80,150);
ArrayList<Blob> bigBlobs = new ArrayList<Blob>();

int threshold = 900;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

// What is the kinect's angle
float angle;

//======================== SETUP =========================//

void setup() {
  size(1280, 480, P3D);
  pg = createGraphics(640, 480, P3D);
  sphereDetail(3);
  
  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();
  
  theBlobDetection = new BlobDetection(kinect.width, kinect.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(0.8f);
  opencv = new OpenCV(this, kinect.width, kinect.height);

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);

  cp5 = new KinectBlobsCP5(this, 5, 5, 220);

  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);
  delatedImg = new PImage(kinect.width, kinect.height);

  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}

void draw() {
  
  background(0);
  
  int depth[] = kinect.getRawDepth();
  int skip = 4; // keep 1 pixel over 4
  
  pg.beginDraw();
  background(0);
  pushMatrix();
  
  translate(cp5.transX, cp5.transY, cp5.transZ);
  rotateY(cp5.rotY * PI/180.);
  rotateX(cp5.rotX * PI/180);
  
  for(int x = 0; x < kinect.width; x += skip) {
    for(int y=0; y < kinect.height; y += skip) {
      int offset = x + y * kinect.width;
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);
      
      pushMatrix();
      float factor = 350 * cp5.zoom;
      translate(v.x * factor, v.y * factor, factor - v.z * factor);
      
      PVector globalPt = new PVector(modelX(0,0,0), modelY(0,0,0), modelZ(0,0,0));
      if(depth[offset] < threshold) {
        if(globalPt.x > cp5.left && globalPt.x < cp5.right
        && globalPt.y > cp5.bottom && globalPt.y < cp5.top
        && globalPt.z < cp5.front && globalPt.z > cp5.back) {
        //if(globalPt.x > left && globalPt.x < right
        //&& globalPt.y > bottom && globalPt.y < top
        //&& globalPt.z > front && globalPt.z < back) {
          float colorVal = map(globalPt.z, cp5.back, cp5.front, 0., 255.);
          stroke(colorVal);
          fill(colorVal);
          sphere(3.);
        }
      }
      
      popMatrix();
    }
  }
  
  popMatrix();
  pg.endDraw();
  
  background(0);
  
  // Draw the raw image
  //image(kinect.getDepthImage(), 0, 0);
  PImage pgImg = pg.get(0,0,320,480);
  pgImg.resize(640,480);
  image(pgImg, 0, 0, kinect.width, kinect.height);

  // Threshold the depth image
  int[] rawDepth = pgImg.pixels;//pg.copy().pixels;
  for (int i=0; i < rawDepth.length; i++) {
    //if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
    if(brightness(rawDepth[i]) > 0) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }
  
  //====== Draw the thresholded image ======//
  depthImg.updatePixels();
  opencv.loadImage(depthImg);
  for(int i=0; i<nbDilatations; i++) {
    opencv.dilate();
  }
  for(int i=0; i<nbDilatations; i++) {
    opencv.erode();
  }
  
  delatedImg = opencv.getSnapshot();
  image(delatedImg, kinect.width, 0);

  //fastblur(delatedImg,2);
  
  //====== draw 1-pixel black border ======//
  for(int i=0; i<kinect.width; i++) {
    delatedImg.pixels[i] = 0;
    delatedImg.pixels[kinect.width * (kinect.height - 1) + i] = 0;
  }
  for(int i=0; i<kinect.height; i++) {
    delatedImg.pixels[i * kinect.width] = 0;
    delatedImg.pixels[(i + 1) * kinect.width - 1] = 0;
  }
  delatedImg.updatePixels();
  
  theBlobDetection.computeBlobs(delatedImg.pixels);
  drawBlobsAndEdges(true,true,640,0,640,480);
  sendBlobsOverOSC();
  
  cp5.display();

  fill(0);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}


// ==================================================
// sendBlobsOverOSC()
// envoie des messages en OSC, pour récupérer les coordonées.
// ==================================================
void sendBlobsOverOSC()
{
  for(int i=0; i<bigBlobs.size(); i++) {
    OscMessage msg = new OscMessage("/kinectblob");
    Blob b = bigBlobs.get(i);

    msg.add(i+1);
    msg.add(b.x);
    msg.add(b.y);
    msg.add(b.w);
    msg.add(b.h);

    oscP5.send(msg, myRemoteLocation);
  } 
}

// ==================================================
// drawBlobsAndEdges()
// ==================================================
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges,int x, int y, int w, int h)
{
  noFill();
  bigBlobs.clear();
  Blob b;
  EdgeVertex eA,eB;
  for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0,255,0);
        for (int m=0;m<b.getEdgeNb();m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x * w + x, eA.y * h + y, 
              eB.x * w + x, eB.y * h + y
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        if ( b.w*w > maxBlobSize.x && b.h*h > maxBlobSize.y){
          strokeWeight(1);
          stroke(255,0,0);
          rect(
            b.xMin*w+x,b.yMin*h+y,
            b.w*w,b.h*h
            );
            
          bigBlobs.add(b);
        }
      }

    }

  }
}

// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img,int radius)
{
  if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }

}