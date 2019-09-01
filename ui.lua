-- bruh
local function chatprint(...)
	LocalPlayer():ChatPrint(...)	
end

local default = {
	{ 
		repo = "PAC3-Server/chatsounds-valve-games",
		sounds = {
			"tf2",
			"hl2",
			"ep1",
			"ep2",
			"portal",
			"l4d",
			"l4d2",
			"css",
			"csgo"
		},
		enabled = true
	},
	{
		repo = "PAC3-Server/chatsounds",
		enabled = true
	},
	{
		repo = "Metastruct/garrysmod-chatsounds",
		sounds = "sound/chatsounds/autoadd",
		enabled = true
	}
}

local function menu()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Chatsounds Menu")
	frame:SetSize(700, 500)
	frame:Center()
	frame:MakePopup()
	
	if not notagain or not requirex then
		frame:Close()
		
		Derma_Query(
			"The newer version of chatsounds isn't running.\nDo you want to load it?",
			"CSMenu loading error",
			"Sure, why not",
			function()
				LocalPlayer():ChatPrint("Okay, pushing through local chat...")
				SayLocal("!newchatsounds")
			end,
			"Nah",
			function() end
		)
		
		return
	end
	
	local repos_view = vgui.Create("DListView", frame)
	repos_view:SetSize(400, 460)
	repos_view:SetPos(10, 30)
	repos_view:SetMultiSelect(true)
	
	repos_view:AddColumn("Repository")
	repos_view:AddColumn("Folders")
	repos_view:AddColumn("Enabled")
	
	local repos_add = vgui.Create("DButton", frame)
	repos_add:SetPos(420, 30)
	repos_add:SetSize(150, 20)
	repos_add:SetText("Subscribe to Repository")
	
	local repos_remove = vgui.Create("DButton", frame)
	repos_remove:SetPos(420, 55)
	repos_remove:SetSize(150, 20)
	repos_remove:SetText("Unsubscribe from Repository")
	
	if not file.Exists("chatsounds/subscribed.txt", "DATA") then
		-- chatprint("Default chatsounds repository list doesn't exist")
		
		frame:Close()
		Derma_Query(
			"The default chatsounds repository list doesn't exist. Do you want to create it?",
			"CSMenu loading error",
			"Sure, why not",
			function()
				file.Write("chatsounds/subscribed.txt", util.TableToJSON(default))
					
				timer.Simple(.1, menu)
			end,
			"Nah",
			function() end
		)
		
		return
		
	end
	
	local repos = file.Read("chatsounds/subscribed.txt", "DATA")
	if not repos then
		
		frame:Close()
		Derma_Query(
			"File read error.",
			"CSMenu loading error",
			"Yikes",
			function() end
		)
		return
			
	end
	
	repos = util.JSONToTable(repos)
	for k,v in pairs(repos) do
		repos_view:AddLine(v.repo, v.sounds and (isstring(v.sounds) and v.sounds or table.concat(v.sounds, ", ")) or "", tostring(v.enabled))
	end
	
	local selected_repo
	
	repos_view.OnRowSelected = function(self, index, panel)
		selected_repo = {
			repo = panel:GetColumnText(1),
			sounds = panel:GetColumnText(2):len() < 1 and nil or panel:GetColumnText(2),
			enabled = true
		}	
	end
	
	repos_add.DoClick = function(self)
		Derma_StringRequest(
			"CSMenu prompt",
			"Which repository do you want to subscribe to?\nFormat: (owner)/(repository), should not have spaces\n\nIf you want to subscribe to folders/a single folder,\nadd a semicolon at the end of your repository,\nthen add your folders, separated by commas.",
			"",
			function(text) end,
			function(text) end,
			"Subscribe",
			"Cancel"
		)	
	end
	
	repos_remove.DoClick = function(self)
		if selected_repo then
			
			Derma_Query(
				"Are you sure you want to unsubscribe from repository:\n" .. selected_repo.repo,
				"CSMenu prompt",
				"Sure, go ahead",
				function()
					for k,v in pairs(repos) do
						if selected_repo.repo == v.repo then
							repos[k] = nil
							file.Write("chatsounds/subscribed.txt", util.TableToJSON(repos))
								
							frame:Close()
							timer.Simple(.1, menu)
							
							break
						end
					end
				end,
				"Nah",
				function() end
			)
			
			
			
		else
			
			Derma_Query(
				"You need to select a repository to delete.",
				"CSMenu error",
				"Yikes",
				function() end
			)
			
		end
	end
end

concommand.Add("chatsounds_open_menu", menu)
