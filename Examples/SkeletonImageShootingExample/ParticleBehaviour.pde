
interface ParticleBehaviour
{
  void updateVertex(int index, float[] v);
  void updateColour(float[] c);
  void calcLifeFactor(int currentLife, int maxLife);
}

//
// Particle Expander!
//

class ParticleExpander implements ParticleBehaviour
{
  float mExpansion = 0.03f;
  int mMaxLife = 2000;
  private float mLifeFactor = 1.0f;

  // default
  ParticleExpander() 
  {
  }

  //
  // pre-calc current life factor - more efficient than doing it for every vertex!
  //
  void calcLifeFactor(int currentLife, int maxLife)
  {
    mLifeFactor = 1.0f - constrain(currentLife/float(mMaxLife), 0.0f, 1.0f);
  }

  //
  // update vertex
  //
  void updateVertex(int index, float[] v)
  {
    v[0] += v[0]*mExpansion;
    v[1] += v[1]*mExpansion;
    v[2] += v[2]*mExpansion;
  }

  //
  // update vertex color
  //
  void updateColour(float[] c)
  {
    // only deal with alpha
    c[3] = mLifeFactor;
  }

  // end class ParticleExpander
}






//
// Particle Mover!
//

class ParticleMover implements ParticleBehaviour
{
  float mExpansion = 0.03f;
  int mMaxLife = 2000;
  private float mLifeFactor = 1.0f;
  float noisiness = 4.0f;

  PVector[] velocities;
  PVector[] accelerations;


  // default
  ParticleMover(int numParticles) 
  { 
    initVelocityAcceleration(numParticles);
  }


  //
  // pre-calc current life factor - more efficient than doing it for every vertex!
  //
  void calcLifeFactor(int currentLife, int maxLife)
  {
    mLifeFactor = 1.0f - constrain(currentLife/float(mMaxLife), 0.0f, 1.0f);
  }

  //
  // update vertex
  //
  void updateVertex(int index, float[] v)
  {
    PVector vel = velocities[index];
    PVector a = accelerations[index];

    vel.x += a.x;
    vel.y += a.y;
    vel.z += a.z;

    v[0] += 0.5f*vel.x*(1.0f+noisiness*noise(v[0]));
    v[1] += 0.5f*vel.y*(1.0f+noisiness*noise(v[1]));
    v[2] += vel.z;
  }


  //
  // update vertex color
  //
  void updateColour(float[] c)
  {
    // only deal with alpha
    c[3] = mLifeFactor;
  }


  void initVelocityAcceleration( int length)
  {
    velocities = new PVector[length];

    for (int i=0; i< velocities.length; ++i)
    {
      velocities[i] = new PVector();
    }

    accelerations = new PVector[length];

    for (int i=0; i< accelerations.length; ++i)
    {
      accelerations[i] = new PVector();
    }
  }

  void initVelocityAcceleration( List<PVector> vel)
  {
    initVelocityAcceleration(vel, null);
  }

  void initVelocityAcceleration( List<PVector> vel, List<PVector> accel )
  {
    velocities = new PVector[vel.size()];
    accelerations = new PVector[vel.size()];

    ListIterator<PVector> li = vel.listIterator();
    for (PVector v : velocities)
    {
      v.set( li.next() );
    }

    if (accel != null)
    {
      li = accel.listIterator();
      for (PVector a : accelerations)
      {
        a.set( li.next() );
      }
    }
  }


  void setVelocities(PVector v)
  {
    for (PVector vel : velocities )
    {
      vel.set(v);
    }
  }

  // end class ParticleExpander
}

