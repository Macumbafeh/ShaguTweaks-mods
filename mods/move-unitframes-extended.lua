local _G = _G

local module = ShaguTweaks:register({
  title = "Movable Unit Frames Extended",
  description = "Party frames, Minimap, Buffs, Weapon Buffs and Debuffs can be moved while <Shift> and <Ctrl> are pressed together. Drag the first buff or debuff to move.",
  expansions = { ["tbc"] = true },
  category = "Unit Frames",
  enabled = nil,
})

local movables = { 
  "PartyMemberFrame1",
  "PartyMemberFrame2",
  "PartyMemberFrame3",
  "PartyMemberFrame4"
}

local nonmovables = {
  "Minimap",
  "BuffButton1",
  "DebuffButton1",
  "TempEnchant1", -- weapon buffs
}

module.enable = function(self)
  ShaguTweaks_config = ShaguTweaks_config or {}
  ShaguTweaks_config["MoveUnitframesExtended"] = ShaguTweaks_config["MoveUnitframesExtended"] or {}
  local movedb = ShaguTweaks_config["MoveUnitframesExtended"]

  local unlocker = CreateFrame("Frame", nil, UIParent)
  unlocker:SetAllPoints(UIParent)

  unlocker.movable = nil
  unlocker:SetScript("OnUpdate", function()
    if IsShiftKeyDown() and IsControlKeyDown() then
      if not unlocker.movable then
        for _, frame in pairs(movables) do
          local frameObj = _G[frame]
          if frameObj then
            frameObj:SetUserPlaced(true)
            frameObj:SetMovable(true)
            frameObj:EnableMouse(true)
            frameObj:RegisterForDrag("LeftButton")
            frameObj:SetScript("OnDragStart", function() frameObj:StartMoving() end)
            frameObj:SetScript("OnDragStop", function() frameObj:StopMovingOrSizing() end)
          end
        end

        for _, frame in pairs(nonmovables) do
          local frameObj = _G[frame]
          if frameObj then
            frameObj:SetMovable(true)
            frameObj:EnableMouse(true)
            frameObj:RegisterForDrag("LeftButton")

            if frame == "Minimap" then
              frameObj:SetScript("OnDragStart", function()
                frameObj:StartMoving()
              end)
              frameObj:SetScript("OnDragStop", function()
                frameObj:StopMovingOrSizing()
              end)
            else
              frameObj:SetScript("OnDragStart", function() frameObj:StartMoving() end)
              frameObj:SetScript("OnDragStop", function() frameObj:StopMovingOrSizing() end)
            end
          end
        end

        unlocker.movable = true
        unlocker.grid:Show()
      end
    elseif unlocker.movable then
      for _, frame in pairs(movables) do
        local frameObj = _G[frame]
        if frameObj then
          frameObj:SetScript("OnDragStart", function() end)
          frameObj:SetScript("OnDragStop", function() end)
          frameObj:StopMovingOrSizing()
        end
      end

      for _, frame in pairs(nonmovables) do
        local frameObj = _G[frame]
        if frameObj then
          frameObj:SetScript("OnDragStart", function() end)
          frameObj:SetScript("OnDragStop", function() end)
          frameObj:StopMovingOrSizing()

          if frame == "Minimap" then
            movedb[MinimapCluster:GetName()] = {frameObj:GetLeft(), frameObj:GetTop()}
          else
            movedb[frameObj:GetName()] = {frameObj:GetLeft(), frameObj:GetTop()}
          end
        end
      end      

      unlocker.movable = nil
      unlocker.grid:Hide()
    end
  end)

  unlocker.grid = CreateFrame("Frame", nil, WorldFrame)
  unlocker.grid:SetAllPoints(WorldFrame)
  unlocker.grid:Hide()

  local size = 1
  local line = {}

  local width = GetScreenWidth()
  local height = GetScreenHeight()

  local ratio = width / GetScreenHeight()
  local rheight = GetScreenHeight() * ratio

  local wStep = width / 64
  local hStep = rheight / 64

  -- vertical lines
  for i = 0, 64 do
    if i == 64 / 2 then
      line = unlocker.grid:CreateTexture(nil, 'BORDER')
      line:SetTexture(.8, .6, 0)
    else
      line = unlocker.grid:CreateTexture(nil, 'BACKGROUND')
      line:SetTexture(0, 0, 0, .2)
    end
    line:SetPoint("TOPLEFT", unlocker.grid, "TOPLEFT", i*wStep - (size/2), 0)
    line:SetPoint('BOTTOMRIGHT', unlocker.grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
  end

  -- horizontal lines
  for i = 1, floor(height/hStep) do
    if i == floor(height/hStep / 2) then
      line = unlocker.grid:CreateTexture(nil, 'BORDER')
      line:SetTexture(.8, .6, 0)
    else
      line = unlocker.grid:CreateTexture(nil, 'BACKGROUND')
      line:SetTexture(0, 0, 0, .2)
    end

    line:SetPoint("TOPLEFT", unlocker.grid, "TOPLEFT", 0, -(i*hStep) + (size/2))
    line:SetPoint('BOTTOMRIGHT', unlocker.grid, 'TOPRIGHT', 0, -(i*hStep + size/2))
  end

  -- position nonmovables
  for _, frame in pairs(nonmovables) do
    local frameObj = _G[frame]
    if frameObj then
      if frame == "Minimap" then
        if movedb[MinimapCluster:GetName()] then 
          MinimapCluster:ClearAllPoints()
          MinimapCluster:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", movedb[MinimapCluster:GetName()][1], movedb[MinimapCluster:GetName()][2])
        end
      else
        if movedb[frameObj:GetName()] then
          frameObj:ClearAllPoints()
          frameObj:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", movedb[frameObj:GetName()][1], movedb[frameObj:GetName()][2])
        end
      end
    end
  end
end
