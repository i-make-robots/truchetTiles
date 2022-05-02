//-------------------------------------------------------------
// multi-scale truchet tiles, based on https://christophercarlson.com/portfolio/multi-scale-truchet-patterns/
// this version draws random tiles over the entire area.
// 2022-05-02 dan@marginallyclever.com
//-------------------------------------------------------------
final float tileWidth = 50.0f;
final float third = tileWidth/3.0f;
final float twoThird = tileWidth*2.0f/3.0f;
final float half = tileWidth/2.0f;

final color gc0 = color(0,128,255);
final color gc1 = color(255,255,255);

ArrayList<Integer> tiles = new ArrayList<>();

void setup() {
  size(800,800);
  noStroke();
  
  for(float y=half;y<height;y+=tileWidth) {
    for(float x=half;x<width;x+=tileWidth) {
      tiles.add((int)random(15));
    }
  }
}


void draw() {
  background(0);

  int i=0;
  for(float y=half;y<height;y+=tileWidth) {
    for(float x=half;x<width;x+=tileWidth) {
      pushMatrix();
      translate(x,y);
      drawTile((int)tiles.get(i++),gc0,gc1);
      popMatrix();
    }
  }
}
