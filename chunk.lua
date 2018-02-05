local lib = {}

local chunk_size = 64
local canvas_mode = "normal"

function lib.new(x,z,t)
  local chunk = {pos={x=x,z=z},voxels={}}

  if t == "fill" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=1, color={1,0.2,0.2}}
        end
      end
    end
  elseif t == "perlin" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
        end
      end
    end
    for ix=1, chunk_size do
      for iz=1, chunk_size do
        local n = math.max(perlin:noise(ix,0.3,iz),0.3)
        for iy=1, math.floor(n*chunk_size) do
          chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.8,0.15}}
        end
      end
    end
  elseif t == "flat" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
          if iy < 9 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.8,0.15}}
          elseif iy < 12 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.4,0.15}}
          end
        end
      end
    end
  elseif t == "test" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
          if iy < 9 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.8,0.15}}
          elseif iy < 12 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.4,0.15}}
          end
        end
      end
    end
    for i=12, 24 do
      chunk.voxels[math.floor(chunk_size/2)][i][math.floor(chunk_size/2)] = {exists=1, color={0.3,0.8,0.15}}
    end
  else --Assume it needs to be empty
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
        end
      end
    end
  end

  chunk.generate_texture = function(self)
    local t = {}
    love.graphics.push()
    -- for ix=1, chunk_size do
    --   for iy=1, chunk_size do
    --     for iz=1, chunk_size do
    --       if self.voxels[ix][iy][iz].exists == 1 then
    --         love.graphics.points((ix-1), (iy-1) + (iz-1)*chunk_size)
    --       end
    --     end
    --   end
    -- end
    for iz=1, chunk_size do
      local c = love.graphics.newCanvas(chunk_size, chunk_size, {format=canvas_mode})
      love.graphics.setCanvas(c)
      love.graphics.clear()
      love.graphics.setColor(1,1,1,1)
      for ix=1, chunk_size do
        for iy=1, chunk_size do
          if self.voxels[ix][iy][iz].exists == 1 then
            love.graphics.points((ix-1), (iy-1))
          end
        end
      end
      love.graphics.setCanvas()
      table.insert(t, c:newImageData())
    end
    self.texture = love.graphics.newVolumeImage(t)
    love.graphics.pop()
  end

  chunk.save_texture = function(self)
    for iz=1, chunk_size do
      local t = self.texture:getLayer(iz)
      t:encode("png", "cubemap.png")
    end
  end

  return chunk
end

return lib
