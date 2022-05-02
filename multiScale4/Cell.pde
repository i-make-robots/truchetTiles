

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
