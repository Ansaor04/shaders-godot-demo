using Godot;
using System;

public partial class Box3 : StaticBody3D
{

	private bool shouldSpin = false;

	public override void _Ready()
	{
		base._Ready();

		var button = GetNode<Button>("/root/Root/Button");
		button.OnPressedAction += () => { shouldSpin = !shouldSpin; };
	}


	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);

		if (shouldSpin)
		{
			var currentRotation = GlobalRotation;
			currentRotation.X += (float)delta;
			GlobalRotation = currentRotation;
		}
	}

}
