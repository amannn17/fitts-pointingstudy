class Target {
  float x;
  float y;
  float w;

  // Constructor: runs once when you write "new Target(...)"
  Target(float tx, float ty, float tw) {
    x = tx;
    y = ty;
    w = tw;
  }

  void display(boolean active) {
    noStroke();
    if (active) {
      fill(230, 60, 60);   // red: the target to click
    } else {
      fill(200);           // grey: the other target
    }
    ellipse(x, y, w, w);
  }

  boolean contains(float px, float py) {
    return dist(px, py, x, y) <= w / 2;
  }
}
