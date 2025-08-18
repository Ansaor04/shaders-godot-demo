using Godot;
using System;

public partial class PlayerStart : Node3D
{
	[Export]
	public PackedScene playerPrefab;

	private Node3D guideNode;

	public override void _Ready()
	{
		guideNode = GetNode<Node3D>("Guides");
		RemoveGuides();

		var existingPlayer = GetNodeOrNull<Node3D>("/root/Player");

		if (existingPlayer != null)
		{
			existingPlayer.GlobalTransform = GlobalTransform;
		}
		else
		{
			SpawnNewPlayer();
		}

	}

	public void SpawnNewPlayer()
	{
		if (playerPrefab == null)
		{
			GD.PrintErr("PlayerPrefab is not assigned!");
			return;
		}

		var playerInstance = playerPrefab.Instantiate();

		if (playerInstance is Node3D playerNode)
		{
			GetParent().CallDeferred("add_child", playerNode);
			playerNode.Name = "Player"; 
			playerNode.GlobalTransform = GlobalTransform;
		}
	}

	public void RemoveGuides()
	{
		guideNode?.QueueFree();
	}
}
