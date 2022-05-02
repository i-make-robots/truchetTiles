//-------------------------------------------------------------
// multi-scale truchet tiles, based on https://christophercarlson.com/portfolio/multi-scale-truchet-patterns/
// this version draws the "wings" for each tile.
// 2022-05-02 dan@marginallyclever.com
//-------------------------------------------------------------

final color gc0 = color(0,0,0);
final color gc1 = color(255,255,255);

ArrayList<Cell> tiles = new ArrayList<>();


void setup() {
  size(800,800);
  noStroke();
}

void draw() {
  background(127);
  
  pushMatrix();
  translate(400,400);
  drawTile12(200,gc0,gc1);  // change '12' to any whole number 1...15 to get different tiles
  
  stroke(255,0,0);
  noFill();
  rect(-100,-100,200,200);
  noStroke();
  popMatrix();
}
