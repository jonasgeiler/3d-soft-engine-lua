function love.conf(t)
	t.window.title = "Soft Engine"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = true
	
	--t.console = true
	
	t.modules.joystick = false
    t.modules.physics = false
end