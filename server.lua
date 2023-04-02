local Inventory = exports.ox_inventory
local Target = exports.ox_target

GlobalState.Database = false

-- Gets identifier to check if player can open owner menu
lib.callback.register('dom_fuel:GetIdentifier', function(source)
    local player = GetPlayerIdentifiers(source)[1]
    return(player)
end)

lib.callback.register('dom_fuel:FuelOrderPay', function(source, cost)
    local success = Inventory:RemoveItem(source, 'money', cost, false)
    return success
end)

-- Grabs info from database to fill owner menu
RegisterNetEvent('dom_fuel:GrabStationInfo', function(station)
    local _source = source
    MySQL.single("SELECT * FROM dom_fuel WHERE GasStation = ?", {station},
    function(result)
        if result then 
            TriggerClientEvent('dom_fuel:OpenGasStationMenu', _source, result)
        else 
            print('Couldn\'t get gas station info')
        end 
    end)
end)

-- Grabs info from database to fill admin menu
RegisterNetEvent('dom_fuel:AdminGrabStationInfo', function(input)
    local _source = source
    MySQL.single("SELECT * FROM dom_fuel WHERE GasStation = ?", {input[1]},
    function(result)
        if result then
            TriggerClientEvent('dom_fuel:AdminOpenGasStationMenu', _source, result)
        else 
            print('Couldn\'t get gas station info')
        end
    end)
end)

local function StartDataBaseTimer(result)
    while true do 
        Wait(600000)
        for i = 1, #result do 
                local queries = {
                    {query = "UPDATE dom_fuel SET Gas = ? WHERE GasStation = ?", values = {GlobalState[result[i].GasStation].gas, result[i].GasStation}},
                    {query = "UPDATE dom_fuel SET Money = ? WHERE GasStation = ?", values = {GlobalState[result[i].GasStation].money, result[i].GasStation}},
                    {query = "UPDATE dom_fuel SET Price = ? WHERE GasStation = ?", values = {GlobalState[result[i].GasStation].price, result[i].GasStation}}
                }
                MySQL.transaction(queries, function(success)
                    if success then print('Updated dom_fuel database') else print('Couldn\'t update databse') end 
                end)
        end 
    end 
end 

-- Grabs info from database to create gas stations and create statebags
RegisterNetEvent('dom_fuel:GrabStationOwnership', function()
    local _source = source
    
    if GlobalState.Database then return end 
		
    GlobalState.Database = true
		
    MySQL.query("SELECT GasStation, id, Gas, Money, Price FROM dom_fuel WHERE Owner IS NOT NULL", {},
    function(result)
        if result then 
            TriggerClientEvent('dom_fuel:CreateOwnedGasStations', _source, result)
            for i = 1, #result do 
                if GlobalState[result[i].GasStation] == nil then 
                    GlobalState[result[i].GasStation] = {name = result[i].GasStation, gas = result[i].Gas, money = result[i].Money, price = result[i].Price}
                end
            end 
            
	StartDataBaseTimer(result)
        else 
            print('got no result')
        end 
    end)
end)

-- Updates owner name and id in database
RegisterNetEvent('dom_fuel:UpdateOwner', function(input, result)
    local _source = source
    local identifier = GetPlayerIdentifiers(input[1])[1]
    local name = GetPlayerName(input[1])

    if identifier == nil then 
        lib.notify(_source, {description = 'Couldn\'t get identifier', type = 'error'})
    else 
        local queries = {
            {query = "UPDATE dom_fuel SET id = ? WHERE GasStation = ?", values = {identifier, result.GasStation}},
            {query = "UPDATE dom_fuel SET Owner = ? WHERE GasStation = ?", values = {name, result.GasStation}}
        }
        MySQL.transaction(queries, function(success)
            lib.notify(_source, {description = 'New owner set', type = 'success'})
        end)
    end 
end)

-- Updates fuel price in data base
RegisterNetEvent('dom_fuel:UpdatePrice', function(input, station)
    GlobalState[station] = {name = station, gas = GlobalState[station].gas, money = GlobalState[station].money, price = input[1]}
end)    

-- Updates fuel in the gas station after a delivery
RegisterNetEvent('dom_fuel:UpdateFuel', function(fuel, station)
    GlobalState[station] = {name = station, gas = (GlobalState[station].gas + fuel), money = GlobalState[station].money, price = GlobalState[station].price}
end)

local function PayForFuel(source, price)
    local success = Inventory:RemoveItem(source, 'money', price)

    if success then return true end 

    local money = Inventory:GetItem(source, 'money', false, true)
    lib.notify(source, {description = 'You don\'t have enough money. Missing '..(price - money), type = 'error'})
end 

local function setFuelState(netId, fuel)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local state = vehicle and Entity(vehicle)?.state

    if state then 
        state:set('fuel', fuel, true)
    end 
end 

-- Pay for fuel 
RegisterNetEvent('dom_fuel:pay', function(price, fuel ,netId, station)
    if not PayForFuel(source, price) then return end
    
    fuel = math.floor(fuel)

    setFuelState(netId, fuel)
    GlobalState[station] = {name = station, gas = (GlobalState[station].gas - fuel), money = (GlobalState[station].money + price), price = GlobalState[station].price}

    lib.notify(source, {description = 'You have filled up your car', type = 'success'})
end)

-- Creates vehicle fuel statebagd
RegisterNetEvent('dom_fuel:createStatebag', function(netid, fuel)
	local vehicle = NetworkGetEntityFromNetworkId(netid)
	local state = vehicle and Entity(vehicle).state

	if state and not state.fuel and GetEntityType(vehicle) == 2 and NetworkGetEntityOwner(vehicle) == source then
		state:set('fuel', fuel > 100 and 100 or fuel, true)
	end
end)

-- Withdraw cash from the gas station
RegisterNetEvent('dom_fuel:WithdrawCash', function(input, station)
    if input[1] > GlobalState[station].money then 
        return lib.notify(source, {description = 'You don\'t have enoough money in the gas station', type = 'error'})
    end 

    local canCarry = Inventory:CanCarryItem(source, 'money', input[1], false)
    if not canCarry then 
        return lib.notify(source, {description = 'You don\'t have enough space for the money', type = 'error'})
    end 

    local success = Inventory:AddItem(source, 'money', input[1], false)
    if success then 
        GlobalState[station] = {name = station, gas = GlobalState[station].gas, money = (GlobalState[station].money - input[1]), price = GlobalState[station].price}
    end 
end)

RegisterCommand('admingasstationmenu', function(source)
    if IsPlayerAceAllowed(source, 'admingasstationmenu') then 
        TriggerClientEvent('dom_fuel:admingasstationmenu', source)
    else return end
end, true)
