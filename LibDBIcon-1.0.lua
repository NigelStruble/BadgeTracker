-- LibDBIcon-1.0 - Simplifies Minimap button creation
-- Simplified version for BadgeTracker

local DBICON10 = "LibDBIcon-1.0"
local DBICON10_MINOR = 44
if not LibStub then error(DBICON10 .. " requires LibStub.") end
local lib = LibStub:NewLibrary(DBICON10, DBICON10_MINOR)
if not lib then return end

lib.objects = lib.objects or {}
-- NOTE: This simplified LibDBIcon does not fire callbacks, so it does not
-- depend on CallbackHandler-1.0. Do not re-add a GetLibrary("CallbackHandler-1.0")
-- call here unless CallbackHandler-1.0 is bundled and loaded in the .toc, or the
-- addon will error on load whenever no other addon happens to provide it.
local next, pairs = next, pairs

function lib:Register(name, object, db)
    if not object.icon then error("Can't register " .. name .. ". Missing 'icon'.") end
    if not db or not db.hide then db = db or {}; db.hide = false end
    
    lib.objects[name] = {obj = object, db = db}
    
    if not db.hide then
        lib:Show(name)
    end
end

function lib:Hide(name)
    local button = lib.objects[name]
    if button then
        button.db.hide = true
        if button.obj.frame then
            button.obj.frame:Hide()
        end
    end
end

function lib:Show(name)
    local button = lib.objects[name]
    if not button or not button.obj then return end
    
    button.db.hide = false
    
    if not button.obj.frame then
        lib:CreateButton(name, button.obj, button.db)
    end
    
    button.obj.frame:Show()
    lib:Refresh(name, button.db)
end

function lib:CreateButton(name, object, db)
    local button = CreateFrame("Button", "LibDBIcon10_" .. name, Minimap)
    button:SetFrameStrata("MEDIUM")
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture(136477) -- "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture(136430) -- "Interface\\Minimap\\MiniMap-TrackingBorder"
    overlay:SetPoint("TOPLEFT")
    
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture(object.icon)
    icon:SetPoint("TOPLEFT", 7, -5)
    button.icon = icon
    
    button:SetScript("OnClick", function(self, mouseButton)
        if object.OnClick then
            object:OnClick(mouseButton)
        end
    end)
    
    button:SetScript("OnEnter", function(self)
        if object.OnTooltipShow then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            object:OnTooltipShow(GameTooltip)
            GameTooltip:Show()
        elseif object.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(object.tooltip)
            GameTooltip:Show()
        end
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        lib.drag = name
    end)
    
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        lib.drag = nil
    end)
    
    button:SetScript("OnUpdate", function(self)
        if lib.drag then
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            
            local angle = math.deg(math.atan2(py - my, px - mx))
            local db = lib.objects[lib.drag].db
            db.minimapPos = angle
            lib:Refresh(lib.drag, db)
        end
    end)
    
    object.frame = button
end

function lib:Refresh(name, db)
    local button = lib.objects[name]
    if not button or not button.obj.frame then return end
    
    local angle = math.rad(db.minimapPos or 225)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    
    button.obj.frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function lib:GetMinimapButton(name)
    return lib.objects[name] and lib.objects[name].obj
end
