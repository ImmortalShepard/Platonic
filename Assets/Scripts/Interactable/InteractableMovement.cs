using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class InteractableMovement : MonoBehaviour
{
    public abstract bool CheckMovement(ref Vector3 forward, float distance, out RaycastHit hitPosition);
    public abstract void MoveTo(Vector3 position);
}
