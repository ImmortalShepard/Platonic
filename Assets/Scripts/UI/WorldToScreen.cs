using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldToScreen : MonoBehaviour
{
    [SerializeField]
    private Transform _worldTransform;
    [SerializeField]
    private Vector3 _worldOffset = new Vector3(0, 1, 0);
    [SerializeField]
    private Camera _camera;

    private void Reset()
    {
        _camera = Camera.main;
    }

    private void OnEnable()
    {
        Vector3 position = _camera.WorldToScreenPoint(_worldTransform.position + _worldOffset);
        position.z = 0;
        transform.position = position;
    }

    void Update()
    {
        Vector3 position = _camera.WorldToScreenPoint(_worldTransform.position + _worldOffset);
        position.z = 0;
        transform.position = position;
    }
}
