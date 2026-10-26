class Study {
  // Two rows of boxes: the distances and the sizes
  float[] distances = {250, 500, 900};
  float[] widths = {20, 40, 80};

  // An empty box that will hold the 9 cards
  ArrayList<Condition> conditions = new ArrayList<Condition>();

  int current = 0;   // the finger: which card we're on

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

  // Which card is the finger on?
  Condition currentCondition() {
    return conditions.get(current);
  }

  // Move the finger to the next card
  void next() {
    current = current + 1;
  }

  // Has the finger gone past the last card?
  boolean isFinished() {
    return current >= conditions.size();
  }
}   // <- the very last line: everything above lives inside the dealer's box
