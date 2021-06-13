function IniQ()
  local Q = {}
  Q[1] = love.graphics.newQuad(1+0,   1, 32, 32, 595, 34)
  Q[2] = love.graphics.newQuad(2+32,  1, 32, 32, 595, 34)
  Q[3] = love.graphics.newQuad(3+64,  1, 32, 32, 595, 34)
  Q[4] = love.graphics.newQuad(4+96,  1, 32, 32, 595, 34) 
  Q[5] = love.graphics.newQuad(5+128, 1, 32, 32, 595, 34) 
  Q[6] = love.graphics.newQuad(6+160, 1, 32, 32, 595, 34)
  Q[7] = love.graphics.newQuad(7+192, 1, 32, 32, 595, 34)
  Q[8] = love.graphics.newQuad(8+224, 1, 32, 32, 595, 34)
  Q[9] = love.graphics.newQuad(9+256, 1, 32, 32, 595, 34)
  Q[10] = love.graphics.newQuad(10+288, 1, 32, 32, 595, 34)
  Q[11] = love.graphics.newQuad(11+320, 1, 32, 32, 595, 34)
  Q[12] = love.graphics.newQuad(12+352, 1, 32, 32, 595, 34)
  Q[13] = love.graphics.newQuad(13+384, 1, 32, 32, 595, 34)
  Q[14] = love.graphics.newQuad(14+416, 1, 32, 32, 595, 34)
  Q[15] = love.graphics.newQuad(15+448, 1, 32, 32, 595, 34)
  Q[16] = love.graphics.newQuad(16+480, 1, 32, 32, 595, 34)
  Q[17] = love.graphics.newQuad(17+512, 1, 32, 32, 595, 34)
  Q[18] = love.graphics.newQuad(18+544, 1, 32, 32, 595, 34)
  return Q
end
function IniQS96()
  return {
  AV = {
    love.graphics.newQuad(0,   0, 32, 48, 96, 192),
    love.graphics.newQuad(32,  0, 32, 48, 96, 192),
    love.graphics.newQuad(64, 0, 32, 48, 96, 192)
  },
  G = {
    love.graphics.newQuad(0,   48, 32, 48, 96, 192),
    love.graphics.newQuad(32,  48, 32, 48, 96, 192),
    love.graphics.newQuad(64, 48, 32, 48, 96, 192)
  },
  D = {
    love.graphics.newQuad(0,   96, 32, 48, 96, 192),
    love.graphics.newQuad(32,  96, 32, 48, 96, 192),
    love.graphics.newQuad(64, 96, 32, 48, 96, 192)
  },
  AR = {
    love.graphics.newQuad(0,   144, 32, 48, 96, 192),
    love.graphics.newQuad(32,  144, 32, 48, 96, 192),
    love.graphics.newQuad(64, 144, 32, 48, 96, 192)
    }
  }
end

function IniQS192()
  return {
  AV = {
    love.graphics.newQuad(0,   0, 64, 64, 192, 256),
    love.graphics.newQuad(64,  0, 64, 64, 192, 256),
    love.graphics.newQuad(128, 0, 64, 64, 192, 256)
  },
  G = {
    love.graphics.newQuad(0,   64, 64, 64, 192, 256),
    love.graphics.newQuad(64,  64, 64, 64, 192, 256),
    love.graphics.newQuad(128, 64, 64, 64, 192, 256)
  },
  D = {
    love.graphics.newQuad(0,   128, 64, 64, 192, 256),
    love.graphics.newQuad(64,  128, 64, 64, 192, 256),
    love.graphics.newQuad(128, 128, 64, 64, 192, 256)
  },
  AR = {
    love.graphics.newQuad(0,   192, 64, 64, 192, 256),
    love.graphics.newQuad(64,  192, 64, 64, 192, 256),
    love.graphics.newQuad(128, 192, 64, 64, 192, 256)
    }
  }
end

function MontureQuads(size)
  return {
  AV = {
    love.graphics.newQuad(0,   0, size, size, size*3, size*4),
    love.graphics.newQuad(size,  0, size, size, size*3, size*4),
    love.graphics.newQuad(size*2, 0, size, size, size*3, size*4)
  },
  G = {
    love.graphics.newQuad(0,   size, size, size, size*3, size*4),
    love.graphics.newQuad(size,  size, size, size, size*3, size*4),
    love.graphics.newQuad(size*2, size, size, size, size*3, size*4)
  },
  D = {
    love.graphics.newQuad(0,   size*2, size, size, size*3, size*4),
    love.graphics.newQuad(size,  size*2, size, size, size*3, size*4),
    love.graphics.newQuad(size*2, size*2, size, size, size*3, size*4)
  },
  AR = {
    love.graphics.newQuad(0,   size*3, size, size, size*3, size*4),
    love.graphics.newQuad(size,  size*3, size, size, size*3, size*4),
    love.graphics.newQuad(size*2, size*3, size, size, size*3, size*4)
    }
  }
end