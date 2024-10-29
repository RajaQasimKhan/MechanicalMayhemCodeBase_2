local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local CashLib = MODULES["CashLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true

	Plr:WaitForChild("leaderstats")
	Plr.leaderstats:WaitForChild("Cash")
	Plr.leaderstats.Cash.Changed:Connect(function()
		script.Parent.Currency.Cash.Title.Text = Plr.leaderstats.Cash.Value
	end)
	script.Parent.Currency.Cash.Title.Text = Plr.leaderstats.Cash.Value

	Plr.Citrine.Changed:Connect(function()
		script.Parent.Currency.Citrine.Title.Text = CashLib.SUFFIX_NUM(Plr.Citrine.Value)
	end)
	script.Parent.Currency.Citrine.Title.Text = CashLib.SUFFIX_NUM(Plr.Citrine.Value)
	
	Plr.KnowledgePoints.Changed:Connect(function()
		script.Parent.Currency.KnowledgePoints.Title.Text = CashLib.SUFFIX_NUM(Plr.KnowledgePoints.Value)
	end)
	script.Parent.Currency.KnowledgePoints.Title.Text = CashLib.SUFFIX_NUM(Plr.KnowledgePoints.Value)
end

return module
