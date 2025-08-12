using Godot;
using System;

public partial class TpDoor : Node3D
{

	[Export]
	public PackedScene targetScene;

	private Area3D teleportArea;

	public override void _Ready()
	{
		teleportArea = GetNode<Area3D>("Screen/Area3D");

		teleportArea.BodyEntered += OnPlayerEnter;
	}

	public void TeleportToScene()
	{
		if (targetScene == null)
		{
			return;
		}

		Node currentScene = GetTree().CurrentScene;
		currentScene?.QueueFree();

		Node newSceneInstance = targetScene.Instantiate();
		SceneTree sceneTree = GetTree();
		sceneTree.Root.AddChild(newSceneInstance);
		sceneTree.CurrentScene = newSceneInstance;
	}

	public void OnPlayerEnter(Node body)
	{
		if (body is Character)
		{
			TeleportToScene();
		}
	}
}
