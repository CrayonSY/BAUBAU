import java.util.Random;

private PFont _freight; 
private Player[] _players;
private Toy[] _toys;
private int _gameState = 1; 
// How many ~~ exist
private int _playerNum = 2, _toyNum, _trapNum=1;
private final int _MAX_PLAYER_NUM = 50;
private int _turn;
// how many toys the players have to pick up.
private int _pickUpNum;
private int _closestToyId;
private int _lostPlayer;
private int _restTrapsNum;

PImage img; 

void setup() {
  _freight = loadFont("FreightDispProBlack-Regular-60.vlw"); 
  size(1024, 878);
  img = loadImage("bone.png");
}
void draw() {
  DisplayUI();
  if(_gameState == 3) _closestToyId = FindClosestToy();
}

void mousePressed()
{
  if(_gameState == 3)
  {
    PickUp();
  }
}

void keyPressed()
{ 
  switch (_gameState)
  {
    // choosing how many players will join the game
    case 1:
      if(_playerNum < _MAX_PLAYER_NUM && (keyCode == RIGHT || keyCode == UP)) _playerNum++;
      if(_playerNum > 2 && (keyCode == LEFT || keyCode == DOWN)) _playerNum--;
      if(_playerNum > 2 && (keyCode == RETURN || keyCode == ENTER))
      {
        _players = new Player[_playerNum];
        for(int i = 0; i < _players.length; i++) _players[i] = new Player(i);
        _toyNum = _playerNum*3;
        SetUpToys();
        _gameState++;
      }
      break;
     
    // choosing how many traps will be set
    case 2:
      if(_trapNum < _playerNum-1 && (keyCode == RIGHT || keyCode == UP)) _trapNum++;
      if(_trapNum > 1 && (keyCode == LEFT || keyCode == DOWN)) _trapNum--;
      if(_trapNum > 1 && (keyCode == RETURN || keyCode == ENTER))
      {
        _restTrapsNum = _trapNum;
        MakeTraps();
        for(int i = 0; i < _toys.length; i++)
        println("id: "+_toys[i].id+" isTrap: "+_toys[i].isTrap);
        SetToyPositions();
        InitializePickUpNum();
        _gameState++; 
      }
      break;
      
    case 4:
      if((keyCode == RETURN || keyCode == ENTER) && _restTrapsNum != 0) _gameState--;
      if(key == ' ') Init();
      break;
  }
}

private void Init()
{
  _gameState = 1;
  _turn = 0;
  InitializePickUpNum();
}

private void DisplayUI()
{
  background(0); 
  textFont(_freight); 
  textAlign(CENTER);
  fill(255); // font-color
  
  switch(_gameState)
  {
    case 1:
      textSize(40);
      text ("How many players?", width/2, height/2-90);
      
      textSize(70);
      text (""+_playerNum, width/2, height/2);
      
      textSize(20);
      text ("Press [arrow-keys] to change the number.\nPress [Enter-key] to go.", width/2, height/2+60); 
      break;
      
    case 2:
      textSize(40);
      text ("How many traps?", width/2, height/2-90);
      
      textSize(70);
      text (""+_trapNum, width/2, height/2);
      
      textSize(20);
      text ("Press [arrow-keys] to change the number.\nPress [Enter-key] to go.", width/2, height/2+60);
      break;
      
    case 3:
      DisplayToys();
      textSize(40);
      text ("Player "+(_turn+1)+", Pick up " + _pickUpNum + " more toys!", width/2, height-100);
      break;
      
    case 4:
      textSize(50);
      text ("Player " + (_lostPlayer +1) + " Lost!", width/2, height/2-60);
      
      textSize(20);
      if(_restTrapsNum == 0)
        text ("Press [Space-key] to restart.", width/2, height/2+60);
      else
        text ("Press [Enter-key] to continue.\nPress [Space-key] to restart.", width/2, height/2+60);
      break;
  }
}

private void SetToyPositions()
{
  Random random = new Random();
  final float SCALE_X = 0.8, SCALE_Y = 0.7;
  for(int i = 0; i < _toyNum; i++)
  {
    float x = (float)(random.nextDouble())*width*SCALE_X +(1-SCALE_X)/2*width;
    float y = (float)(random.nextDouble())*height*SCALE_Y +(1-SCALE_Y)/4*width;
    _toys[i].SetPosition(x,y);
  }
}

private void DisplayToys()
{
  for(Toy toy : _toys) if(!toy.hasBeenTaken) image(img, toy.x, toy.y, 20, 20);
}

private void SetUpToys()
{
  _toys = new Toy[_toyNum];
  for(int i = 0; i < _toys.length; i++) _toys[i] = new Toy(i, false, false);
}

private void MakeTraps()
{
  // get the id of the toys which become a trap.
  int[] randomNumbers = MakeRandomNumbers(_toyNum, _trapNum);
  for(int r : randomNumbers) _toys[r].isTrap = true;
}

// the second argument means how many random numbers you want to get(size of the returned int array)
private int[] MakeRandomNumbers(int maxValue, int size)
{
  int[] randomNumbers = new int[size];
  Random random = new Random();
  for(int a = 0; a < randomNumbers.length; a++)
  {
    randomNumbers[a] = random.nextInt(maxValue);
    
    // Check if the new random number is not the same as any other random numbers.
    int b = 0;
    while(b < a)
    {
      if(randomNumbers[a] == randomNumbers[b])
      {
        randomNumbers[a] = random.nextInt(maxValue);
        b = 0;
      }
      else b++;
    }
  }
  return randomNumbers;
}

private int FindClosestToy()
{
  int id = 0;
  float distance = Float.MAX_VALUE;
  for(int i = 0; i < _toys.length; i++)
  {
    if(_toys[i].hasBeenTaken) continue;
    float dx = mouseX - _toys[i].x;
    float dy = mouseY - _toys[i].y;
    float d = (float)Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2));
    if(d > distance) continue;
    distance = d;
    id = _toys[i].id;
  }
  return id;
}

private void PickUp()
{
  if(_gameState != 3) return;
  _toys[_closestToyId].hasBeenTaken = true;
  
  // When the toy is a trap
  if(_toys[_closestToyId].isTrap)
  {
    _restTrapsNum--;
    _lostPlayer = _turn;
    _players[_turn].isLoser = true;
    _gameState++;
    GainTurn();
  }
  else
  {
    _pickUpNum--;
    if(_pickUpNum == 0) GainTurn();
  }
}

private void GainTurn()
{
  _turn++;
  if(_turn == _playerNum) _turn = 0;
  if(_players[_turn].isLoser) GainTurn();
  InitializePickUpNum();
}

private void InitializePickUpNum()
{
  Random random = new Random();
  // _pickUpNum is between 1 and 3
  _pickUpNum = random.nextInt(3)+1;
}
