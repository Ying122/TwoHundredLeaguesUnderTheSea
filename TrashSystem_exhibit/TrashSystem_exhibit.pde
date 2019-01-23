
String message;
int force;
int forcePrev;

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Box2DProcessing box2d;

Creature creature;
ArrayList<Trash> trash;
ArrayList<Boundary> boundaries;

float xoff = 100;
float yoff = 10;
boolean pressed = false;
boolean contact = false;
boolean inside = false;
boolean auto = true;

//shader parameter
PShader mShader;
float weight = 7;
float freq = .0003f;
float amp;
boolean circle = false;
float gx;
float gy;
float r=60;

void setup() {
  fullScreen(P3D);
  //size(640,640,P3D);
  
  
  mShader = loadShader("frag.glsl", "vert.glsl");
  mShader.set("weight", weight);
  mShader.set("stroke", 1., .64, .3);
  mShader.set("alphaScale", 1.f);
  strokeWeight(weight); 
  stroke(255);
  blendMode(ADD);
  
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);
  box2d.listenForCollisions();
  
  // Add some boundaries
  boundaries = new ArrayList<Boundary>();
  boundaries.add(new Boundary(width/2, height-5, width, 10));
  boundaries.add(new Boundary(width/2, 5, width, 10));
  boundaries.add(new Boundary(width-5, height/2, 10, height));
  boundaries.add(new Boundary(5, height/2, 10, height));

  creature = new Creature(width/2,height/2,r);
  trash = new ArrayList<Trash>();
}

void draw() {
  noCursor();
  background(0);
  fill(0);
  noStroke();
  rect(1580,0,100,height*2);
  rect(325,0,100,height*2);
  
  // Step through time
  box2d.step();
  
  
  //println(pressed);
  if (auto) {
     int a = millis() % 35000;
     int range = int(random(1000,4000));
  if (a>=0 & a<range) {
    pressed = true;
  }
  else {
    pressed = false;
  }
  }
  //when pressured, generate trash and creature get anxious
  if (pressed) {
     gx = mouseX;
     gy = mouseY;
      
     trash.add(new Trash(gx,gy));
     //freq +=0.0000005;
  }

  freq = constrain(freq,0.0003,0.0004);
  
   //println(freq);
    
  
  //flikered when poked by trash
  if (contact) {
    mShader.set("alphaScale", random(0.5f));
    creature.r -= 1;
    //while (creature.r>30) {creature.r -= 0.0000001;};
    
  }
  else {
    mShader.set("alphaScale", 1.f);
    creature.r+=0.5;
    //while (creature.r<60) {creature.r += 0.000001;};
  }
  
  creature.r = constrain(creature.r,20,60);
  
  //Make an x,y coordinate out of perlin noise to apply force for any direction
  float x = (noise(xoff)-0.5)*width;
  float y = (noise(yoff)-0.5)*height;
  xoff += 0.001;
  yoff += 0.001;
  
  creature.applyForce(new Vec2(x,y));
 
  // Look at all trash
  for (int i = trash.size()-1; i >= 0; i--) {
    Trash t = trash.get(i);
    t.display();
    if (t.done()) {
      trash.remove(i);
      //if (freq>0.0003) {freq -= 0.000001;}
    }
  }
  
  //creature gets anxious when trash gets more
  
  //freq = 0.00001*(trash.size()/30);
  //amp = 15*(1+trash.size()/10);
  //println(amp);
  //amp = map(width-10, 0, width, 0, 50);
  amp = 50 + (trash.size()/25);
  //println(amp);
  
  //boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }
  
  mShader.set("time", (float)millis());
  mShader.set("scale", map(height-10, 0, height, 0, .01) );
  mShader.set("frequency", freq);
  mShader.set("deformAmount", 150.f);
  mShader.set("amplitude", amp);
  mShader.set("circle", circle);
  shader(mShader);
  creature.display();
}

// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if(o1 == null || o2 == null) 
    return;
  // If object 1 is a Box, then object 2 must be a particle
  // Note we are ignoring particle on particle collisions
  if (o1.getClass() == Trash.class && o2.getClass() == Creature.class) {
    contact = true;
  } 
  // If object 2 is a Box, then object 1 must be a particle
  else if (o2.getClass() == Trash.class && o1.getClass() == Creature.class ) {
    contact = true;
  }
}

void endContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if(o1 == null || o2 == null) 
    return;

  // If object 1 is a Box, then object 2 must be a particle
  // Note we are ignoring particle on particle collisions
  if (o1.getClass() == Trash.class && o2.getClass() == Creature.class) {
    contact = false;
  } 
  // If object 2 is a Box, then object 1 must be a particle
  else if (o2.getClass() == Trash.class && o1.getClass() == Creature.class ) {
    contact = false;
  }
}

void mousePressed() {
  pressed = true;
  auto = false;
  print(mouseX,mouseY);
}  

void mouseReleased() {
  pressed = false;
  auto = true;
  
}
