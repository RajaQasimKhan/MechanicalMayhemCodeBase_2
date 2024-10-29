local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local DataStore = DataStoreService:GetDataStore("MessageStore")
local Event = RepStorage:WaitForChild("Events"):WaitForChild("DabineMessenger")

local admin_key = "admin_key_1"
local plr_msg_key = "plr_chat_1/"

_G.PlrMsgs = {}
_G.AdminMsgs = {}
_G.CurrentMessages = {}
_G.AdminMsgsSave = {}

-- Initialization
--[[DataStore:UpdateAsync(admin_key, function(past_data)
	if past_data then
		return past_data
	else
		return {}
	end
end)]]

function LENGTH(tbl)
	local count = 0
	for i, v in pairs(tbl) do
		count += 1
	end
	return count
end

function updateAdminKey(player_id, subject)
	DataStore:UpdateAsync(admin_key, function(past_data)
		if past_data then
			past_data[player_id] = tick()
			return past_data
		else
			return {[player_id] = tick()}
		end
	end)
end

function clearChats(player_id)
	_G.PlrMsgs[player_id] = {}
end


function saveMessagesToStore()
	if _G.AdminMsgsSave then
		if #_G.AdminMsgsSave > 0 then
			for i, message in pairs(_G.AdminMsgsSave) do
				local chat = message["Chat"]
				local destination = message["Destination"]
				if Players:GetPlayerByUserId(destination) then
					local plr = Players:GetPlayerByUserId(destination)
					if plr then
						if _G.PlrMsgs then
							if _G.PlrMsgs[plr.UserId] then
								table.insert(_G.PlrMsgs[plr.UserId], chat)
							else
								_G.PlrMsgs[plr.UserId] = {}
								table.insert(_G.PlrMsgs[plr.UserId], chat)
							end
							table.remove(_G.AdminMsgsSave, i)
						end
					end
				end
			end
		end
	end
	if _G.PlrMsgs then
		if LENGTH(_G.PlrMsgs) > 0 then
			for plr_id:number, plr_chats in pairs(_G.PlrMsgs) do
				if #plr_chats > 0 then
					local success = false
					DataStore:UpdateAsync(plr_msg_key..plr_id, function(past_data)
						if past_data then
							for i, chat in pairs(plr_chats) do
								table.insert(past_data, chat)
							end
							success = true
							clearChats(plr_id)
							return past_data
						else
							success = true
							clearChats(plr_id)
							return plr_chats
						end
					end)
					if success then
						updateAdminKey(plr_id)
					end
				end
			end
		end
	end
end

function getMessagesForPlayers()
	for i, player:Player in pairs(Players:GetPlayers()) do
		if player then
			if player.Name ~= "dab676767" then
				local chats = DataStore:GetAsync(plr_msg_key..player.UserId)
				--warn(chats)
				if chats then
					Event:FireClient(player, "refresh", chats)
				end
			else
				if _G.AdminMsgs[player.Name] then
					local chats = DataStore:GetAsync(plr_msg_key.._G.AdminMsgs[player.Name])
					if chats then
						Event:FireClient(player, "refresh", {_G.AdminMsgs[player.Name], chats})
					end
				end
			end
		end
	end
end

function getMessagesForOnePlayer(player:Player)
	if player then
		if true--[[player.Name ~= "dab676767"]] then
			local chats = DataStore:GetAsync(plr_msg_key..player.UserId)
			--warn(chats)
			if chats then
				_G.CurrentMessages[player] = chats
			end
		end
	end
end

game:BindToClose(saveMessagesToStore)

Players.PlayerAdded:Connect(function(player)
	if player.Name == "dab676767" then
		script.MessagesAdmin:Clone().Parent = player:WaitForChild("PlayerGui")
	else
		script.MessagesUser:Clone().Parent = player:WaitForChild("PlayerGui")
	end
	_G.PlrMsgs[player.UserId] = {}
	_G.CurrentMessages[player] = {}
	getMessagesForOnePlayer(player)
end)


Event.OnServerEvent:Connect(function(player, instruction, data, misc)
	--warn(player, instruction, data, misc)
	if instruction == "send_msg" then
		if data["SenderId"] == player.UserId then
			if data["Subject"]:len() + data["Txt"]:len() <= 2000 then
				if player.Name == "dab676767" then
					if _G.AdminMsgsSave then
						table.insert(_G.AdminMsgsSave, {["Chat"] = data, ["Destination"] = misc})
						Event:FireClient(player, "MessageSent")
					end
				else
					if _G.PlrMsgs then
						--print(_G.PlrMsgs)
						if _G.PlrMsgs[player.UserId] then
							table.insert(_G.PlrMsgs[player.UserId], data)
							table.insert(_G.CurrentMessages[player], data)
							wait()
							Event:FireClient(player, "MessageSent")
						end
					end
				end
			end
		end
	elseif instruction == "get_msgs" then
		if _G.CurrentMessages[player] then
			Event:FireClient(player, "refresh", _G.CurrentMessages[player])
		end
	elseif instruction == "get_admin_stuff" then
		if player.Name == "dab676767" then
			local data = DataStore:GetAsync(admin_key)
			--warn(data)
			if data then
				Event:FireClient(player, "reload_admin_stuff", data)
			end
		end
	elseif instruction == "UpdateSelectedUser" then
		if player.Name == "dab676767" then
			--print(data)
			_G.AdminMsgs[player.Name] = data
		end
	
	end
end)

while wait(5) do
	--warn(_G)
	saveMessagesToStore()
	getMessagesForPlayers()
end