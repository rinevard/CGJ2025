using Godot;
using System;

// 输出hello world测试

public partial class NewScript : Node
{
    public override void _Ready()
    {
        GD.Print("Hello World");
    }
}
