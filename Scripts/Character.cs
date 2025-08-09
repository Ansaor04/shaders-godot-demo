using Godot;
using System;

public partial class Character : CharacterBody3D
{

	[ExportGroup("Camera")]
	[Export] public float MouseSensitivity = 0.005f;
	[Export] public float MinPitch = -80.0f;
	[Export] public float MaxPitch = 80.0f;

	[ExportGroup("Movement")]
	[Export] public float WalkSpeed = 1.5f;
	[Export] public float RunSpeed = 6.0f;
	[Export] public float JumpVelocity = 4.5f;
	[Export] public float RotationSpeed = 10.0f;
	[Export] public float GroundAcceleration = 10.0f;
	[Export] public float GroundDeceleration = 15.0f;
	[Export] public float AirAcceleration = 2.0f;
	[Export] public float AirDeceleration = 1.0f;

	[Export] public float SprintAccelerationBoost = 1.5f;

	private float _cameraPitch = 0.0f;
	private float _cameraYaw = 0.0f;

	private Camera3D _camera;
	private SpringArm3D _springArm;
	private AnimationPlayer _animationPlayer;
	private Node3D _mesh;
	private bool _isRunning = false;
	private bool _isJumping = false;

	public override void _Ready()
	{
		base._Ready();
		Input.MouseMode = Input.MouseModeEnum.Captured;

		SetupNodes();
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector3 velocity = Velocity;

		HandleGravity(ref velocity, delta);

		HandleMovement(ref velocity, delta);

		Velocity = velocity;
		MoveAndSlide();
	}


	private void SetupNodes()
	{
		_camera = GetNode<Camera3D>("SpringArm3D/Camera3D");
		_springArm = GetNode<SpringArm3D>("SpringArm3D");
		_animationPlayer = GetNode<AnimationPlayer>("Mesh/AnimationPlayer");
		_mesh = GetNode<Node3D>("Mesh");
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion && Input.MouseMode == Input.MouseModeEnum.Captured)
		{
			HandleMouseInput(mouseMotion);
		}

		if (@event.IsActionPressed("ui_cancel"))
		{
			ToggleMouseCapture();
		}
	}

	private void ToggleMouseCapture()
	{
		Input.MouseMode = Input.MouseMode == Input.MouseModeEnum.Captured
			? Input.MouseModeEnum.Visible
			: Input.MouseModeEnum.Captured;
	}

	private void HandleMouseInput(InputEventMouseMotion mouseMotion)
	{
		_cameraYaw -= mouseMotion.Relative.X * MouseSensitivity;

		float pitchDelta = mouseMotion.Relative.Y * MouseSensitivity;
		_cameraPitch = Mathf.Clamp(_cameraPitch - pitchDelta, Mathf.DegToRad(MinPitch), Mathf.DegToRad(MaxPitch));

		_springArm.Rotation = new Vector3(_cameraPitch, _cameraYaw, 0);
	}

	private void HandleJump(ref Vector3 velocity)
	{
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
		{
			velocity.Y = JumpVelocity;
			_isJumping = true;
			RequestAnimation("Jump_Start");
		}
	}

	private void HandleMovement(ref Vector3 velocity, double delta)
	{
		HandleJump(ref velocity);

		Vector2 inputDir = Input.GetVector("move_right", "move_left", "move_forward", "move_back");
		_isRunning = Input.IsActionPressed("sprint");

		Vector3 movementDirection = GetCameraRelativeVector(inputDir);
		Vector3 currentHorizontalVelocity = new Vector3(velocity.X, 0, velocity.Z);

		float targetSpeed = GetTargetSpeed(inputDir);

		if (movementDirection.Length() > 0.1f)
		{
			Vector3 targetVelocity = movementDirection * targetSpeed;
			Vector3 acceleratedVelocity = AccelerateTowards(currentHorizontalVelocity, targetVelocity, delta);

			velocity.X = acceleratedVelocity.X;
			velocity.Z = acceleratedVelocity.Z;

			RotateCharacterToMovement(movementDirection, delta);
			if (!_isJumping)
			{
				RequestAnimation(_isRunning ? "Sprint" : "Walk");
			}
		}
		else
		{
			Vector3 deceleratedVelocity = DecelerateVelocity(currentHorizontalVelocity, delta);
			velocity.X = deceleratedVelocity.X;
			velocity.Z = deceleratedVelocity.Z;

			if (!_isJumping)
			{
				RequestAnimation("Idle");
			}
		}
	}

	private void HandleGravity(ref Vector3 velocity, double delta)
	{
		_isJumping = !IsOnFloor();
		if (_isJumping)
		{
			velocity += GetGravity() * (float)delta;
			RequestAnimation("Jump");
		}
	}

	private Vector3 AccelerateTowards(Vector3 currentVelocity, Vector3 targetVelocity, double delta)
	{
		float acceleration = IsOnFloor() ? GroundAcceleration : AirAcceleration;

		if (_isRunning && IsOnFloor())
		{
			acceleration *= SprintAccelerationBoost;
		}

		Vector3 velocityDifference = targetVelocity - currentVelocity;
		float accelerationStep = acceleration * (float)delta;

		if (velocityDifference.Length() <= accelerationStep)
		{
			return targetVelocity;
		}

		return currentVelocity + velocityDifference.Normalized() * accelerationStep;
	}

	private Vector3 DecelerateVelocity(Vector3 currentVelocity, double delta)
	{
		if (currentVelocity.Length() < 0.1f)
		{
			return Vector3.Zero;
		}

		float deceleration = IsOnFloor() ? GroundDeceleration : AirDeceleration;
		float decelerationStep = deceleration * (float)delta;

		if (currentVelocity.Length() <= decelerationStep)
		{
			return Vector3.Zero;
		}

		return currentVelocity - currentVelocity.Normalized() * decelerationStep;
	}

	private float GetTargetSpeed(Vector2 inputDir)
	{
		float baseSpeed = _isRunning ? RunSpeed : WalkSpeed;
		return baseSpeed;
	}

	private void RotateCharacterToMovement(Vector3 movementDirection, double delta)
	{
		if (movementDirection.Length() < 0.1f) return;

		float targetYaw = Mathf.Atan2(movementDirection.X, movementDirection.Z);

		Vector3 currentRotation = _mesh.GlobalRotation;
		currentRotation.Y = Mathf.LerpAngle(currentRotation.Y, targetYaw, RotationSpeed * (float)delta);
		_mesh.GlobalRotation = currentRotation;
	}

	private Vector3 GetCameraRelativeVector(Vector2 inputVector)
	{
		Vector3 cameraForward = _springArm.GlobalTransform.Basis.Z;
		Vector3 cameraRight = _springArm.GlobalTransform.Basis.X;

		cameraForward.Y = 0;
		cameraRight.Y = 0;

		cameraForward = cameraForward.Normalized();
		cameraRight = cameraRight.Normalized();

		Vector3 relativeVector = ((cameraForward * inputVector.Y) + (cameraRight * inputVector.X));

		return relativeVector;
	}

	private void RequestAnimation(string animationName)
	{
		if (_animationPlayer.CurrentAnimation != animationName)
		{
			_animationPlayer.Play(animationName);
		}
	}

}
