
class Study {
  // Two rows of boxes: the distances and the sizes
  float[] distances = {250, 500, 900};
  float[] widths = {20, 40, 80};

  // An empty box that will hold the 9 cards
  ArrayList<Condition> conditions = new ArrayList<Condition>();

  Study() {
    // Make all 9 cards: every distance with every size
    for (float a : distances) {
      for (float w : widths) {
        conditions.add(new Condition(a, w));
      }
    }
    // Shuffle the deck
    Collections.shuffle(conditions);
  }

  // Show every card, so we can check
  void printConditions() {
    for (Condition c : conditions) {
      println("A = " + c.A + "  W = " + c.W);
    }
  }
}
