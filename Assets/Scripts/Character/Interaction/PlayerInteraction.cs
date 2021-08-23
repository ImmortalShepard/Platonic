using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{
    [SerializeField]
    private Vector3 _capsuleCenterOffset = new Vector3(0,1,0);
    [SerializeField]
    private Vector3 _capsuleLengthOffset = new Vector3(0,0.5f,0);
    [SerializeField]
    private float _capsuleRadius = 0.25f;
    [SerializeField]
    private float _interactDistance = 0.75f;

    private Interactable _interactable;

    private void Update()
    {
        Vector3 capsuleCenter = transform.position + _capsuleCenterOffset;
        Vector3 forward = transform.forward;
        RaycastHit raycastHit;
        LayerMask layerMask = 1 << gameObject.layer;
        bool hit = Physics.CapsuleCast(capsuleCenter + _capsuleLengthOffset, capsuleCenter - _capsuleLengthOffset, _capsuleRadius, forward, out raycastHit, _interactDistance, layerMask);
        if (!hit)
        {
            if (_interactable == null)
            {
                return;
            }
            _interactable.Deactivate();
            _interactable = null;
            return;
        }
        _interactable = raycastHit.transform.GetComponent<Interactable>();
        _interactable?.Activate();
    }
}
