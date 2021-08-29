using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "DefaultRoll", menuName = "Custom/Roll Settings")]
public class RollSettings : ScriptableObject
{
    [SerializeField]
    private float _maxSpeed = 3.0f;
    public float maxSpeed => _maxSpeed;

    [SerializeField]
    private float _acceleration = 5.0f;
    public float acceleration => _acceleration;

    [SerializeField]
    private float _slowDown = 10.0f;
    public float slowDown => _slowDown;

    [SerializeField]
    private float _maxAngle = 180.0f;
    public float maxAngle => _maxAngle;
}
