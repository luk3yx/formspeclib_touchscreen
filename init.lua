minetest.register_craft({
	type = "shapeless",
	output = "formspeclib_touchscreen:touchscreen",
	recipe = {
		"digistuff:touchscreen",
		"default:diamond"
	}
})

formspeclib_touchscreen = {}

formspeclib_touchscreen.update_ts_formspec = function (pos)
	local meta = minetest.get_meta(pos)
	if meta:get_int("init") == 0 then
		meta:set_string("formspec", "size[10,8]"..
		"field[3.75,3;3,1;channel;Channel;]"..
		"button_exit[4,3.75;2,1;save;Save]")
	else
		local data = minetest.deserialize(meta:get_string("data")) or {}
		local formspec = formspeclib.render(data, true)
		
		if formspec:len() < 1 then formspec = nil end
		
		meta:set_string("formspec", formspec or formspeclib.render({
			width = 10,
			height = 8,
			{
				type = "text",
				x = 1,
				y = 1,
				align = "left",
				text = "No data has been sent"
			}
		}))
	end
end

formspeclib_touchscreen.ts_on_receive_fields = function (pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	local playername = sender:get_player_name()
	local locked = meta:get_int("locked") == 1
	local can_bypass = minetest.check_player_privs(playername,{protection_bypass=true})
	local is_protected = minetest.is_protected(pos,playername)
	if (locked and is_protected) and not can_bypass then
		minetest.record_protection_violation(pos,playername)
		minetest.chat_send_player(playername,"You are not authorized to use this screen.")
		return
	end
	local init = meta:get_int("init") == 1
	if not init then
		if fields.save then
			meta:set_string("channel",fields.channel)
			meta:set_int("init",1)
			formspeclib_touchscreen.update_ts_formspec(pos)
		end
	else
		digiline:receptor_send(pos, digiline.rules.default, setchan, fields)
	end
end

formspeclib_touchscreen.ts_on_digiline_receive = function (pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if channel ~= setchan then return end
	if type(msg) ~= "table" then return end
	local data = minetest.deserialize(meta:get_string("data")) or {}
	data = formspeclib_touchscreen.process_command(meta,data,msg)
	meta:set_string("data", minetest.serialize(data))
	formspeclib_touchscreen.update_ts_formspec(pos)
end

formspeclib_touchscreen.process_command = function (meta, data, msg)
	local append = msg.append
	msg.append = nil
	
	if msg.command == "clear" then
		-- Message is a clear command, reset data
		data = {}
	elseif msg.command == "lock" then
		meta:set_int("locked",1)
	elseif msg.command == "unlock" then
		meta:set_int("locked",0)
	elseif msg.type then
		-- Message indicates a single element, append it
		table.insert(data, msg)
	else
		if append == nil then
			append = false --[[#msg < 1]]
		end
		
		if append then
			-- Message appears to be a list of elements, append them all
			for key,value in pairs(msg) do
				if type(key) == "number" then
					table.insert(data, value)
				else
					data[key] = value
				end
			end
		else
			-- Append is false, controller wants to specify completely new formspec
			data = msg
		end
	end
	
	return data
end

minetest.register_node("formspeclib_touchscreen:touchscreen", {
	description = "Formspeclib Touchscreen",
	groups = {cracky=3},
	on_construct = function(pos)
		formspeclib_touchscreen.update_ts_formspec(pos,true)
	end,
	drawtype = "nodebox",
	tiles = {
		"formspeclib_touchscreen_panel_back.png",
		"formspeclib_touchscreen_panel_back.png",
		"formspeclib_touchscreen_panel_back.png",
		"formspeclib_touchscreen_panel_back.png",
		"formspeclib_touchscreen_panel_back.png",
		"formspeclib_touchscreen_ts_front.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 }
		}
    	},
	on_receive_fields = formspeclib_touchscreen.ts_on_receive_fields,
	digiline = 
	{
		receptor = {},
		effector = {
			action = formspeclib_touchscreen.ts_on_digiline_receive
		},
	},
	light_source = 15,
})
