--wave sla q porra e essa

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Player = game:GetService('Players').LocalPlayer
local MarketplaceService = game:GetService('MarketplaceService')
local Name = Player.DisplayName or Player.Name or 'Unknown'
local PlayerId = Player.UserId
local Game = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- Removendo a chamada à função indefinida
-- updateuiprocinfo(Name, Game, PlayerId)

repeat wait() until game:IsLoaded() -- precaução

-- Definindo funções globais
getgenv().isnetworkowner = newcclosure(function(part: BasePart): boolean
    return part.ReceiveAge == 0 and not part.Anchored and part.Velocity.Magnitude > 0
end)

getgenv().setfpscap = newcclosure(function(bruh)
    local SetTo = bruh or 0
    if SetTo == 0 then SetTo = SetTo > 0 and 1.0 / SetTo or 1.0 / 10000.0 end
    setfflag("TaskSchedulerTargetFps", tostring(SetTo))
end)

-- Variáveis
local textService = cloneref(game:GetService("TextService"))

local drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3
    }
}

local renv = getrenv()
local genv = getgenv()

local pi = renv.math.pi
local huge = renv.math.huge

local _assert = clonefunction(renv.assert)
local _color3new = clonefunction(renv.Color3.new)
local _instancenew = clonefunction(renv.Instance.new)
local _mathatan2 = clonefunction(renv.math.atan2)
local _mathclamp = clonefunction(renv.math.clamp)
local _mathmax = clonefunction(renv.math.max)
local _setmetatable = clonefunction(renv.setmetatable)
local _stringformat = clonefunction(renv.string.format)
local _typeof = clonefunction(renv.typeof)
local _taskspawn = clonefunction(renv.task.spawn)
local _udimnew = clonefunction(renv.UDim.new)
local _udim2fromoffset = clonefunction(renv.UDim2.fromOffset)
local _udim2new = clonefunction(renv.UDim2.new)
local _vector2new = clonefunction(renv.Vector2.new)

local _destroy = clonefunction(game.Destroy)
local _gettextboundsasync = clonefunction(textService.GetTextBoundsAsync)

local _httpget = clonefunction(game.HttpGet)
local _writecustomasset = writecustomasset and clonefunction(writecustomasset)

-- Função para criar instâncias
local function create(className, properties, children)
    local inst = _instancenew(className)
    for i, v in properties do
        if i ~= "Parent" then
            inst[i] = v
        end
    end
    if children then
        for i, v in children do
            v.Parent = inst
        end
    end
    inst.Parent = properties.Parent
    return inst
end

-- Setup
do
    local fonts = {
        Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    }

    for i, v in fonts do
        game:GetService("TextService"):GetTextBoundsAsync(create("GetTextBoundsParams", {
            Text = "Hi",
            Size = 12,
            Font = v,
            Width = huge
        }))
    end
end

-- Drawing
do
    local drawingDirectory = create("ScreenGui", {
        DisplayOrder = 15,
        IgnoreGuiInset = true,
        Name = "drawingDirectory",
        Parent = gethui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local function updatePosition(frame, from, to, thickness)
        local central = (from + to) / 2
        local offset = to - from
        frame.Position = _udim2fromoffset(central.X, central.Y)
        frame.Rotation = _mathatan2(offset.Y, offset.X) * 180 / pi
        frame.Size = _udim2fromoffset(offset.Magnitude, thickness)
    end

    local itemCounter = 0
    local cache = {}

    local classes = {}
    do
        local line = {}

        function line.new()
            itemCounter = itemCounter + 1
            local id = itemCounter

            local newLine = _setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Color = _color3new(),
                    From = _vector2new(),
                    Thickness = 1,
                    To = _vector2new(),
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = create("Frame", {
                    Name = id,
                    AnchorPoint = _vector2new(0.5, 0.5),
                    BackgroundColor3 = _color3new(),
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = _udim2new(),
                    Size = _udim2new(),
                    Visible = false,
                    ZIndex = 0
                })
            }, line)

            cache[id] = newLine
            return newLine
        end

        function line:__index(k)
            local prop = self._properties[k]
            if prop ~= nil then
                return prop
            end
            return line[k]
        end

        function line:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                self._properties[k] = v
                if k == "Color" then
                    self._frame.BackgroundColor3 = v
                elseif k == "From" then
                    self:_updatePosition()
                elseif k == "Thickness" then
                    self._frame.Size = _udim2fromoffset(self._frame.AbsoluteSize.X, _mathmax(v, 1))
                elseif k == "To" then
                    self:_updatePosition()
                elseif k == "Transparency" then
                    self._frame.BackgroundTransparency = _mathclamp(1 - v, 0, 1)
                elseif k == "Visible" then
                    self._frame.Visible = v
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v
                end
            end
        end

        function line:__iter()
            return next, self._properties
        end

        function line:__tostring()
            return "Drawing"
        end

        function line:Destroy()
            cache[self._id] = nil
            self.__OBJECT_EXISTS = false
            _destroy(self._frame)
        end

        function line:_updatePosition()
            local props = self._properties
            updatePosition(self._frame, props.From, props.To, props.Thickness)
        end

        line.Remove = line.Destroy
        classes.Line = line
    end

    do
        local circle = {}

        function circle.new()
            itemCounter = itemCounter + 1
            local id = itemCounter

            local newCircle = _setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Color = _color3new(),
                    Filled = false,
                    NumSides = 0,
                    Position = _vector2new(),
                    Radius = 0,
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = create("Frame", {
                    Name = id,
                    AnchorPoint = _vector2new(0.5, 0.5),
                    BackgroundColor3 = _color3new(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = _udim2new(),
                    Size = _udim2new(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UICorner", {
                        Name = "_corner",
                        CornerRadius = _udimnew(1, 0)
                    }),
                    create("UIStroke", {
                        Name = "_stroke",
                        Color = _color3new(),
                        Thickness = 1
                    })
                })
            }, circle)

            cache[id] = newCircle
            return newCircle
        end

        function circle:__index(k)
            local prop = self._properties[k]
            if prop ~= nil then
                return prop
            end
            return circle[k]
        end

        function circle:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties
                props[k] = v
                if k == "Color" then
                    self._frame.BackgroundColor3 = v
                    self._frame._stroke.Color = v
                elseif k == "Filled" then
                    self._frame.BackgroundTransparency = v and 0 or 1
                elseif k == "Position" then
                    self._frame.Position = _udim2fromoffset(v.X, v.Y)
                elseif k == "Radius" then
                    self._frame.Size = _udim2fromoffset(v * 2, v * 2)
                elseif k == "Thickness" then
                    self._frame._stroke.Thickness = v
                elseif k == "Transparency" then
                    self._frame.BackgroundTransparency = v
                    self._frame._stroke.Transparency = _mathclamp(1 - v, 0, 1)
                elseif k == "Visible" then
                    self._frame.Visible = v
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v
                end
            end
        end

        function circle:__iter()
            return next, self._properties
        end

        function circle:__tostring()
            return "Drawing"
        end

        function circle:Destroy()
            cache[self._id] = nil
            self.__OBJECT_EXISTS = false
            _destroy(self._frame)
        end

        circle.Remove = circle.Destroy
        classes.Circle = circle
    end

    do
        local text = {}

        function text.new()
            itemCounter = itemCounter + 1
            local id = itemCounter

            local newText = _setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Center = false,
                    Color = _color3new(),
                    Font = 1,
                    Outline = false,
                    OutlineColor = _color3new(),
                    Position = _vector2new(),
                    Size = 12,
                    Text = "",
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = create("TextLabel", {
                    Name = id,
                    AnchorPoint = _vector2new(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = _udim2new(),
                    Size = _udim2new(),
                    Text = "",
                    TextColor3 = _color3new(),
                    TextSize = 12,
                    TextStrokeColor3 = _color3new(),
                    TextTransparency = 0,
                    TextStrokeTransparency = 1,
                    TextWrapped = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Visible = false,
                    ZIndex = 0
                })
            }, text)

            cache[id] = newText
            return newText
        end

        function text:__index(k)
            local prop = self._properties[k]
            if prop ~= nil then
                return prop
            end
            return text[k]
        end

        function text:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties
                props[k] = v
                if k == "Center" then
                    self._frame.AnchorPoint = v and _vector2new(0.5, 0.5) or _vector2new()
                    self._frame.Position = v and _udim2fromoffset(self._frame.AbsolutePosition.X + (self._frame.AbsoluteSize.X / 2), self._frame.AbsolutePosition.Y + (self._frame.AbsoluteSize.Y / 2)) or _udim2fromoffset(self._frame.AbsolutePosition.X, self._frame.AbsolutePosition.Y)
                elseif k == "Color" then
                    self._frame.TextColor3 = v
                elseif k == "Font" then
                    self._frame.FontFace = v
                elseif k == "Outline" then
                    self._frame.TextStrokeTransparency = v and 0 or 1
                elseif k == "OutlineColor" then
                    self._frame.TextStrokeColor3 = v
                elseif k == "Position" then
                    self._frame.Position = _udim2fromoffset(v.X, v.Y)
                elseif k == "Size" then
                    self._frame.TextSize = v
                elseif k == "Text" then
                    self._frame.Text = v
                elseif k == "Transparency" then
                    self._frame.TextTransparency = _mathclamp(1 - v, 0, 1)
                elseif k == "Visible" then
                    self._frame.Visible = v
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v
                end
            end
        end

        function text:__iter()
            return next, self._properties
        end

        function text:__tostring()
            return "Drawing"
        end

        function text:Destroy()
            cache[self._id] = nil
            self.__OBJECT_EXISTS = false
            _destroy(self._frame)
        end

        text.Remove = text.Destroy
        classes.Text = text
    end

    do
        local square = {}

        function square.new()
            itemCounter = itemCounter + 1
            local id = itemCounter

            local newSquare = _setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Color = _color3new(),
                    Filled = false,
                    Position = _vector2new(),
                    Size = _vector2new(),
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = create("Frame", {
                    Name = id,
                    AnchorPoint = _vector2new(),
                    BackgroundColor3 = _color3new(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = _udim2new(),
                    Size = _udim2new(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UIStroke", {
                        Name = "_stroke",
                        Color = _color3new(),
                        Thickness = 1
                    })
                })
            }, square)

            cache[id] = newSquare
            return newSquare
        end

        function square:__index(k)
            local prop = self._properties[k]
            if prop ~= nil then
                return prop
            end
            return square[k]
        end

        function square:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties
                props[k] = v
                if k == "Color" then
                    self._frame.BackgroundColor3 = v
                    self._frame._stroke.Color = v
                elseif k == "Filled" then
                    self._frame.BackgroundTransparency = v and 0 or 1
                elseif k == "Position" then
                    self._frame.Position = _udim2fromoffset(v.X, v.Y)
                elseif k == "Size" then
                    self._frame.Size = _udim2fromoffset(v.X, v.Y)
                elseif k == "Thickness" then
                    self._frame._stroke.Thickness = v
                elseif k == "Transparency" then
                    self._frame.BackgroundTransparency = v
                    self._frame._stroke.Transparency = _mathclamp(1 - v, 0, 1)
                elseif k == "Visible" then
                    self._frame.Visible = v
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v
                end
            end
        end

        function square:__iter()
            return next, self._properties
        end

        function square:__tostring()
            return "Drawing"
        end

        function square:Destroy()
            cache[self._id] = nil
            self.__OBJECT_EXISTS = false
            _destroy(self._frame)
        end

        square.Remove = square.Destroy
        classes.Square = square
    end

    do
        local image = {}

        function image.new()
            itemCounter = itemCounter + 1
            local id = itemCounter

            local newImage = _setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Data = "",
                    Position = _vector2new(),
                    Rounding = 0,
                    Size = _vector2new(),
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = create("ImageLabel", {
                    Name = id,
                    AnchorPoint = _vector2new(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Image = "",
                    Parent = drawingDirectory,
                    Position = _udim2new(),
                    Size = _udim2new(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UICorner", {
                        Name = "_corner",
                        CornerRadius = _udimnew()
                    })
                })
            }, image)

            cache[id] = newImage
            return newImage
        end

        function image:__index(k)
            local prop = self._properties[k]
            if prop ~= nil then
                return prop
            end
            return image[k]
        end

        function image:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties
                props[k] = v
                if k == "Data" then
                    if v:find("rbxasset://") or v:find("http://") or v:find("https://") then
                        self._frame.Image = v
                    else
                        if _writecustomasset then
                            local success, result = pcall(function()
                                return _writecustomasset("Drawing_" .. self._id .. "_Image.png", _httpget(v))
                            end)
                            if success then
                                self._frame.Image = result
                            end
                        end
                    end
                elseif k == "Position" then
                    self._frame.Position = _udim2fromoffset(v.X, v.Y)
                elseif k == "Rounding" then
                    self._frame._corner.CornerRadius = _udimnew(v, 0)
                elseif k == "Size" then
                    self._frame.Size = _udim2fromoffset(v.X, v.Y)
                elseif k == "Transparency" then
                    self._frame.ImageTransparency = _mathclamp(1 - v, 0, 1)
                elseif k == "Visible" then
                    self._frame.Visible = v
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v
                end
            end
        end

        function image:__iter()
            return next, self._properties
        end

        function image:__tostring()
            return "Drawing"
        end

        function image:Destroy()
            cache[self._id] = nil
            self.__OBJECT_EXISTS = false
            _destroy(self._frame)
        end

        image.Remove = image.Destroy
        classes.Image = image
    end

    drawing.new = function(type)
        return classes[type].new()
    end

    drawing.Remove = function(obj)
        return obj:Destroy()
    end

    drawing.Classes = classes

    genv.Drawing = drawing
end
