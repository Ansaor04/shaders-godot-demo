using Godot;
using System;

public partial class Button : Node3D
{
	[Export]
	public string signalName;

	[Export]
	public float buttonCoolDown = 2.0f;

	private AnimationPlayer animationPlayer;
	private Area3D triggerArea;

	private double timer = 0;
	private bool isActive = false;
	private Action<double> ButtonCallbackTimer;

	public override void _Ready()
	{
		animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
		triggerArea = GetNode<Area3D>("TriggerArea");

		triggerArea.BodyEntered += OnPlayerEnter;
	}

	public override void _PhysicsProcess(double delta)
	{
		if (ButtonCallbackTimer != null)
		{
			ButtonCallbackTimer(delta);
		}
	}

	public void OnPlayerEnter(Node body)
	{
		if (body is Character)
		{
			OnPress();
		}
	}

	private void OnPress()
	{
		if (isActive) return;

		timer = buttonCoolDown;
		animationPlayer.Play("Press");
		ButtonCallbackTimer = OnButtonCallback;
		isActive = true;
	}

	private void OnButtonCallback(double delta)
	{
		timer -= delta;
		if (timer <= 0)
		{
			ButtonCallbackTimer = null;
			animationPlayer.PlayBackwards("Press");
			isActive = false;
		}
	}

}
