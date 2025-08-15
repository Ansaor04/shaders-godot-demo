using Godot;
using System;

public partial class ToonSceneLightManager : Node3D
{
	private bool lights = false;

	private DirectionalLight3D ambientLight;
	private SpotLight3D standLight1;
	private SpotLight3D standLight2;
	private SpotLight3D standLight3;

	public override void _Ready()
	{
		base._Ready();

		ambientLight = GetNode<DirectionalLight3D>("DirectionalLight3D");
		standLight1 = GetNode<SpotLight3D>("SpotLight3D");
		standLight2 = GetNode<SpotLight3D>("SpotLight3D2");
		standLight3 = GetNode<SpotLight3D>("SpotLight3D3");

		var button = GetNode<Button>("Button");
		button.OnPressedAction += ToggleLights;

		ToggleLights();
	}


	public void ToggleLights()
	{
		lights = !lights;

		ambientLight.Visible = lights;

		standLight1.Visible = lights;
		standLight2.Visible = lights;
		standLight3.Visible= lights;
	}
}
