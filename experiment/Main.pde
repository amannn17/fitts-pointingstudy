TargetL t;
TargetR r;
boolean leftActive = true;

void setup() {
  size(1200, 600);
  t = new TargetL(400, 300, 40);
  r = new TargetR(800,300,40);
}

void draw() {
  background(255);
  t.display(leftActive);
  r.display(!leftActive);
}
void mousePressed() {
  // First question: did the click land on the red circle?
  boolean hit;
  if (leftActive) {
    hit = t.contains(mouseX, mouseY);
  } else {
    hit = r.contains(mouseX, mouseY);
  }

  // Second question: what do we do about it?
  if (hit) {
    println("HIT");
    leftActive = !leftActive;   // flip: the other circle turns red
  } else {
    println("MISS");            // stay on the same circle
  }
}
