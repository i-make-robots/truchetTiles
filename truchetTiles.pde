//--------------------------------------------------------------
// weighted truchet tiles
// 2020-06-14 dan@marginallyclever.com
//--------------------------------------------------------------

int tileSize = 60;
int lineSpacing = 10;
int iterSize = 1;
float maxWeight = lineSpacing*2/3;

int [] grid = {
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,1,1,1,1,0,0,0, 0,1,1,1,1,1,0,0,
  0,1,0,0,0,1,0,0, 0,1,0,0,0,0,1,0,
  0,1,0,0,0,0,1,0, 0,1,0,0,0,0,1,0,
  0,1,0,0,0,0,1,0, 0,1,1,1,1,1,0,0,
  0,1,0,0,0,1,0,0, 0,1,0,0,0,1,0,0,
  0,1,1,1,1,0,0,0, 0,1,0,0,0,0,1,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,1,0,0,0,0,1,0, 0,0,1,1,1,1,0,0,
  0,1,0,0,0,0,1,0, 0,1,0,0,0,0,1,0,
  0,1,0,0,0,0,1,0, 0,1,0,0,0,0,0,0,
  0,1,0,0,0,0,1,0, 0,1,0,0,1,1,1,0,
  0,1,0,0,0,0,1,0, 0,1,0,0,0,0,1,0,
  0,0,1,1,1,1,0,0, 0,0,1,1,1,1,0,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
};

class Line {
  public float x0,y0,x1,y1;
  public float weight;
  
  public Line(float xx0,float yy0,float xx1,float yy1,float w) {
    x0=xx0;
    y0=yy0;
    x1=xx1;
    y1=yy1;
    weight = w;
  }
};


ArrayList<Line> lines = new ArrayList<Line>();

PImage img; 

void setup() {
  size(960,960);
  
  img = loadImage("tunein-turnon-dropout-karililt.jpg");
  img.filter(GRAY);
  img.loadPixels();
  
  int i=0;
  for(int y=0;y<height;y+=tileSize) {
    for(int x=0;x<width;x+=tileSize) {
      int t = grid[i++];
      //int t = floor(random(2));
      if(0==t) tileA(x,y);
      else     tileB(x,y);
    }
  }
}

void inter(int x0,int y0,int x1,int y1) {
  float dx = x1-x0;
  float dy = y1-y0;
  float len = sqrt(dx*dx+dy*dy);
  
  for(float i=0;i<len;i+=iterSize) {
    float ox=(x0+dx*(i)/len);
    float oy=(y0+dy*(i)/len);
    float i2 = min(i+iterSize,len);
    float px=(x0+dx*(i2)/len);
    float py=(y0+dy*(i2)/len);
    float c=0;
    if( px>=0 && px<img.width &&
        py>=0 && py<img.height ) {
      c = (float)(255-red(img.get((int)px,(int)py))) * maxWeight / 255.0;
    }
    c = max(c,1);
    lines.add(new Line(ox,oy,px,py,c));
  }
}

// style=/
void tileA(int x0,int y0) {
  int x1=x0+tileSize;
  int y1=y0+tileSize;
  
  for(int x=0;x<tileSize;x+=lineSpacing) {
    inter(x0+x,y0,x0,y0+x);
    inter(x0+x,y1,x1,y0+x);
  }
}

// style=\
void tileB(int x0,int y0) {
  int x1=x0+tileSize;
  int y1=y0+tileSize;
  
  for(int x=0;x<tileSize;x+=lineSpacing) {
    inter(x0+x,y0,x1,y1-x);
    inter(x0+x,y1,x0,y1-x);
  }
}

void draw() {
  background(255);
  stroke(0);
  
  for( Line n : lines ) {
    strokeWeight(n.weight);
    line(n.x0,n.y0,n.x1,n.y1);
  }   
}
