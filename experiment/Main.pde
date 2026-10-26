Target left;
Target right;
boolean leftActive = true;
int lastHitTime = 0;
boolean firstClick = true;

void setup() {
  size(1200, 600);
  left = new Target(400, 300, 40);
  right = new Target(800,300,40);
}

void draw() {
  background(255);
  left.display(leftActive);
  right.display(!leftActive);
}
void mousePressed() {
  // First question: did the click land on the red circle?
  boolean hit;
  if (leftActive) {
    hit = left.contains(mouseX, mouseY);
  } else {
    hit = right.contains(mouseX, mouseY);
  }

  // Second question: what do we do about it?
    if (hit) {
    if (firstClick) {
      println("START");
      firstClick = false;
    } else {
      int mt = millis() - lastHitTime;
      println("HIT  MT = " + mt + " ms");
    }
    lastHitTime = millis();
    leftActive = !leftActive;
  } else {
    println("MISS");
  }
}
