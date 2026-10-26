class Trial {
  String participant;
  String device;
  int block;
  int trial;
  float A;
  float W;
  float ID;
  int MT;
  boolean hit;
  float clickX;
  float clickY;
  float targetX;

  Trial(String participant, String device, int block, int trial,
        float A, float W, int MT, boolean hit,
        float clickX, float clickY, float targetX) {
    this.participant = participant;
    this.device = device;
    this.block = block;
    this.trial = trial;
    this.A = A;
    this.W = W;
    this.MT = MT;
    this.hit = hit;
    this.clickX = clickX;
    this.clickY = clickY;
    this.targetX = targetX;

    // Index of difficulty: ID = log2(A / W + 1)
    this.ID = log(A / W + 1) / log(2);
  }
}
