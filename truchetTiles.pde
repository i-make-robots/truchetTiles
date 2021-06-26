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


class Point {
  public float x,y;
  
  Point(float xx,float yy) {
    x=xx;
    y=yy;
  }
}

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
int readyState;

void setup() {
  size(960,960);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  
  float cw=20;
  for(float pass=0;pass<=cw;pass++) {
    println(adjustedOffset(10,pass, cw));
  }

  //img = loadImage("tunein-turnon-dropout-karililt.jpg");
  //mask = loadImage("drug.jpg");

  readyState=0;
  selectInput("Select the image picture","imageSelected");
}

void imageSelected(File selection) {
  if(selection == null) {
    exit();
    return;
  }
  img = loadImage(selection.getAbsolutePath());
  img.filter(GRAY);
  readyState=1;
  selectInput("Select the mask picture","maskSelected");
}

void maskSelected(File selection) {
  if(selection == null) {
    exit();
    return;
  }
  mask = loadImage(selection.getAbsolutePath());
  mask.filter(GRAY);
  readyState=2;
  
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

  if(readyState<2) return;
  
  // draw unsorted line segments
  stroke(0);
  unsorted.draw();
  
  // draw sorted line segments
  int i=0;
  for( Line n : sortedLines ) {
    //if(orderedLines.isEmpty()) rainbow(i);  // make pretty colors for to debug
    i+=3;
    n.drawSorted();
  }
  
  // draw ordered line segments
  i=0;
  for( Line n : orderedLines ) {
    //if(!sortedLines.isEmpty()) rainbow(i);  // make pretty colors for to debug
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
  }
  
  f.flush();
  f.close();
  println("Export done");
}


// draw line from start to finish, then go back and do it again but offset where needed to give thickness.
void writeLine2(Line li,PrintWriter f) {
  // find the thickest part of the line, which tells us how many cycles we'll have to make.
  float w=0;
  for(LineSegment s : li.segments) {
    w=max(w,s.weight);
  }
  
  int cw= ceil(w);
  if(cw<1) cw=1;

  boolean first=true;
  LineSegment start = li.segments.get(0);
  
  ArrayList<Point> offsetSequence = new ArrayList<Point>();
    
  // collect all the points, write them at the end.
  for(int pass=0; pass<=cw; ++pass) {
    // add first point at start of line
    float [] s0 = getOffsetLine(
      start.x0,start.y0,
      start.x1,start.y1,
      adjustedOffset(start.weight,pass,cw)
    );

    offsetSequence.add(new Point(s0[0],s0[1]));
    
    // add the middle points of the line
    for(int i=1;i<li.segments.size();++i) {
      LineSegment seg = li.segments.get(i);
      float [] s1 = getOffsetLine(
        seg.x0,seg.y0,
        seg.x1,seg.y1,
        adjustedOffset(seg.weight,pass,cw)
      );
      float [] inter = findIntersection(
        s0[0],s0[1],
        s0[2],s0[3],
        s1[0],s1[1],
        s1[2],s1[3]
      );
      offsetSequence.add(new Point(inter[0],inter[1]));
      s0=s1;
    }
    // add the last point of the line
    offsetSequence.add(new Point(s0[2],s0[3]));
    
    if((pass%2)==1) {
      Collections.reverse(offsetSequence);
    }
    
    // optimize
    ArrayList<Point> newSequence = optimizeLine(offsetSequence);
    
    // write the line to file.
    for( Point p : newSequence ) {
      f.println("G0 X"+tx(p.x)+" Y"+ty(p.y));
      if(first) {
        f.println("G0 Z"+nf2(zDown,0,0));
        first=false;
      }
    }
    offsetSequence.clear();
  }
  
  f.println("G0 Z"+nf2(zUp,0,0));
}

ArrayList<Point> optimizeLine(ArrayList<Point> original) {
  ArrayList<Point> improved = new ArrayList<Point> ();
  int s = original.size(); 
  if(s<3) {
    improved.addAll(original);
    return improved;
  }
  
  Point p0 = original.get(0);
  Point p1 = original.get(1);
  Point p2 = null;
  improved.add(p0);
  
  for(int i=2;i<s;++i) {
    p2=original.get(i);
    // get unit vector a = p1 - p0
    float ax = p1.x-p0.x;
    float ay = p1.y-p0.y;
    float d01 = sqrt(sq(ax)+sq(ay));
    ax/=d01;
    ay/=d01;
    
    // get unit vector b = p1 - p0
    float bx = p2.x-p0.x;
    float by = p2.y-p0.y;
    float d02 = sqrt(sq(bx)+sq(by));
    bx/=d02;
    by/=d02;
    
    // if a==b 
    if( abs(ax-bx)<1e-3 && abs(ay-by)<1e-3) {
      // do nothing
    } else {
      improved.add(p1);
    }
    p0=p1;
    p1=p2;
  }
  if(p2!=null) {
    improved.add(p2);
  }
  
  return improved;
}

float adjustedOffset(float weight,float pass,float cw) {
  float v = pass/cw;
  return (weight*v - weight/2.0) * (4.0/5.0);
}

float[] getOffsetLine(float x0,float y0,float x1,float y1,float r0) {
  // get normal of each line
  float nx01 = y1-y0;
  float ny01 = x0-x1;
  float d01 = sqrt(sq(nx01)+sq(ny01)); 
  nx01/=d01;
  ny01/=d01;
  
  float ox1 = x0+nx01*r0;
  float oy1 = y0+ny01*r0;
  float ox2 = x1+nx01*r0;
  float oy2 = y1+ny01*r0;
  return new float[] { ox1,oy1,ox2,oy2 };
}

float [] findIntersectionOffset(float x0,float y0,float x1,float y1,float x2,float y2,float r0,float r1) {
  float[] v0=getOffsetLine(x0,y0,x1,y1,r0);
  float[] v1=getOffsetLine(x1,y1,x2,y2,r1);
  
  return findIntersection(
    v0[0],v0[1],
    v0[2],v0[3],
    v1[0],v1[1],
    v1[2],v1[3]
    );
}

float [] findIntersection(float x1,float y1,float x2,float y2,float x3,float y3,float x4,float y4) {  
  float d = ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4));
  if(abs(d)<0.01) {
    // lines are colinear (infinite solutions) or parallel (no solutions).
    float ix = (x4+x1)/2;
    float iy = (y4+y1)/2;
    return new float [] { ix, iy };
  }
  
  float t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)) / d;
  //float u = ((x1-x2)*(y1-y3) - (y1-y2)*(x1-x3)) / d;
  
  float ix = x1+t*(x2-x1);
  float iy = y1+t*(y2-y1);
  return new float[] { ix, iy };
}
