class Toy {
  public int id;
  public boolean isTrap;
  public boolean hasBeenTaken;
  // position
  public float x, y;
  public Toy(int id, boolean isTrap, boolean hasBeenTaken) {
    this.id = id;
    this.isTrap = isTrap;
    this.hasBeenTaken = hasBeenTaken;
  }
  public void SetPosition(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
}



class Player {
  public int id;
  public boolean isLoser;
  public Player(int id) {
    this.id = id;
  }
  public void Lost()
  {
    isLoser = true;
  }
}
