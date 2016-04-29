public class KinectBlobsCP5 {
  
  ControlP5 cp5;
  int ctlHeight;
  int ctlSpacer;
  int x, y, w;
  
  //===== For point cloud transform =====//
  public float transX;
  public float transY;
  public float transZ;
  public float rotX;
  public float rotY;
  public float zoom;
  //======== Limits =========//
  public float left;
  public float right;
  public float top;
  public float bottom;
  public float front;
  public float back;
  
  KinectBlobsCP5(PApplet parent, int x, int y, int w) {
    
    this.x = x;
    this.y = y;
    this.w = w;
    int sw = (int)(this.w * 0.8);
    
    transX = 320;
    transY = 240;
    transZ = -50;
    rotX = 0;
    rotY = 0;
    zoom = 1;
    
    left = -5000;
    right = 5000;
    top = 5000;
    bottom = -5000;
    back = -1200;
    front = 2000;
    
    ctlHeight = 20;
    ctlSpacer = 5;
    cp5 = new ControlP5(parent);
    
    //================ TRANSLATION ===============//
    cp5.addSlider("transX")
      .setPosition(x + ctlSpacer, y + ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(transX);
    cp5.addSlider("transY")
      .setPosition(x + ctlSpacer, y + ctlHeight + 2 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(transY);
    cp5.addSlider("transZ")
      .setPosition(x + ctlSpacer, y + 2 * ctlHeight + 3 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(transZ);

    //================= ROTATION =================//
    cp5.addSlider("rotX")
      .setPosition(x + ctlSpacer, y + 3 * ctlHeight + 6 * ctlSpacer)
      .setRange(-90.,90.)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(rotX);
    cp5.addSlider("rotY")
      .setPosition(x + ctlSpacer, y + 4 * ctlHeight + 7 * ctlSpacer)
      .setRange(-180.,180.)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(rotY);

    //================== SCALING =================//
    cp5.addSlider("zoom")
      .setPosition(x + ctlSpacer, y + 5 * ctlHeight + 10 * ctlSpacer)
      .setRange(0.,10.)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(zoom);

    //================== CLIPPING ================//
    cp5.addSlider("left")
      .setPosition(x + ctlSpacer, y + 6 * ctlHeight + 13 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(left);
    cp5.addSlider("right")
      .setPosition(x + ctlSpacer, y + 7 * ctlHeight + 14 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(right);
    cp5.addSlider("bottom")
      .setPosition(x + ctlSpacer, y + 8 * ctlHeight + 15 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(bottom);
    cp5.addSlider("top")
      .setPosition(x + ctlSpacer, y + 9 * ctlHeight + 16 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(top);
    cp5.addSlider("back")
      .setPosition(x + ctlSpacer, y + 10 * ctlHeight + 17 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(back);
    cp5.addSlider("front")
      .setPosition(x + ctlSpacer, y + 11 * ctlHeight + 18 * ctlSpacer)
      .setRange(-5000,5000)
      .setSize(sw,ctlHeight)
      .plugTo(this)
      .setValue(front);
  }
  
  void display() {
    noStroke();
    fill(90,110,130, 220);
    int realWidth = this.w;//(int)(this.w * 1.23);
    int subHeight1 = 3 * ctlHeight + 4 * ctlSpacer;
    rect(this.x, this.y, realWidth, subHeight1);
    int subHeight2 = 2 * ctlHeight + 3 * ctlSpacer;
    rect(this.x, this.y + subHeight1 + ctlSpacer, realWidth, subHeight2);
    int subHeight3 = ctlHeight + 2 * ctlSpacer;
    rect(this.x, this.y + subHeight1 + subHeight2 + 2 * ctlSpacer,
        realWidth, subHeight3);
    int subHeight4 = 6 * ctlHeight + 7 * ctlSpacer;
    rect(this.x, this.y + subHeight1 + subHeight2 + subHeight3 + 3 * ctlSpacer,
        realWidth, subHeight4);
  }
};