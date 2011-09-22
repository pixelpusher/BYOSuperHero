void newSwarm()
{
  swarm = new ImageParticleSwarm(this, tex);
 /* 
  if (swarm.makeModel( handPositions ))
  {
    swarms.add( swarm );

    if (swarms.size() > 10)
    {
      ImageParticleSwarm first = swarms.removeFirst();
      first.destroy();
    }
  }
  */
  
  if (swarm.makeModel( triMesh ))
  {
    swarms.add( swarm );

    if (swarms.size() > 10)
    {
      ImageParticleSwarm first = swarms.removeFirst();
      first.destroy();
    }
  }
  
  // clear tri mesh
  triMesh.clear();
  
  
 // handPositions.clear();
}



void handJerked()
{
  Vec3D pos=new Vec3D(leftHandPos.x-width/2, leftHandPos.y-height/2, 0);


  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);

  Vec3D a=pos.add(0, 0, weight);
  Vec3D b=pos.add(0, 0, -weight);

  // store current points for next iteration
  prev = pos;
  p.set(pos);
  q.set(pos);


//handPositions.add(pos);  
}


void handMoved()
{
  // get 3D rotated mouse position
  Vec3D pos=new Vec3D(leftHandPos.x-width/2, leftHandPos.y-height/2, 0);

    text("new pos:" + pos,20,30);
  
    pushMatrix();
    translate(pos.x+width/2,pos.y+height/2);
    image(tex, 0,0, 32, 32);
    popMatrix();

  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);

  // use distance to previous point as target stroke weight
  weight+=(sqrt(pos.distanceTo(prev))*2-weight)*0.1;
  // define offset points for the triangle strip

  println("weight " + weight + " / " + MIN_DIST );

  if (weight > MIN_DIST)
  {
    
    
  //  handPositions.add(pos);
    
    Vec3D a=pos.add(0, 0, weight);
    Vec3D b=pos.add(0, 0, -weight);

    // add 2 faces to the mesh
    triMesh.addFace(p, b, q);
    triMesh.addFace(p, a, b);
    // store current points for next iteration
    prev=pos;
    p=a;
    q=b;
    
    
    //prev.set(pos);
  
  }

  /*
  if (triMesh.getNumVertices() > 600)
  {
    newSwarm();
  }
  */
  
}




void drawMesh() {

  noStroke();    
  fill(255,180,20, 80);
  beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for (Iterator i=triMesh.faces.iterator(); i.hasNext();) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    vertex(f.a);
    vertex(f.b);
    vertex(f.c);
  }
  endShape();
  
}



void drawMeshUniqueVerts() {
//    noStroke();
stroke(255,80);
strokeWeight(6);

beginShape(POINTS);
  // get unique vertices, use with indices
  float[] triVerts = triMesh.getUniqueVerticesAsArray(); 
  for (int i=0; i < triVerts.length; i += 3)
  { 
/*   pushMatrix(); 
    translate(triVerts[i], triVerts[i+1], triVerts[i+2]);
    image(tex,0,0,32,32);
    popMatrix();
    */
    vertex(triVerts[i], triVerts[i+1], triVerts[i+2]);
  }
  endShape();
}


void drawHandPositions()
{
  
  for (Vec3D v : handPositions)
  {
    pushMatrix();
    translate(v.x,v.y,v.z);
    image(tex, 0,0, 32, 32);
    popMatrix();
  }
} 


