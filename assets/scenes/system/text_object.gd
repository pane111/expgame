extends StaticBody2D

@export_multiline var text_to_display: String

func onInteract():
	GameManager.display_text(text_to_display)
