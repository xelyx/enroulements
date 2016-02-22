/** enroulement : exercice sur les similitudes: scale, rotation,translation
 *
 * fait le 20/02/2016 par Jacques Maire
 *
 **/
import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

Scene scene;
InteractiveFrame  f1, utile1, utile2;
Vec[] dc, pc, gc;
int nf;
float tempo;
void setup() {
  size(700, 600, P3D);
  scene = new Scene(this);
  scene.setRadius(1500);
  scene.showAll();
  scene.eye().frame().setRotationSensitivity(0.3f);  
  scene.setGridVisualHint(false);
   scene.setAxesVisualHint(false);
  f1 = new InteractiveFrame(scene);
  f1.translate(0, 0, 0);
  f1.rotate((Rotation)(new Quat(new Vec(0, 1, 1), 1.0)));
  f1.scale(1.06);
  utile1= new InteractiveFrame(scene,f1);
  utile2= new InteractiveFrame(scene,f1);
  nf=36;//nombre de facettes sur les anneaux
  pc=new Vec[nf];
  gc=new Vec[nf];
  dc=new Vec[nf];
  for (int i=0; i<nf; i++) {
    dc[i]=new Vec(40*cos(TWO_PI*i/nf), 40*sin(TWO_PI*i/nf), 0);
    gc[i]=dc[i].get();
    //graphics handers
    f1.addGraphicsHandler(this, "enroulee");
  }
}
void draw() {
  background(55, 55, 0);
  tempo=frameCount*0.01;
  pointLight(255, 255, 0, 5000, 1000, 1000);
   pointLight(255, 255, 0, -1000, 3000, -1000);
  if (scene.mouseAgent().inputGrabber() == f1)  
    fill(255, 0, 0);
  else 
  fill(255, 255, 0);
  f1.draw();
}

void enroulee(PGraphics pg) {
  
  Quat qua=(Quat)f1.orientation();
  qua=Quat.multiply(qua, new Quat(1,-2,1, PI/8));
  Quat qpas=Quat.multiply(new Quat(qua.axis(), qua.angle()*0.1),
  new Quat(new Vec(cos(3*tempo), -2*sin(0.5*tempo), 1+sin(tempo)), 0.3));
  Vec vpas=Vec.multiply(f1.position().get(), 0.02);

  float scalor0=f1.scaling();
  Vec tr=vpas.get();
  Quat qu=qpas.get(); 
  float scalor=scalor0;

  for (int u=0; u<60; u++) {
    utile1.setPosition(tr); 
    utile1.setOrientation((Rotation)qu);
    utile1.setMagnitude(scalor);

    tr=Vec.add(tr, vpas);
    qu=Quat.multiply(qpas, qu);
    scalor=scalor*scalor0;

    utile2.setPosition(tr); 
    utile2.setOrientation((Rotation)qu);
    utile2.setMagnitude(scalor);

    for (int t=0; t<nf; t++)
    {
      pc[t]=gc[t].get();
      pc[t]=utile1.inverseCoordinatesOf(dc[t]);
      gc[t]=utile2.inverseCoordinatesOf(dc[t]);
    }

    pg.noStroke();
    pg.normal(1, 1, 1);
    pg.beginShape(TRIANGLE_STRIP);  
    for (int i=0; i<nf; i++) {    
      pg.vertex(pc[i].x(), pc[i].y(), pc[i].z());
      pg.vertex(gc[i].x(), gc[i].y(), gc[i].z());
    }
    pg.vertex(pc[0].x(), pc[0].y(), pc[0].z());
    pg.vertex(gc[0].x(), gc[0].y(), gc[0].z());
    pg.endShape();
  }
}  