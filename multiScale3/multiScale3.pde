//-------------------------------------------------------------
// multi-scale truchet tiles, based on https://christophercarlson.com/portfolio/multi-scale-truchet-patterns/
// this version splits tiles into smaller tiles in a naive way.
// 2022-05-02 dan@marginallyclever.com
//-------------------------------------------------------------
//final float tileWidth = 200.0f;
//final float third = tileWidth/3.0f;
//final float twoThird = tileWidth*2.0f/3.0f;
//final float half = tileWidth/2.0f;
//final float quarter = tileWidth/4.0f;

final color gc0 = color(128,0,255);
final color gc1 = color(255,255,255);

class Cell {
  float x,y;
  float w;
  int tile;
  boolean flip;
  
  Cell [] children;
  
  public Cell(float x,float y,float w,int tile,boolean flip) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.tile=tile;
    this.flip=flip;
  }
  
  // cut into four children
  void tiling() {
    children = new Cell[4];
    float half = this.w/2;
    float quarter = this.w/4;
    float sx = x-quarter;
    float sy = y-quarter;
    
    children[0] = new Cell(sx     ,sy     ,half,(int)random(15),!flip);
    children[1] = new Cell(sx+half,sy     ,half,(int)random(15),!flip);
    children[2] = new Cell(sx+half,sy+half,half,(int)random(15),!flip);
    children[3] = new Cell(sx     ,sy+half,half,(int)random(15),!flip);
    
    for(int i=0;i<4;++i) {
      tiles.add(children[i]);
    }
  }
}

ArrayList<Cell> tiles = new ArrayList<>();


void setup() {
  size(800,800);
  noStroke();
  
  init(128);
}

void init(float tileWidth) {  
  float half = tileWidth/2.0f;

  for(float y=half;y<height+tileWidth;y+=tileWidth) {
    for(float x=half;x<width+tileWidth;x+=tileWidth) {
      tiles.add(new Cell(x,y,tileWidth,(int)random(15),false));
    }
  }
  
  for(int pass=0;pass<5;++pass) {
    int top = tiles.size();
    for(int i=0;i<top;++i) {
      Cell cell = tiles.get(i);
      
      if(random(100)<22) {
        cell.tiling();
      }
    }
  }
}


void draw() {
  background(0);

  for(Cell cell : tiles) {
    if(cell.children!=null) continue;
    pushMatrix();
    translate(cell.x,cell.y);
    if(cell.flip) {
      drawTile(cell.tile,cell.w,gc0,gc1);
    } else {
      drawTile(cell.tile,cell.w,gc1,gc0);
    }
    popMatrix();
  }
}
