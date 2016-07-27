# This contains a number of mathematical methods for working with vectors
class Utils
  # This generates two random variables with a normal distribution
  def self.rand_norm
    u1 = rand
    u2 = rand
    r = Math.sqrt(-2.0 * Math.log(u1))
    z0 = r * Math.cos(2 * Math::PI * u2)
    z1 = r * Math.sin(2 * Math::PI * u2)
    [z0, z1]
  end

  # Thia returns the dot product of two vectors
  def self.dotp(a, b)
    a[0] * b[0] + a[1] * b[1]
  end

  # This returns the length squared of a vector
  def self.len2(a)
    dotp(a, a)
  end

  # This returns the length of a vector
  def self.len(a)
    Math.sqrt(len2(a))
  end

  # This returns the angle between two vectors, in the range 0 .. pi
  def self.angle(vec_a, vec_b)
    Math.acos(dotp(vec_a, vec_b) / (len(vec_a) * len(vec_b)))
  end

  # This calculates the projection of vector a onto vector b
  def self.projection(vec_a, vec_b)
    scale = dotp(vec_a, vec_b) / dotp(vec_b, vec_b)
    [scale * vec_b[0], scale * vec_b[1]]
  end
end
