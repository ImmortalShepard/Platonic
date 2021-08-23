using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Player2D3DSwitcher : MonoBehaviour
{
    [SerializeField]
    private int _2DLayer;
    [SerializeField]
    private int _3DLayer;

    private Rigidbody _playeRigidbody;

    [SerializeField]
    private List<GameObject> _switchLayerObjects = new List<GameObject>();

    private void Reset()
    {
        _2DLayer = LayerMask.NameToLayer("2D");
        _3DLayer = LayerMask.NameToLayer("3D");
    }

    private void Start()
    {
        _playeRigidbody = GetComponent<Rigidbody>();
    }

    public void SwapProjection()
    {
        if (gameObject.layer == _2DLayer)
        {
            To3D();
            return;
        }
        if (gameObject.layer == _3DLayer)
        {
            To2D();
        }
    }

    private void To2D()
    {
        gameObject.layer = _2DLayer;
        _switchLayerObjects.ForEach(layerObject => layerObject.layer = _2DLayer);
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            Vector3 playerPosition = transform.position;
            playerPosition.z = Util2D3D.Convert3Dto2D(playerPosition.z);
            transform.position = playerPosition;
            return;
        }
#endif
        Vector3 position = _playeRigidbody.position;
        position.z = Util2D3D.Convert3Dto2D(position.z);
        _playeRigidbody.position = position;
    }

    private void To3D()
    {
        gameObject.layer = _3DLayer;
        _switchLayerObjects.ForEach(layerObject => layerObject.layer = _3DLayer);
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            Vector3 playerPosition = transform.position;
            playerPosition.z = Util2D3D.Convert2Dto3D(playerPosition.z);
            transform.position = playerPosition;
            return;
        }
#endif
        Vector3 position = _playeRigidbody.position;
        position.z = Util2D3D.Convert2Dto3D(position.z);
        _playeRigidbody.position = position;
    }
}
