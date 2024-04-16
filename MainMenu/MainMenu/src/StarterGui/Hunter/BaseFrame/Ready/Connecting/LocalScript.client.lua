local num = 0

game["Run Service"].Heartbeat:Connect(function(delta)
	
	num += delta
	
	if (math.floor(num) == 0) then
		script.Parent.Text = "Connecting"
	end
	
	if (math.floor(num) == 1) then
		script.Parent.Text = "Connecting."
	end
	
	if (math.floor(num) == 2) then
		script.Parent.Text = "Connecting.."
	end
	
	if (math.floor(num) == 3) then
		script.Parent.Text = "Connecting..."
	end
	
	if (math.floor(num) >= 4) then
		num = 0
	end
	
end)