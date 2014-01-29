class "TaxiDriver"

function TaxiDriver:__init ( )
	-- SETTINGS
	self.timeToPay = 15 -- In seconds
	self.amountToPay = 100 -- How much money the driver gets every X seconds set in timeToPay

	-- DON'T TOUCH
	self.passengers = { }
	self.taxiIDs =
		{
			[ 9 ] = true,
			[ 22 ] = true,
			[ 70 ] = true
		}
	self.timer = Timer ( )

	Events:Subscribe ( "PlayerEnterVehicle", self, self.onVehicleEnter )
	Events:Subscribe ( "PlayerExitVehicle", self, self.onVehicleExit )
	Events:Subscribe ( "PostTick", self, self.timerTick )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
end

function TaxiDriver:onVehicleEnter ( args )
	if ( self.taxiIDs [ args.vehicle:GetModelId ( ) ] ) then
		local driver = args.vehicle:GetDriver ( )
		if ( not args.is_driver ) then
			if IsValid ( driver ) then
				self.passengers [ args.player:GetId ( ) ] = driver:GetId ( )
			end
		end
	end
end

function TaxiDriver:onVehicleExit ( args )
	if ( self.taxiIDs [ args.vehicle:GetModelId ( ) ] ) then
		if ( not args.is_driver ) then
			self.passengers [ args.player:GetId ( ) ] = nil
		end
	end
end

function TaxiDriver:timerTick ( )
	if ( self.timer:GetSeconds ( ) >= self.timeToPay ) then
		for passengerID, driverID in pairs ( self.passengers ) do
			local passenger = Player.GetById ( passengerID )
			local driver = Player.GetById ( driverID )
			if ( IsValid ( passenger ) and IsValid ( driver ) ) then
				if ( passenger:GetMoney ( ) >= self.amountToPay ) then
					passenger:updateMoney ( -self.amountToPay )
					driver:updateMoney ( self.amountToPay )
				else
					driver:SendChatMessage ( passenger:GetName ( ) .." doesn't have enough money to pay you!", Color ( 255, 0, 0 ) )
				end
			else
				self.passengers [ passengerID ] = nil
			end
		end
		self.timer:Restart ( )
	end
end

function TaxiDriver:onPlayerQuit ( args )
	self.passengers [ args.player:GetId ( ) ] = nil
end

function Player:updateMoney ( amount )
	self:SetMoney ( self:GetMoney ( ) + amount )
end

taxiDriver = TaxiDriver ( )