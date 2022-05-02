// multi-scale truchet tiles, based on https://christophercarlson.com/portfolio/multi-scale-truchet-patterns/
// this version draws the 15 basic tiles.
// 2022-05-02 dan@marginallyclever.com
//-------------------------------------------------------------
final float tileWidth = 100.0f;
final float third = tileWidth/3.0f;
final float twoThird = tileWidth*2.0f/3.0f;
final float half = tileWidth/2.0f;


void setup() {
  size(800,800);
}


void draw() {
  background(0);
  noStroke();
  
  pushMatrix();
  translate(100+half,100+half);
    pushMatrix();
      drawTile2();
      translate(tileWidth,0);
      drawTile1();
      translate(tileWidth,0);
      drawTile3();
      translate(tileWidth,0);
      drawTile4();
      translate(tileWidth,0);
      drawTile5();
    popMatrix();
    translate(0,tileWidth);
    pushMatrix();
      drawTile6();
      translate(tileWidth,0);
      drawTile7();
      translate(tileWidth,0);
      drawTile8();
      translate(tileWidth,0);
      drawTile9();
      translate(tileWidth,0);
      drawTile10();
      translate(tileWidth,0);
    popMatrix();
    translate(0,tileWidth);
    pushMatrix();
      drawTile11();
      translate(tileWidth,0);
      drawTile12();
      translate(tileWidth,0);
      drawTile13();
      translate(tileWidth,0);
      drawTile14();
      translate(tileWidth,0);
      drawTile15();
      translate(tileWidth,0);
    popMatrix();
  popMatrix();
}


void drawTile1() {
  pushMatrix();
  translate(-half,-half);
  fill(255);
  rect(0,0,tileWidth,tileWidth);
  fill(255,0,0);
  arc(tileWidth,0,twoThird*2,twoThird*2,HALF_PI,PI);  // north east
  arc(0,tileWidth,twoThird*2,twoThird*2,PI+HALF_PI,TWO_PI);  // southwest
  fill(255);
  arc(tileWidth,0,twoThird,twoThird,HALF_PI,PI);  // north east
  arc(0,tileWidth,twoThird,twoThird,PI+HALF_PI,TWO_PI);  // southwest
  popMatrix();
}


void drawTile2() {
  pushMatrix();
  rotate(radians(90));
  drawTile1();
  popMatrix();
}


void drawTile3() {
  pushMatrix();
  translate(-half,-half);
  fill(255);
  rect(0,0,tileWidth,tileWidth);
  fill(255,0,0);
  rect(0,third,tileWidth,third);
  arc(half,0,third,third,0,PI);
  arc(half,tileWidth,third,third,PI,TWO_PI);
  popMatrix();
}

void drawTile4() {
  pushMatrix();
  rotate(radians(90));
  drawTile3();
  popMatrix();
}

void drawTile5() {
  pushMatrix();
  translate(-half,-half);
  fill(255);
  rect(0,0,tileWidth,tileWidth);
  fill(255,0,0);
  arc(half,0,third,third,0,PI);  // north
  arc(half,tileWidth,third,third,PI,TWO_PI);  // south
  arc(tileWidth,half,third,third,HALF_PI,PI+HALF_PI);  // east
  arc(0,half,third,third,PI+HALF_PI,TWO_PI+HALF_PI);  // west
  popMatrix();
}

void drawTile6() {
  pushMatrix();
  translate(-half,-half);
  fill(255,0,0);
  rect(0,0,tileWidth,tileWidth);
  fill(255);
  arc(tileWidth,0,twoThird,twoThird,HALF_PI,PI);
  arc(0,tileWidth,twoThird,twoThird,PI+HALF_PI,TWO_PI);
  arc(0,0,twoThird,twoThird,0,HALF_PI);
  arc(tileWidth,tileWidth,twoThird,twoThird,PI,PI+HALF_PI);
  popMatrix();
}

void drawTile7() {
  pushMatrix();
  translate(-half,-half);
  fill(255);
  rect(0,0,tileWidth,tileWidth);
  fill(255,0,0);
  rect(0,third,tileWidth,third);
  rect(third,0,third,tileWidth);
  popMatrix();
}

void drawTile8() {
  pushMatrix();
  translate(-half,-half);
  fill(255);
  rect(0,0,tileWidth,tileWidth);
  fill(255,0,0);
  arc(half,tileWidth,third,third,PI,TWO_PI);  // south
  arc(0,half,third,third,PI+HALF_PI,TWO_PI+HALF_PI);  // west
  
  fill(255,0,0);
  arc(tileWidth,0,twoThird*2,twoThird*2,HALF_PI,PI);  // north east
  fill(255);
  arc(tileWidth,0,twoThird,twoThird,HALF_PI,PI);  // north east
  popMatrix();
}

void drawTile9() {
  pushMatrix();
  rotate(radians(270));
  drawTile8();
  popMatrix();
}

void drawTile10() {
  pushMatrix();
  rotate(radians(180));
  drawTile8();
  popMatrix();
}

void drawTile11() {
  pushMatrix();
  rotate(radians(90));
  drawTile8();
  popMatrix();
}

void drawTile12() {
  pushMatrix();
  translate(-half,-half);
  fill(255,0,0);
  rect(0,0,tileWidth,twoThird);
  fill(255);
  rect(0,twoThird,tileWidth,third);
  
  arc(tileWidth,0,twoThird,twoThird,HALF_PI,PI);  // north east
  arc(0,0,twoThird,twoThird,0,HALF_PI);  // north west
  
  fill(255,0,0);
  arc(half,tileWidth,third,third,PI,TWO_PI);  // south
  
  popMatrix();
}

void drawTile13() {
  pushMatrix();
  rotate(radians(270));
  drawTile12();
  popMatrix();
}

void drawTile14() {
  pushMatrix();
  rotate(radians(180));
  drawTile12();
  popMatrix();
}

void drawTile15() {
  pushMatrix();
  rotate(radians(270));
  drawTile12();
  popMatrix();
}
