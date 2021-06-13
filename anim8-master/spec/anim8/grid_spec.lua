--[[
require 'spec.love-mocks'

local anim8 = require 'anim8'

local newQuad   = love.graphics.newQuad
local newGrid   = anim8.newGrid

describe("anim8", function()

  describe("newGrid", function()
    it("throws error if any of its parameters is not a positive integer", function()
      assert.error(function() newGrid() end)
      assert.error(function() newGrid(1) end)
      assert.error(function() newGrid(1,1,1,-1) end)
      assert.error(function() newGrid(0,1,1,1) end)
      assert.error(function() newGrid(1,1,'a',1) end)
    end)

    it("preserves the values", function()
      local g = newGrid(1,2,3,4,5,6,7)
      assert.equal(1, g.frameWidth)
      assert.equal(2, g.frameHeight)
      assert.equal(3, g.imageWidth)
      assert.equal(4, g.imageHeight)
      assert.equal(5, g.left)
      assert.equal(6, g.top)
      assert.equal(7, g.border)
    end)

    it("calculates width and height", function()
      local g = newGrid(32,32,64,256)
      assert.equal(2, g.width)
      assert.equal(8, g.height)
    end)

    it("presets border and offsets to 0", function()
      local g = newGrid(32,32,64,256)
      assert.equal(0, g.left)
      assert.equal(0, g.top)
      assert.equal(0, g.border)
    end)
  end)

  describe("Grid", function()
    describe("getFrames", function()
      local g, nq
      before_each(function()
        g = newGrid(16,16,64,64)
        nq = function(x,y) return newQuad(x,y, 16,16, 64,64) end
      end)

      describe("with 2 integers", function()
        it("returns a single frame", function()
          assert.equal(nq(0,0), g:getFrames(1,1)[1])
        end)
        it("returns another single frame", function()
          assert.equal(nq(32,16), g:getFrames(3,2)[1])
        end)
        it("throws an error if the frame does not exist", function()
          assert.error(function() g:getFrames(10,10) end)
        end)
      end)

      describe("with several pairs of integers", function()
        it("returns a list of frames", function()
          local frames = g:getFrames(1,3, 2,2, 3,1)
          assert.same({nq(0,32), nq(16,16), nq(32,0)}, frames)
        end)
        it("takes into account border widths", function()
          g = newGrid(16,16,64,64,0,0,1)
          local frames = g:getFrames(1,3, 2,2, 3,1)
          assert.same({nq(1,35), nq(18,18), nq(35,1)}, frames)
        end)
        it("takes into account left and top", function()
          g = newGrid(16,16,64,64,10,20)
          local frames = g:getFrames(1,3, 2,2, 3,1)
          assert.same({nq(10,52), nq(26,36), nq(42,20)}, frames)
        end)
      end)

      describe("with a string and a integer", function()
        it("returns a list of frames", function()
          local frames = g:getFrames('1-2', 2)
          assert.equal(nq(0,16) , frames[1])
          assert.equal(nq(16,16), frames[2])
        end)
        it("throws an error for invalid strings", function()
          assert.error(function() g:getFrames('foo', 1) end)
          assert.error(function() g:getFrames('foo-bar', 1) end)
          assert.error(function() g:getFrames('1-foo', 1) end)
        end)
        it("throws an error for valid strings representing too big indexes", function()
          assert.error(function() g:getFrames('1000-1') end)
        end)
      end)

      describe("with several strings", function()
        it("returns a list of frames", function()
          local frames = g:getFrames('1-2',2, 3,2)
          assert.same({nq(0,16), nq(16,16), nq(32,16)}, frames)
        end)
        it("parses rows first, then columns", function()
          local frames = g:getFrames('1-3','1-3')
          assert.same({ nq(0,0),  nq(16,0),  nq(32,0),
                        nq(0,16), nq(16,16), nq(32,16),
                        nq(0,32), nq(16,32), nq(32,32)
                      },
                      frames)
        end)
        it("counts backwards if the first number in the string is greater than the second one", function()
          local frames = g:getFrames('3-1',2)
          assert.same({nq(32,16), nq(16,16), nq(0,16)}, frames)
        end)
      end)


      describe("with a non-number or string", function()
        it("throws an error", function()
          assert.error(function() g:getFrames({1,10}) end)
        end)
      end)

      describe("When two similar grids are requested for the same quad", function()
        it("is not created twice", function()
          local g2 = newGrid(16,16,64,64)
          local q1 = setmetatable(g:getFrames(1,1)[1], nil)
          local q2 = setmetatable(g2:getFrames(1,1)[1], nil)
          assert.equal(q1, q2)
        end)
      end)

    end)

    describe("()", function()
      it("is a shortcut to :getFrames", function()
        local g = newGrid(16,16,64,64)
        assert.equal(g:getFrames(1,1)[1], g(1,1)[1])
      end)
    end)
  end)
end)
]]--