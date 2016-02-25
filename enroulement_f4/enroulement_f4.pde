/** enroulement_f4 : exercice sur les similitudes: scale, rotation,translation
 *
 * fait le 20/02/2016 par Jacques Maire
 *
 **/
import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

Scene scene;
InteractiveFrame  frame1;
Frame utile1, utile2;
Vec[] ptRef, ptSim1, ptSim2;
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
  // frame1 est le repere contenant du sketch
  frame1 = new InteractiveFrame(scene);
  frame1.translate(0, 0, 0);
  frame1.rotate((Rotation)(new Quat(new Vec(0, 1, 0), 1.0)));
  frame1.scale(1.06);
  nf=36;//nombre de facettes sur les anneaux
  ptSim1=new Vec[nf];
  ptSim2=new Vec[nf];
  ptRef=new Vec[nf];
  //initialisation des points de reference et des points au depart de utile2
  for (int i=0; i<nf; i++) {
    ptRef[i]=new Vec(40*cos(TWO_PI*i/nf), 40*sin(TWO_PI*i/nf), 0);
    ptSim2[i]=ptRef[i].get();
    
  }
  //graphics handers
    frame1.addGraphicsHandler(this, "enroulee");
    
  utile1=new Frame(frame1, new Quat(1, 0, 0, 0), 1);
  utile2=new Frame(frame1, new Quat(1, 0, 0, 0), 1);
}


void draw() {
  background(55, 55, 0);
  tempo=frameCount*0.01;
  pointLight(255, 255, 0, 5000, 1000, 1000);
  pointLight(255, 255, 0, -1000, 3000, -1000);
  if (scene.mouseAgent().inputGrabber() == frame1)  
    fill(255, 0, 0);
  else 
  fill(255, 255, 0);
  frame1.draw();
}



void enroulee(PGraphics pg) {
  //Calcul des increments  
  Quat qua=(Quat)frame1.orientation();
  qua=Quat.multiply(qua, new Quat(0, -2, -5, PI/8));
  Quat quatPas=Quat.multiply(new Quat(qua.axis(), qua.angle()*0.1), 
    new Quat(new Vec(2*cos(3*tempo), -4*sin(0.5*tempo), 2+sin(tempo)), 0.3));
  Vec vecPas=Vec.multiply(frame1.position().get(), 0.02);

  //les increments de parametres des deux frames utile1, utile2
  float scalor0=frame1.scaling();
  Vec tr=vecPas.get();
  Quat qu=quatPas.get(); 
  float scalor=scalor0;

  //le dessin est la juxtaposition de 60 bandes
  //les deux lisieres de chaque bande sont les images de la ligne de reference par
  // deux similitudes utile1 et utile2
  for (int u=0; u<60; u++) {
    utile1.setPosition(tr);
    utile1.setOrientation(qu);
    utile1.setMagnitude(scalor);
    tr=Vec.add(tr, vecPas);
    qu=Quat.multiply(quatPas, qu);
    scalor=scalor*scalor0;
    utile2.setPosition(tr);
    utile2.setOrientation(qu);
    utile2.setMagnitude(scalor);

    //les coordonnées des points sur les 2 lisieres formant la bande courante
    for (int t=0; t<nf; t++)
    {   
     ptSim1[t]=utile1.inverseCoordinatesOf(ptRef[t]);
      ptSim2[t]=utile2.inverseCoordinatesOf(ptRef[t]);
    }
    //dessin de la bande courante
    pg.noStroke();
    pg.normal(0,0, 1);
    pg.beginShape(TRIANGLE_STRIP);  
    for (int i=0; i<nf; i++) {    
      pg.vertex(ptSim1[i].x(), ptSim1[i].y(), ptSim1[i].z());
      pg.vertex(ptSim2[i].x(), ptSim2[i].y(), ptSim2[i].z());
    }
    pg.vertex(ptSim1[0].x(), ptSim1[0].y(), ptSim1[0].z());
    pg.vertex(ptSim2[0].x(), ptSim2[0].y(), ptSim2[0].z());
    pg.endShape();
  }
}  