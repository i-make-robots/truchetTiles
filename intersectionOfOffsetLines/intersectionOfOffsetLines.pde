float gx0,gy0;
float gx1,gy1;
float gx2,gy2;
float gx3,gy3;
float gr0,gr1;
float vx,vy;

float signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}

void setup() {
  size(800,800);
  initPoints();
}

void initPoints() {
  gx0 = random(1,width-1);
  gx1 = random(1,width-1);
  gx2 = random(1,width-1);
  gx3 = random(1,width-1);
  gy0 = random(1,height-1);
  gy1 = random(1,height-1);
  gy2 = random(1,height-1);
  gy3 = random(1,height-1);
  gr0 = random(5,20);
  //gr1 = random(5,20);
  //gr1 = signum(gr0) * abs(gr1);
  gr1=gr0;
  
  vx=0;
  vy=0;
}

void mouseReleased() {
  initPoints();
}

void draw() {
  background(255);
  //test1();
  //test2();
  test3();
}

// test intersection of two lines
void test1() {
  float [] i = findIntersection(
    gx0,gy0,
    gx1,gy1,
    gx2,gy2,
    gx3,gy3);
  
  strokeWeight(1);  stroke(255,0,0);  line(gx0,gy0,gx1,gy1);
  strokeWeight(1);  stroke(0,255,0);  line(gx2,gy2,gx3,gy3);
  strokeWeight(5);  stroke(255,0,0);  point(gx0,gy0);
  strokeWeight(5);  stroke(0,255,0);  point(gx2,gy2);
  strokeWeight(5);  stroke(0,0,255);  point(i[0],i[1]);
}

// get offset of two lines, find intersection from there.
void test2() {
  gx1+=vx/1000.0;
  gy1+=vy/1000.0;
  vx+=random(-50.0,50.0);
  vy+=random(-50.0,50.0);
  
  test2draw();
}

void test2draw() {
  float [] inter = findIntersectionOffset(
    gx0,gy0,
    gx1,gy1,
    gx2,gy2,
    gr0,gr1);

  float[] v0=getOffsetLine(gx0,gy0,gx1,gy1,gr0);
  float[] v1=getOffsetLine(gx1,gy1,gx2,gy2,gr1);

  
  strokeWeight(1);  stroke(255,  0,  0);  line(gx0,gy0,gx1,gy1);
  strokeWeight(1);  stroke(  0,255,  0);  line(gx1,gy1,gx2,gy2);
  strokeWeight(1);  stroke(255,128,  0);  line(v0[0],v0[1],inter[0],inter[1]);
  strokeWeight(1);  stroke(128,255,  0);  line(inter[0],inter[1],v1[2],v1[3]);
  strokeWeight(5);  stroke(  0,  0,255);  point(inter[0],inter[1]);
}

void test3() {
  gx1+=vx/1000.0;
  gy1+=vy/1000.0;
  vx+=random(-50.0,50.0);
  vy+=random(-50.0,50.0);
  
  test2draw();
  gr0=-gr0;
  gr1=-gr1;
  test2draw();  
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
    return new float [] { Float.NaN, Float.NaN };
  }
  
  float t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)) / d;
  //float u = ((x1-x2)*(y1-y3) - (y1-y2)*(x1-x3)) / d;
  
  float ix = x1+t*(x2-x1);
  float iy = y1+t*(y2-y1);
  return new float[] { ix, iy };
}
