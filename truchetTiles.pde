//--------------------------------------------------------------
// weighted truchet tiles
// 2020-06-14 dan@marginallyclever.com
//--------------------------------------------------------------
import java.util.*;

// CONSTANTS
int lineSpacing = 10;
int tileSize = 10;
int iterSize = 5;
float maxWeight = lineSpacing*2.0/3.0;
float tileAdj = lineSpacing/2;

// pen up angle (for export to gcode)
float zUp=90;
// pen down angle (for export to gcode)
float zDown=40;


// CLASSES
class LineSegment {
  // start of segment
  public float x0,y0;
  // end of segment
  public float x1,y1;
  // line thickness
  public float weight;
  // address of original tile, for faster searching
  public int ax,ay;

  public LineSegment(float x0,float y0,float x1,float y1,int ax,int ay) {
    this.x0=x0;
    this.y0=y0;
    this.x1=x1;
    this.y1=y1;
    this.ax=ax;
    this.ay=ay;
    
    float c=0;
    float cx=(x0+x1)/2;
    float cy=(y0+y1)/2;
    if( cx>=0 && cx<img.width &&
        cy>=0 && cy<img.height ) {
      float darkness = red( img.get((int)cx,(int)cy) );
      c = maxWeight * ((255.0-darkness) / 255.0);
      c = min(c,maxWeight);
    }
    weight = max(c,1);
  }
  
  public void flip() {
    float px=x0;
    float py=y0;
    x0=x1;
    y0=y1;
    x1=px;
    y1=py;
  }
  
  public float [] getDelta() {
    float [] v = new float[2];
    v[0] = x1-x0;
    v[1] = y1-y0;
    return v;
  }
};



class Line {
  public ArrayList<LineSegment> segments = new ArrayList<LineSegment>();
  
  public void draw() {
    for( LineSegment n : segments ) {
      strokeWeight(n.weight);
      line(n.x0,n.y0,n.x1,n.y1);
    }
  }
  
  public void drawSorted() {
    float px=segments.get(0).x0;
    float py=segments.get(0).y0;
    for( LineSegment n : segments ) {
      strokeWeight(n.weight);
      line(px,py,n.x1,n.y1);
      px=n.x1;
      py=n.y1;
    }
  }
  
  public void flip() {
    Collections.reverse(segments);
    for(LineSegment s : segments) {
      s.flip();
    }
  }
}


// GLOBALS
// the unsorted line segments created by the truchet tile generator
Line unsorted = new Line();
// segments sorted for drawing efficiency
ArrayList<Line> sortedLines = new ArrayList<Line>();
// used by sortSegmentsIntoLines()
Line activeLine=null;
// lines sorted for travel efficiency
ArrayList<Line> orderedLines = new ArrayList<Line>();

// the image gives weight to each segment
PImage img;
// the mask controls the direction of each truchet tile.
PImage mask;

// when scoring lines, which end is better?
boolean headBest;


void setup() {
  size(960,960);
  strokeJoin(ROUND);
  strokeCap(ROUND);

  //img = loadImage("tunein-turnon-dropout-karililt.jpg");
  //mask = loadImage("drug.jpg");

  img = loadImage("alan-turing.jpg");
  mask = loadImage("code.jpg");

  img.filter(GRAY);
  mask.filter(GRAY);

  for(int y=0;y<height;y+=tileSize) {
    for(int x=0;x<width;x+=tileSize) {
      //int t = floor(random(2));
      int t = red(mask.get(x,y)) > 128 ? 1:0;
      if(0==t) tileA(x,y);
      else     tileB(x,y);
    }
  }
}

// Interpolate from (x0,y0) to (x1,y1) in steps of length iterSize.
void inter(float x0,float y0,float x1,float y1,int ax,int ay) {
  // get the line length
  float dx = x1-x0;
  float dy = y1-y0;
  float len = sqrt(dx*dx+dy*dy);
  float pieces = len;

  // step many times over the whole line in tiny segments.
  for(float i=0;i<pieces;i+=iterSize) {
    float vA=(i         )/pieces;
    float vB=(i+iterSize)/pieces;
    vB = min(vB,1);
    // find the x/y at the start of the line segment
    float ox = x0+dx*vA;
    float oy = y0+dy*vA;
    // find the x/y at the end of the line segment
    float px = x0+dx*vB;
    float py = y0+dy*vB;
    unsorted.segments.add(new LineSegment(ox,oy,px,py,ax,ay));
  }
}

// style=/
void tileA(float x0,float y0) {
  float x1=x0+tileSize;
  float y1=y0+tileSize;

  for(float x=tileAdj;x<tileSize;x+=lineSpacing) {
    inter(x0+x,y0,x0,y0+x,int(x0/tileSize),int(y0/tileSize));
    inter(x0+x,y1,x1,y0+x,int(x0/tileSize),int(y0/tileSize));
  }
}

// style=\
void tileB(float x0,float y0) {
  float x1=x0+tileSize;
  float y1=y0+tileSize;

  for(float x=tileAdj;x<tileSize;x+=lineSpacing) {
    inter(x0+x,y0,x1,y1-x,int(x0/tileSize),int(y0/tileSize));
    inter(x0+x,y1,x0,y1-x,int(x0/tileSize),int(y0/tileSize));
  }
}

void draw() {
  background(255);

  // draw unsorted line segments
  stroke(0);
  unsorted.draw();
  
  // draw sorted line segments
  int i=0;
  for( Line n : sortedLines ) {
    if(orderedLines.isEmpty()) rainbow(i);
    i+=3;
    n.drawSorted();
  }
  
  // draw ordered line segments
  i=0;
  for( Line n : orderedLines ) {
    if(!sortedLines.isEmpty()) rainbow(i);
    i+=3;
    n.drawSorted();
  }
  
  if(unsorted.segments.size()>0) {
    // if we still have unsorted segments, work on that.  
    for(int j=0;j<5000;++j) {
      sortSegmentsIntoLines();
    }
    if(unsorted.segments.size()==0) {
      // all segments are now in lines.
      for( Line n : sortedLines ) {
        // Check the tail of one segment meets the head of the next.
        flipSegments(n);
        // Some segments are shorter than others.  Smooth them out.
        smoothSegments(n);
      }
    }
  } else {
    for(int j=0;j<10;++j) {
      sortLinesByTravel();
    }
  }
}

// set the stroke color based on a rainbow.
void rainbow(int i) {
  i = 255 - (i & 0xff);
  if(i < 85) {
    stroke(255 - i * 3, 0, i * 3);
  } else if(i < 170) {
    i -= 85;
    stroke(0, i * 3, 255 - i * 3);
  } else {
    i -= 170;
    stroke(i * 3, 255 - i * 3, 0);
  }
}

void sortSegmentsIntoLines() {
  if(unsorted.segments.size()==0) return;

  
  if(activeLine==null) {
    activeLine = new Line(); //<>//
    activeLine.segments.add(unsorted.segments.remove(0));
    sortedLines.add(activeLine);
    //print("\n"+lines.size());
  }
  
  // find an unsorted segment near the ends of activeLine
  LineSegment head = activeLine.segments.get(0);
  LineSegment tail = activeLine.segments.get(activeLine.segments.size()-1);
  
  for( LineSegment s : unsorted.segments ) {
    // try to match with head of line
    if(tryToSort(head,s)) {
      //print("+");
      unsorted.segments.remove(s);
      activeLine.segments.add(0,s);
      return;
    }
    
    // try to match with tail of line
    if(tryToSort(tail,s)) {
      //print("-");
      unsorted.segments.remove(s);
      activeLine.segments.add(s);
      return;
    }
  }

  // did not find any new segments to add.
  activeLine = null;
}

// return true if line segments a and b touch end to end.
boolean tryToSort(LineSegment a,LineSegment b) {
  // reject if truchet index too far apart 
  if(abs(a.ax-b.ax)>1 || abs(a.ay-b.ay)>1) return false;
  
  if(closeEnough(a.x0,a.y0,b.x0,b.y0,0.001)) return true;
  if(closeEnough(a.x0,a.y0,b.x1,b.y1,0.001)) return true;
  if(closeEnough(a.x1,a.y1,b.x0,b.y0,0.001)) return true;
  if(closeEnough(a.x1,a.y1,b.x1,b.y1,0.001)) return true;
  
  return false;
}

boolean closeEnough(float x0,float y0,float x1,float y1,float epsilon) {
  if(abs(x0-x1)>epsilon) return false; //<>//
  if(abs(y0-y1)>epsilon) return false;
  return true; 
}

void flipSegments(Line n) {
  LineSegment tail = n.segments.get(0);
  for(int i=1;i<n.segments.size();++i) {
    LineSegment s = n.segments.get(i);
    // check if s is flipped 
    if( distSq(tail.x1,tail.y1,s.x0,s.y0) > distSq(tail.x1,tail.y1,s.x1,s.y1) ) {
      // it is.  fix it.
      s.flip();
    }
    tail = s;
  }
  // lastly check that the head is the right way around.
  LineSegment head = n.segments.get(0);
  LineSegment headPlus1 = n.segments.get(1);
  if( distSq(head.x1,head.y1,headPlus1.x0,headPlus1.y0) > distSq(head.x0,head.y0,headPlus1.x0,headPlus1.y0) ) {
    // it is.  fix it.
    head.flip();
  }
}

void smoothSegments(Line n) {
  // lines can turn 90 corners.  smooth all segments between two corners.
  Line temp = new Line();
  
  // Find the next corner 
  LineSegment head = n.segments.get(0);
  float [] n0 = head.getDelta();
  int headIndex=0;
  
  for(int i=1;i<n.segments.size();++i) {
    LineSegment s = n.segments.get(i);
    float [] n1 = s.getDelta();
    if(dotProduct(n0,n1) < 0.1) {
      // The deltas are too different.  This segment has turned.
      smoothSection(temp,head,n.segments.get(i-1));
      
      head = s;
      headIndex=i;
      n0=n1;
    }
  }
  if(headIndex<n.segments.size()) {
    // There's a section after a corner.  Maybe we never hit a corner!
    // Either way, make sure that last straight part is processed.
    smoothSection(temp,head,n.segments.get(n.segments.size()-1));
  }
  assert(temp.segments.size()>0);
  
  // temp.segments is now filled with smoothed lines
  n.segments = temp.segments;
}

float dotProduct(float [] a,float [] b) {
  return a[0]*b[0]+a[1]*b[1];
}

void smoothSection(Line temp,LineSegment head,LineSegment s) {
  float dx=s.x1-head.x0;
  float dy=s.y1-head.y0;
  float len = sqrt(dx*dx + dy*dy);
  float pieces = len;//floor(len/iterSize);
  for(float j=0;j<pieces;j+=iterSize) {
    float vA = (j  ) / pieces;
    float vB = (j+iterSize) / pieces;
    vB = min(vB,1);
    float ax=head.x0 + dx*vA;
    float ay=head.y0 + dy*vA;
    float bx=head.x0 + dx*vB;
    float by=head.y0 + dy*vB;
    LineSegment s2 = new LineSegment(ax,ay,bx,by,0,0);
    temp.segments.add(s2);
  }
}

void sortLinesByTravel() {
  if(sortedLines.size()==0) {
    // all done!
    noLoop();
    // export lines as gcode?
    exportLines(orderedLines);
    return;
  }
  
  if(activeLine==null) {
    activeLine = sortedLines.remove(0);
  }
 
  Line best = sortedLines.get(0);
  float bestScore = scoreLine(activeLine,best);
  boolean bestEnd = true;
  
  for( Line b : sortedLines ) {
    float s = scoreLine(activeLine,b);
    if(bestScore>s) {
      bestScore=s;
      bestEnd = headBest;
      best=b;
      
    }
  }
  sortedLines.remove(best);
  if(bestEnd==false) best.flip();  
  orderedLines.add(best);
  activeLine = best;
}

// return min( dist(a.tail,b.head), dist(a.tail,b.tail) )
float scoreLine(Line a,Line b) {
  LineSegment atail = a.segments.get(a.segments.size()-1);
  LineSegment bhead = b.segments.get(0);
  LineSegment btail = b.segments.get(b.segments.size()-1);
  
  float head = distSq(atail.x0,atail.y0,bhead.x0,bhead.y0);
  float tail = distSq(atail.x0,atail.y0,btail.x1,btail.y1);
  
  headBest = head<tail;
  
  return min( head, tail );
}

float distSq(float x0,float y0,float x1,float y1) {
  float dx=x1-x0;
  float dy=y1-y0;
  return dx*dx+dy*dy;
}

  
// replace default nf() with one that doesn't add european conventions.
String nf2(float number,int left,int right) {
  String result = nf((float)number,left,right);
  return result;
}

float tx(float v) {
  return v-(img.width/2);
}

float ty(float v) {
  return (img.height/2)-v;
}

boolean exportOnce=false;
void exportLines(ArrayList<Line> lines) {
  if(exportOnce) return;
  exportOnce=true;
  println("Export start");
  
  PrintWriter f = createWriter("output.ngc");
  f.println("; "+year()+"-"+month()+"-"+day()+" truchetTiles");
  f.println("G28");
  f.println("G0 Z"+nf2(zUp,0,0));
  
  for(Line i : lines) {
    if(i.segments.size()==0) continue;
    
    writeLine2(i,f);
    //writeLine1(i,f);
  }
  
  f.flush();
  f.close();
  println("Export done");
}


void writeLine1(Line li,PrintWriter f) {
  LineSegment start = li.segments.get(0);
  f.println("G0 X"+tx(start.x0)+" Y"+ty(start.y0));
  f.println("G0 Z"+nf2(zDown,0,0));
  for(LineSegment s : li.segments) {
    writeLineSegment1(s,f);
  }
  f.println("G0 Z"+nf2(zUp,0,0));
}

// we want a filled box with the major axis (length) x0,y0-x1,y1 and width s.weight
void writeLineSegment1(LineSegment s,PrintWriter f) {
  float x0=tx(s.x0);
  float y0=ty(s.y0);
  
  float x1=tx(s.x1);
  float y1=ty(s.y1);
  // find a unit vector orthogonal to the original line
  float nx=y1-y0;
  float ny=x0-x1;
  float nd=sqrt(sq((float)nx)+sq((float)ny));
  nx/=nd;
  ny/=nd;
  
  float w=1;
  float limit = (float)s.weight / 2.0;
  
  for(float j=-limit;j<=limit;j+=w) {
    f.println("G0 X"+(x0+nx*j)+" Y"+(y0+ny*j));
    f.println("G0 X"+(x1+nx*j)+" Y"+(y1+ny*j));
  }
  f.println("G0 X"+x1+" Y"+y1);
}

// draw line from start to finish, then go back and do it again but offset where needed to give thickness.
void writeLine2(Line li,PrintWriter f) {
  // find the thickest part of the line, which tells us how many cycles we'll have to make.
  float w=0;
  for(LineSegment s : li.segments) {
    w=max(w,s.weight);
  }
  
  int cw= ceil(w)/2;
  if(cw<1) cw=1;
  
  LineSegment start = li.segments.get(0);
  f.println("G0 X"+tx(start.x0)+" Y"+ty(start.y0));
  f.println("G0 Z"+nf2(zDown,0,0));

  LineSegment pSeg=start;
  for(LineSegment seg : li.segments) {
    writeLineSegment2a(f,seg,pSeg,0,cw);
    pSeg=seg;
  }
  
  for(int pass=1; pass<=cw; ++pass) {
    ListIterator<LineSegment> iter = li.segments.listIterator(li.segments.size());
    while(iter.hasPrevious()) {
      LineSegment seg = iter.previous();
      writeLineSegment2b(f,seg,pSeg,pass,cw);
      pSeg=seg;
    }
    for(LineSegment seg : li.segments) {
      writeLineSegment2a(f,seg,pSeg,pass,cw);
      pSeg=seg;
    }
  }
  f.println("G0 Z"+nf2(zUp,0,0));
}

// we want a filled box with the major axis (length) x0,y0-x1,y1 and width s.weight
void writeLineSegment2a(PrintWriter f,LineSegment s,LineSegment s0,int pass,int cw) {
  float x0=tx(s.x0);
  float y0=ty(s.y0);
  float x1=tx(s.x1);
  float y1=ty(s.y1);
  
  writeLineSegment2c(f,x0,y0,x1,y1,pass,cw,s.weight,s0.weight);
}

// we want a filled box with the major axis (length) x0,y0-x1,y1 and width s.weight
void writeLineSegment2b(PrintWriter f,LineSegment s,LineSegment s0,int pass,int cw) {
  float x1=tx(s.x0);
  float y1=ty(s.y0);
  float x0=tx(s.x1);
  float y0=ty(s.y1);
  writeLineSegment2c(f,x0,y0,x1,y1,pass,cw,s.weight,s0.weight);
}

void writeLineSegment2c(PrintWriter f,float x0,float y0,float x1,float y1,int pass,int cw,float w1,float w0) {
  // find a unit vector orthogonal to the original line
  float nx=y1-y0;
  float ny=x0-x1;
  float nd=sqrt(sq((float)nx)+sq((float)ny));
  
  float div = (float)pass / (float)cw;
  float j0 = (w0/2.0)*div;
  float j1 = (w1/2.0)*div;
  
  nx/=nd;
  ny/=nd;
  
  f.println("G0 X"+(x0+nx*j0)+" Y"+(y0+ny*j0));
  f.println("G0 X"+(x1+nx*j1)+" Y"+(y1+ny*j1));
}
