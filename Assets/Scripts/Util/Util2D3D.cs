using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Util2D3D : MonoBehaviour
{
    private const float _2Dto3D = 1.4142135623730950488016887242097f;
    private const float _3Dto2D = .70710678118654752440084436210485f;

    public static float Convert2Dto3D(float value)
    {
        return value * _2Dto3D;
    }

    public static float Convert3Dto2D(float value)
    {
        return value * _3Dto2D;
    }
}
