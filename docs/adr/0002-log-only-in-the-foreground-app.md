# Feedings are logged only in the foreground app

Every one-tap surface (Live Activity, Action button, Control Center, Siri logging intents) opens the
app, which writes the feeding, shows the logged confirmation with Undo, and restarts the Live
Activity. Background `LiveActivityIntent`s look simpler, but restarting an activity from the
background is reported to fail, and a second write path would need its own confirmation. The Home
Screen widget and the Apple Watch Smart Stack only open the app: they are reachable without Face
ID, so a stray tap would log a feeding.
