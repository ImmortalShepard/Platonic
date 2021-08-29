using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

[CreateAssetMenu(fileName = "InputReader", menuName = "Custom/Input Reader")]
public class InputReader : ScriptableObject, GameInput.IGameplayActions
{
    //Gameplay
    private event UnityAction<Vector2> _moveEvent = delegate { };
    public UnityAction<Vector2> MoveEvent { get => _moveEvent; set => _moveEvent = value; }
    private event UnityAction _jumpEvent = delegate { };
    public UnityAction JumpEvent { get => _jumpEvent; set => _jumpEvent = value; }
    private event UnityAction _jumpCancelEvent = delegate { };
    public UnityAction JumpCancelEvent { get => _jumpCancelEvent; set => _jumpCancelEvent = value; }
    private event UnityAction _attackEvent = delegate { };
    public UnityAction AttackEvent { get => _attackEvent; set => _attackEvent = value; }
    private event UnityAction _attackCancelEvent = delegate { };
    public UnityAction AttackCancelEvent { get => _attackCancelEvent; set => _attackCancelEvent = value; }
    private event UnityAction _interactEvent = delegate { };
    public UnityAction InteractEvent { get => _interactEvent; set => _interactEvent = value; }
    private event UnityAction _interactCancelEvent = delegate { };
    public UnityAction InteractCancelEvent { get => _interactCancelEvent; set => _interactCancelEvent = value; }

    private GameInput gameInput;

    private void OnEnable()
    {
        if (gameInput == null)
        {
            gameInput = new GameInput();
            gameInput.Gameplay.SetCallbacks(this);
            gameInput.Gameplay.Enable();
        }
    }

    private void OnDisable()
    {
        DisableAllInputs();
    }

    private void DisableAllInputs()
    {
        gameInput.Gameplay.Disable();
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        _moveEvent.Invoke(context.ReadValue<Vector2>());
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        switch (context.phase)
        {
            case InputActionPhase.Performed:
                _jumpEvent.Invoke();
                break;
            case InputActionPhase.Canceled:
                _jumpCancelEvent.Invoke();
                break;
        }
    }

    public void OnAttack(InputAction.CallbackContext context)
    {
        switch (context.phase)
        {
            case InputActionPhase.Performed:
                _attackEvent.Invoke();
                break;
            case InputActionPhase.Canceled:
                _attackCancelEvent.Invoke();
                break;
        }
    }

    public void OnInteract(InputAction.CallbackContext context)
    {
        switch (context.phase)
        {
            case InputActionPhase.Performed:
                _interactEvent.Invoke();
                break;
            case InputActionPhase.Canceled:
                _interactCancelEvent.Invoke();
                break;
        }
    }
}
