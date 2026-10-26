import netP5.*;
import oscP5.*;

OscP5 osc;

// Global so both oscEvent() and keyPressed() can use them
float gx, gy, gz;

void setup() {
  size(400, 400);
  osc = new OscP5(this, 9000);
  textSize(20);
}

void draw() {
  // Live readout in the window so you can see values while tilting
  background(0);
  fill(255);
  text("x: " + nf(gx, 1, 2), 40, 120);
  text("y: " + nf(gy, 1, 2), 40, 160);
  text("z: " + nf(gz, 1, 2), 40, 200);
  text("f=flat l=left r=right t=toward a=away", 40, 300);
}

void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/ZIGSIM/amansiphone/gravity")) {
    // Assign only, no "float": that would create new local variables
    gx = m.get(0).floatValue();
    gy = m.get(1).floatValue();
    gz = m.get(2).floatValue();
  }
}

void keyPressed() {
  String label = "";
  if (key == 'f') label = "FLAT";
  if (key == 'l') label = "LEFT";
  if (key == 'r') label = "RIGHT";
  if (key == 't') label = "TOWARD";
  if (key == 'a') label = "AWAY";

  if (!label.equals("")) {
    println(label, nf(gx, 1, 2), nf(gy, 1, 2), nf(gz, 1, 2));
  }
}
