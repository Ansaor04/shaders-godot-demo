using Godot;
using System;

public partial class Character : CharacterBody3D
{
	[Export]
	public int Speed { get; set; } = 14;

	private Vector3 _targetVelocity = Vector3.Zero;

	public override void _PhysicsProcess(double delta)
	{
		base._PhysicsProcess(delta);

		var direction = Vector3.Zero;
		
		if (Input.IsActionPressed("move_forward"))
		{
			direction.Z += 1.0f;
		}
		if (Input.IsActionPressed("move_back"))
		{
			direction.Z -= 1.0f;
		}

		if (direction != Vector3.Zero)
		{
			direction = direction.Normalized();
		}

		_targetVelocity.Z = direction.Z * Speed;
		
		Velocity = _targetVelocity;
		MoveAndSlide();
	}

}
