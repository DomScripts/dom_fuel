local Target = exports.ox_target
local Input = lib.inputDialog
local Zone = lib.zones
local Inventory = exports.ox_inventory

local inJob = false
local GotFuelJob = false
local hasFuelNozzle = false
local isPump = false

local function GetModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(100)
    end
end 

-- Formats values with a (,) for front end display
function comma_value_format(n)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- Create the owned gas stations
TriggerServerEvent('dom_fuel:GrabStationOwnership')
RegisterNetEvent('dom_fuel:CreateOwnedGasStations', function(result)
    for i = 1, #result do 
        local station = result[i].GasStation
        for k, v in pairs(Data.Stations) do
            if v.name == station then 
                -- Creates blip is true
                if Config.Blip.Toggle then 
                    local blip = AddBlipForCoord(v.coords)
                    SetBlipSprite(blip, 361)
                    SetBlipDisplay(blip, 2)
                    SetBlipScale(blip, Config.Blip.Scale)
                    SetBlipColour(blip, Config.Blip.Color)
                    AddTextEntry('FUEL BLIP', 'Gas Station')
                    BeginTextCommandSetBlipName('FUEL BLIP')
                    EndTextCommandSetBlipName(blip)
                end 
                -- Creates target for owner menu
                Target:addSphereZone({
                    coords = v.ownerMenu,
                    radius = Config.PumpTarget.Radius,
                    debug = Config.Debug,
                    options = {{
                        name = 'OwnerMenu',
                        icon = 'fa-solid fa-laptop',
                        distance = Config.PumpTarget.Distance,
                        label = 'Gas Station Details',
                        onSelect = function()
                            lib.callback('dom_fuel:GetIdentifier', false, function(player)
                                if player ~= result[i].id then 
                                    lib.notify({title = v.name..' Gas Station', description = 'You don\'t have the log-in', type = 'error'})
                                else 
                                    local station = v.name
                                    TriggerEvent('dom_fuel:OpenGasStationMenu', station)
                                end 
                            end)
                        end 
                    }}
                })
                -- Creates target for the pumps
		-- Someone tell Linden to allow a way to pass a variable when referencing a function in a ox_target on select so I don't have to nest a rainbow
                for b = 1, #v.pumps do 
                    Target:addSphereZone({
                        coords = v.pumps[b],
                        radius = Config.PumpTarget.Radius,
                        debug = Config.Debug,
                        options = {{
                            name = 'Pump',
                            icon = 'fas fa-gas-pump',
                            distance = Config.PumpTarget.Distance,
                            label = 'Fuel Pump',
                            onSelect = function()
                                lib.registerContext({
                                    id = 'pump_menu',
                                    title = station..' Gas Pump',
                                    options = {
                                        {
                                            title = 'Price',
                                            description = '$'..GlobalState[station].price..' / per gallon',
                                        },
                                        {
                                            title = 'Pick Up Nozzle',
                                            onSelect = function()
                                                if hasFuelNozzle == true then return end 
                                                hasFuelNozzle = true  
                                                GetModel('prop_cs_fuel_nozle')
                                                fuelNozzle = CreateObject(GetHashKey('prop_cs_fuel_nozle'), 1.0, 1.0, 1.0, true, true, false)
                                                AttachEntityToEntity(fuelNozzle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 18905), 0.13, 0.04, 0.01, -42.0, -115.0, -63.42, false, true, false, true, 0, true)
                                                    
                                                local VehicleFuelOptions = {{
                                                    name = 'Fuel_Car:option1',
                                                    icon = 'fa-solid fa-droplet',
                                                    distance = Config.PumpTarget.Distance,
                                                    label = 'Fuel Car',
                                                    onSelect = function()                                            
                                                        lib.registerContext({
                                                            id = 'Fuel_Car_Menu',
                                                            title = 'Fuel Car',
                                                            options = {
                                                                {
                                                                    title = 'Price',
                                                                    description = '$'..GlobalState[station].price..' / per gallon',
                                                                },
                                                                {
                                                                    title = 'Fuel Car',
                                                                    onSelect = function()
                                                                        local vehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 2, false)
                                                                        local state = Entity(vehicle).state
                                                                        local fuel  = state.fuel or GetVehicleFuelLevel(vehicle)
                                                                        local price, money = 0
                                                                        local duration = math.ceil((100 - fuel) / Config.Refill.RefillValue) * Config.Refill.RefillTick

                                                                        if 100 - fuel < Config.Refill.RefillValue then 
                                                                            return lib.notify({description = 'The fuel tank is full', type = 'error'})
                                                                        end 

                                                                        if 100 - fuel > GlobalState[station].gas then 
                                                                            return lib.notify({description = 'There isn\'t enough fuel in the station', type = 'error'})
                                                                        end

                                                                        money = getMoney()

                                                                        if GlobalState[station].price > money then 
                                                                            return lib.notify({description = 'You don\'t have enough money', type = 'error'})
                                                                        end 

                                                                        isFueling = true

                                                                        TaskTurnPedToFaceEntity(PlayerPedId(), vehicle, duration)
                                                                        Wait(500)

                                                                        CreateThread(function()
                                                                            lib.progressCircle({
                                                                                duration = duration,
                                                                                label = 'Fueling Car',
                                                                                position = 'bottom',
                                                                                useWhileDead = false,
                                                                                canCancel = true,
                                                                                disable = {
                                                                                    move = true,
                                                                                    car = true,
                                                                                    combat = true,
                                                                                },
                                                                                anim = {
                                                                                    dict = 'timetable@gardener@filling_can',
                                                                                    clip = 'gar_ig_5_filling_can',
                                                                                }
                                                                            })

                                                                            isFueling = false
                                                                        end)

                                                                        while isFueling do 
                                                                            price += GlobalState[station].price

                                                                            if price + GlobalState[station].price >= money then 
                                                                                lib.cancelProgress()
                                                                            end

                                                                            fuel += Config.Refill.RefillValue

                                                                            if fuel >= 100 then 
                                                                                isFueling = false
                                                                                fuel = 100.0
                                                                            end 

                                                                            Wait(Config.Refill.RefillTick)
                                                                        end 

                                                                        ClearPedTasks(PlayerPedId())

                                                                        TriggerServerEvent('dom_fuel:pay', price, fuel, NetworkGetNetworkIdFromEntity(vehicle), station)

                                                                    end 
                                                                }
                                                                }
                                                        })
                                                            lib.showContext('Fuel_Car_Menu')
                                                        end 
                                                }}
                                                Target:addGlobalVehicle(VehicleFuelOptions)
                                            end 
                                        },
                                        {
                                            title = 'Return Nozzle',
                                            onSelect = ReturnFuelNozzel
                                        }
                                    }
                                })
                                lib.showContext('pump_menu')
                            end 
                        }}
                    })
                end
            end 
        end 
    end
end)

function ReturnFuelNozzel()
    hasFuelNozzle = false
    DeleteEntity(fuelNozzle)                                        
    Target:removeGlobalVehicle('Fuel_Car:option1')
end 

function getMoney()
    local count = Inventory:Search('count', 'money')
    return count
end 

-- Admin drop down menu
RegisterNetEvent('dom_fuel:admingasstationmenu', function()
    local input = Input('Select a Gas Station', {
        {
            type = 'select',
            options = {
                {value = 'Grove Street', label = value},
                {value = 'Strawberry Ave', label = value},
                {value = 'El Rancho Blvd', label = value},
                {value = 'Popular St', label = value},
                {value = 'Mirror Park Blvd', label = value},
                {value = 'Clinton Ave', label = value},
                {value = 'North Rockford Dr - 1', label = value},
                {value = 'West Eclipse Blvd', label = value},
                {value = 'North Rockford Dr - 2', label = value},
                {value = 'Calais Ave', label = value},
                {value = 'Palomino Freeway', label = value},
                {value = 'Innocence Blvd', label = value},
                {value = 'Macdonald St', label = value},
                {value = 'Lindsay Circus', label = value},
                {value = 'Route 68 - 1', label = value},
                {value = 'Route 68 - 2', label = value},
                {value = 'Route 68 - 3', label = value},
                {value = 'Route 68 - 4', label = value},
                {value = 'Route 68 - 5', label = value},
                {value = 'Senora Way', label = value},
                {value = 'Senora Freeway', label = value},
                {value = 'Alhambra Dr', label = value},
                {value = 'Grapseed Main St', label = value},
                {value = 'Panorama Dr', label = value},
                {value = 'Great Ocean Hwy - 1', label = value},
                {value = 'Great Ocean Hwy - 2', label = value},
                {value = 'Paleto Bvld', label = value}
            }
        }
    })

    if not input then return else 
        TriggerServerEvent('dom_fuel:AdminGrabStationInfo', input)
    end 
end)

function CanDoFuelOrder(fuel, cost, duration, station, dropoff)
    if ((GlobalState[station].gas + fuel) <  Config.FuelOrder.MaxFuel) then 
        if GotFuelJob == false then 
            lib.callback('dom_fuel:FuelOrderPay', false , function(success)
                local success1 = success
                if success1 == true then 
                    GotFuelJob = true
                    FuelOrderStart(fuel, cost, duration, dropoff, station)
                    lib.notify({description = 'Go pickup the truck', type = 'inform'})
                else 
                    lib.notify({description = 'You don\'t have enough money', type = 'error'})
                end 
            end, cost)
        else 
            lib.notify({description = 'You already have a job to do', type = 'error'})
        end 
    else 
        lib.notify({description = 'You can\'t hold anymore fuel', type = 'error'})
    end 
end 

-- Owner Gas Station Menu
RegisterNetEvent('dom_fuel:OpenGasStationMenu', function(station)
    local GasFormated = comma_value_format(GlobalState[station].gas)
    local MoneyFormated = comma_value_format(GlobalState[station].money)
    local dropoff
    for k, v in pairs(Data.Stations) do 
        if v.name == station then 
            dropoff = v.coords
        end 
    end 

    lib.registerContext({
        id = 'OrderFuel',
        title = station..' Fuel Order',
        options = {
            {
                title = 'Small Order',
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Small.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Small.fuel)}
                },
                onSelect = function()
                    local fuel = Config.FuelOrder.Small.fuel
                    local cost = Config.FuelOrder.Small.cost
                    local duration = Config.FuelOrder.Small.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
            {
                title = 'Medium Order',
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Medium.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Medium.fuel)}
                },
                onSelect = function()
                    local fuel = Config.FuelOrder.Medium.fuel
                    local cost = Config.FuelOrder.Medium.cost
                    local duration = Config.FuelOrder.Medium.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
            {
                title = 'Large Order',
                metadata = {
                    {label = 'Cost', value = '$'..comma_value_format(Config.FuelOrder.Large.cost)},
                    {label = 'Fuel', value = comma_value_format(Config.FuelOrder.Large.fuel)}
                },
                onSelect = function()
                    local fuel = Config.FuelOrder.Large.fuel
                    local cost = Config.FuelOrder.Large.cost
                    local duration = Config.FuelOrder.Large.duration
                    CanDoFuelOrder(fuel, cost, duration, station, dropoff)
                end 
            },
        }
    })

    lib.registerContext({
        id = 'GasStationMenu',
        title = station..' Gas Station',
        options = {
            {
                title = 'Money',
                description = MoneyFormated,
                onSelect = function()
                    local input = Input('Withdraw from '..station, {
                        {type = 'number', icon = 'fa-solid fa-dollar-sign'}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:WithdrawCash', input, station)
                    end 
                end 
            },
            {
                title = 'Gas',
                description = GasFormated..' / 100,000',
                progress = ((GlobalState[station].gas/Config.FuelOrder.MaxFuel)*100),
                colorScheme = 'orange'
            },
            {
                title = 'Price',
                description = '$'..GlobalState[station].price..' / per gallon',
                onSelect = function()
                    local input = Input('Set the price of '..station, {
                        {type = 'number', icon = 'fa-solid fa-dollar-sign'}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:UpdatePrice', input, station)
                    end 
                end 
            },
            {
                title = 'Order Fuel',
                description = 'Order more fuel for your gas station',
                menu = 'OrderFuel'
            }
        }
    })
    lib.showContext('GasStationMenu')
end)

-- Admins gas station info menu
RegisterNetEvent('dom_fuel:AdminOpenGasStationMenu', function(result)
    if result.Owner == nil then 
        result.Owner = 'Gas station not owned'
    end 

    local MoneyFormated = comma_value_format(result.Money)


    local GasFormated = comma_value_format(result.Gas)

    lib.registerContext({
        id = 'AdminGasStationMenu',
        title = result.GasStation.." Gas Station",
        options = {
            {
                title = 'Ownership',
                description = result.Owner,
                onSelect = function()
                    local input = Input('Set an owner of '..result.GasStation, {
                        {type = 'number', label = 'Enter a Server ID', icon = 'hashtag'}
                    })
                    if not input then return else 
                        TriggerServerEvent('dom_fuel:UpdateOwner', input, result)
                    end 
                end 
            },
            {
                title = 'Money',
                description = MoneyFormated,
            },
            {
                title = 'Gas',
                description = GasFormated..' / 100,000',
                progress = ((result.Gas/Config.FuelOrder.MaxFuel)*100),
                colorScheme = 'orange'
            },
            {
                title = 'Price',
                description = '$'..result.Price..' / per gallon',
            }
        }
    })
    lib.showContext('AdminGasStationMenu')
end)

-- Zone for fuel order NPC
function FuelOrderStart(fuel, cost, duration, dropoff, station)
    if inJob == true then 
        lib.notify({description = 'You already have a job', type = 'error'})
    else 
        local function FuelOrderBoxOnEnter()
            local model = Config.FuelOrder.NPCModel
            GetModel(model)

            FuelOrderNPC = CreatePed(1, GetHashKey(model), Config.FuelOrder.NPCLocation, Config.FuelOrder.NPCHeading, true, true)
            FreezeEntityPosition(FuelOrderNPC, true)
            SetEntityInvincible(FuelOrderNPC, true)
            SetBlockingOfNonTemporaryEvents(FuelOrderNPC, true)
            SetModelAsNoLongerNeeded(GetHashKey(model))

            if TrailerFuel == false then 
                local FuelTrailerDropOffOptions = {{
                    name = 'FuelTruckDropOff:option1',
                    icon = 'fa-solid fa-truck-droplet',
                    label = 'Return Truck',
                    onSelect = function()
                        DeleteEntity(FuelTruck)
                        DeleteEntity(FuelTrailer)
                        DeleteEntity(FuelOrderNPC)
                        FuelOrderBoxZone:remove()
                        inJob = false
                        GotFuelJob = false
                        lib.notify({description = 'You have completed the order', type = 'success'})
                    end 
                }}
                Target:addLocalEntity(FuelTrailer, FuelTrailerDropOffOptions)
            end 

            local FuelOrderNPCOptions = {{
                name = 'FuelOrderNPC:option1',
                icon = 'fa-solid fa-truck-droplet',
                label = 'Take out fuel truck',
                onSelect = function()
                    if inJob == false then 
                        inJob = true
                        TrailerFuel = true

                        model = Config.FuelOrder.FuelTruck
                        GetModel(model)
                        FuelTruck = CreateVehicle(GetHashKey(model), Config.FuelOrder.FuelTruckLocation, true, false)
                        model = Config.FuelOrder.FuelTrailer
                        GetModel(model)
                        FuelTrailer = CreateVehicle(GetHashKey(model), Config.FuelOrder.FuelTrailerLocation, true, false)
                        AttachVehicleToTrailer(FuelTruck, FuelTrailer, 1.1)

                        lib.notify({description = 'Take the truck to your gas station', type = 'inform'})

                        local function FuelOrderDropOffBoxOnEnter()
                            local FuelTrailerOptions = {{
                                name = 'FuelTrailer:option1',
                                icon = 'fa-solid fa-droplet',
                                label = 'Deliver Fuel',
                                onSelect = function()
                                        Target:disableTargeting(true)
                                        if lib.progressCircle({
                                            duration = duration,
                                            label = 'Unloading Fuel',
                                            position = 'bottom',
                                            useWhileDead = false,
                                            canCancel = false,
                                            disable = {move = true, combat = true},
                                            anim = {
                                                dict = 'timetable@gardener@filling_can',
                                                clip = 'gar_ig_5_filling_can',
                                            },
                                            prop = {},
                                        }) then 
                                            TrailerFuel = false
                                            Target:removeLocalEntity(FuelTrailer, FuelTrailerOptions)
                                            Target:disableTargeting(false)
                                            FuelOrderDropOffBoxZone:remove()
                                            TriggerServerEvent('dom_fuel:UpdateFuel', fuel, station)
                                            lib.notify({description = 'Return the truck', type = 'inform'})

                                        else 
                                            print('Failed Progress Bar')
                                        end 
                                end 
                            }}

                            Target:addLocalEntity(FuelTrailer, FuelTrailerOptions)
                        end 

                        FuelOrderDropOffBoxZone = Zone.box({
                            coords = dropoff,
                            size = Config.FuelOrder.DropOffSize,
                            debug = Config.Debug,
                            onEnter = FuelOrderDropOffBoxOnEnter
                        })
                    else 
                        lib.notify({description = 'You already took out a truck', type = 'error'})
                    end 
                end
            }}
            Target:addLocalEntity(FuelOrderNPC, FuelOrderNPCOptions)
        end 

        local function FuelOrderBoxOnExit()
            DeleteEntity(FuelOrderNPC)
        end 

        FuelOrderBoxZone = Zone.box({
            coords = Config.FuelOrder.NPCLocation,
            size = Config.FuelOrder.NPCZoneSize,
            rotation = Config.FuelOrder.NPCZoneRotation,
            debug = Config.Debug,
            onEnter = FuelOrderBoxOnEnter,
            onExit = FuelOrderBoxOnExit
        })
    end 
end 

function setFuel(state, vehicle, fuel, replicate)
	if DoesEntityExist(vehicle) then
		SetVehicleFuelLevel(vehicle, fuel)

		if not state.fuel then
			TriggerServerEvent('dom_fuel:createStatebag', NetworkGetNetworkIdFromEntity(vehicle), fuel)
		else
			state:set('fuel', fuel, replicate)
		end
	end
end

lib.onCache('seat', function(seat)
	if cache.vehicle then
		lastVehicle = cache.vehicle
	end

	if not NetworkGetEntityIsNetworked(lastVehicle) then return end

	if seat == -1 then
		SetTimeout(0, function()
			local vehicle = cache.vehicle
			local multiplier = Config.FuelUsage.classUsage[GetVehicleClass(vehicle)] or 1.0

			-- Vehicle doesn't use fuel
			if multiplier == 0.0 then return end

			local state = Entity(vehicle).state

			if not state.fuel then
				TriggerServerEvent('dom_fuel:createStatebag', NetworkGetNetworkIdFromEntity(vehicle), GetVehicleFuelLevel(vehicle))
				while not state.fuel do Wait(0) end
			end

			SetVehicleFuelLevel(vehicle, state.fuel)

			local fuelTick = 0

			while cache.seat == -1 do
				if GetIsVehicleEngineRunning(vehicle) then
					local usage = Config.FuelUsage.rpmUsage[math.floor(GetVehicleCurrentRpm(vehicle) * 10) / 10]
					local fuel = state.fuel
					local newFuel = fuel - usage * multiplier

					if newFuel < 0 or newFuel > 100 then
						newFuel = fuel
					end

					if fuel ~= newFuel then
						if fuelTick == 15 then
							fuelTick = 0
						end

						setFuel(state, vehicle, newFuel, fuelTick == 0)
						fuelTick += 1
					end
				end

				Wait(1000)
			end

			setFuel(state, vehicle, state.fuel, true)
		end)
	end
end)
