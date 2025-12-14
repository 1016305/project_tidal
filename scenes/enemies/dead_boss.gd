@tool
extends Node3D

@onready var startup_sequence: AnimationPlayer = $"startup sequence"

func ready():
	startup_sequence.play("reset")
