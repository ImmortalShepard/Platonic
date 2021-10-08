using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Rigidbody))]
public class Player2D3DSwitcher : MonoBehaviour, ISwitcher2D3D
{
    [SerializeField]
    private int _2DLayer;
    [SerializeField]
    private int _3DLayer;

    private Rigidbody _playeRigidbody;

    [SerializeField]
    private List<GameObject> _switchLayerObjects = new List<GameObject>();
    private List<Renderer> _renderers;
    [SerializeField]
    private Material _2dMaterial;
    [SerializeField]
    private Material _3dMaterial;

    private void Reset()
    {
        _2DLayer = LayerMask.NameToLayer("2D");
        _3DLayer = LayerMask.NameToLayer("3D");
    }

    private void Start()
    {
        _playeRigidbody = GetComponent<Rigidbody>();
        Switcher2D3D.Instance.AddSwitcher(this);
        _renderers = new List<Renderer>(_switchLayerObjects.Count);
        _switchLayerObjects.ForEach(switchObject =>
        {
            Renderer renderer = switchObject.GetComponent<Renderer>();
            if (renderer != null)
            {
                _renderers.Add(renderer);
            }
        });
    }

    public void SwitchProjection()
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
        _renderers.ForEach(renderer =>
        {
            renderer.material = _2dMaterial;
            renderer.shadowCastingMode = ShadowCastingMode.Off;
        });
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

    private void To3D()
    {
        gameObject.layer = _3DLayer;
        _switchLayerObjects.ForEach(layerObject => layerObject.layer = _3DLayer);
        _renderers.ForEach(renderer =>
        {
            renderer.material = _3dMaterial;
            renderer.shadowCastingMode = ShadowCastingMode.On;
        });
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

    public void Switch2D3D()
    {
        SwitchProjection();
    }
}
