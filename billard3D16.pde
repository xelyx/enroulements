/* Billard3D16
 * fait par Jacques Maire le 10/02/2016
 */

import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;
import remixlab.proscene.*;

Scene scene;
Arbre arbre;

public void setup() {
  size(600, 600, P3D);
  scene = new Scene(this);  
  scene.setRadius(2200);
  scene.showAll();
  scene.setGridVisualHint(false);
  scene.setAxesVisualHint(false);



  arbre=new Arbre(scene);
  noStroke();
  rectMode(CENTER);
  ellipseMode(RADIUS);
  frameRate(1000);
}



void draw() {
  background(0, 0, 255);
  pointLight(255, 255, 255, 0, 0, 1000);
  //scene.camera().lookAt(new Vec());
  //scene.camera().setPosition(0, 2200, 0);
 // scene.camera().setOrientation(new Quat(cos(-0.65),sin(-0.65),0,0));
  arbre.moteurBoite();
  for (InteractiveFrame frm : scene.frames()) {
    frm.draw(scene.pg());
  }
}




public class Arbre {
  InteractiveFrame  laBoite, laBille; 
  Vec   vBoite, pBoite;
  float largeur, rBille, rayBump, dB;
  int[]  choc;
  int[] chocB;
  Vec[] posBump;
  Scene scene;

  Arbre(Scene s) {


    scene=s;  
    vBoite=new Vec(-45, -45, 40);
    pBoite=new Vec(150, -400, 800);
    largeur=1000;
    rBille=110;
    rayBump=200;
    dB=400;
    chocB=new int[12];
    choc=new int[6];
    posBump=new Vec[12];
    posBump[0]=new Vec(dB, dB*2, dB);
    posBump[1]=new Vec(dB, -dB*2, dB);
    posBump[2]=new Vec(dB, -dB*2, -dB);
    posBump[3]=new Vec(dB, dB*2, -dB);

    posBump[4]=new Vec(-dB, dB*2, dB);
    posBump[5]=new Vec(-dB, -dB*2, dB);
    posBump[6]=new Vec(-dB, -dB*2, -dB);
    posBump[7]=new Vec(-dB, dB*2, -dB);

    posBump[8]=new Vec(-dB, 0, dB);
    posBump[9]=new Vec(-dB, 0, dB);
    posBump[10]=new Vec(-dB, 0, -dB);
    posBump[11]=new Vec(-dB, 0, -dB);

    //l arbre des frames
    laBille  =new InteractiveFrame(scene);
    laBoite  =new InteractiveFrame(scene, laBille);
    laBoite.setPosition(pBoite);
    //graphics handLers
    laBille.addGraphicsHandler(this, "dessinBille");
    laBoite.addGraphicsHandler(this, "dessinBoite");
  }

  void dessinBumps(PGraphics pg) {
    for (int i=0; i<12; i++) {
      pg.pushMatrix();
      pg.translate(posBump[i].x(), posBump[i].y(), posBump[i].z());
      pg.fill((chocB[i]>0)?#FFFF00:#FF0000);
      pg.sphere(rayBump*max(1, 0.04*chocB[i]));
      pg.popMatrix();
    }
  }

  void dessinBoite(PGraphics pg) {
    pg.pushMatrix();
    boitefaces(pg, largeur);
    pg.popMatrix();
    dessinBumps(pg);
  }
  void dessinBille(PGraphics pg) {
    pg.pointLight(55, 55, 55, rBille+5, rBille-100, rBille+5);
    pg.fill(100, 100, 255, 190);    
    pg.sphere(rBille);
  }

  void moteurBoite() {
    Vec ancPos=laBoite.translation();
    Vec  newPos=Vec.add(vBoite, ancPos);

    if (newPos.x()-rBille<-largeur) {
      vBoite.setX(vBoite.x()*-1.0);
      choc[0]=40;
    }
    if (newPos.x()+rBille>largeur) {
      vBoite.setX(vBoite.x()*-1.0);
      choc[1]=40;
    }

    if (newPos.y()-rBille<-largeur*2.0) {
      vBoite.setY(vBoite.y()*-1.0);
      choc[2]=40;
    }
    if (newPos.y()+rBille>largeur*2.0) {
      vBoite.setY(vBoite.y()*-1.0);
      choc[3]=40;
    }
    if (newPos.z()-rBille<-largeur) {
      vBoite.setZ(vBoite.z()*-1.0);
      choc[4]=40;
    }
    if (newPos.z()+rBille>largeur) {
      vBoite.setZ(vBoite.z()*-1.0);
      choc[5]=40;
    }

    for (int i=0; i<12; i++) {
      Vec vite=rebond(i);
      if (vite.magnitude()>0) {
        vBoite=vite.get();
        chocB[i]=40;
      }
    } 
    laBoite.setTranslation(Vec.add(vBoite, laBoite.translation())); 
    for (int i=0; i<6; i++)if (choc[i]>0)choc[i]--; 
    for (int i=0; i<12; i++)if (chocB[i]>0)chocB[i]--;
  }

  void boitefaces(PGraphics pg, float m) {
    float md=m*2.0;
    beginShape(QUADS);
    pg.fill((choc[4]>0)?#FFFF00:color(255, 255, 100, 200));
    pg.vertex(m, md, m);//haut
    pg.vertex(m, -md, m);
    pg.vertex(-m, -md, m);
    pg.vertex(-m, md, m);
    pg.fill(0, 155, 255);
    pg.fill((choc[5]>0)?#FFFF00:color(0, 155, 255));
    pg.vertex(m, md, -m);//bas
    pg.vertex(m, -md, -m);
    pg.vertex(-m, -md, -m);
    pg.vertex(-m, md, -m);
    pg.fill((choc[0]>0)?#FFFF00:color(155, 0, 255));
    pg.vertex(m, md, m);//droit
    pg.vertex(m, -md, m);
    pg.vertex(m, -md, -m);
    pg.vertex(m, md, -m);
    pg.fill(255, 255, 255);
    pg.fill((choc[1]>0)?#FFFF00:color(255, 255, 255));
    pg.vertex(-m, md, m);//gauche
    pg.vertex(-m, -md, m);
    pg.vertex(-m, -md, -m);
    pg.vertex(-m, md, -m);
    endShape();
  }


  Vec rebond(int n) {
    Vec posbump=posBump[n];
    Vec posboit=laBoite.translation();
    Vec norma=Vec.add(posbump, posboit);
    if ( norma.magnitude()>rayBump+rBille) return new Vec();
    else {    
      Vec vitnorma=Vec.projectVectorOnAxis(vBoite, norma);
      Vec vitplan=Vec.projectVectorOnPlane(vBoite, norma);
      return Vec.subtract(vitplan, vitnorma);
    }
  }
}

 