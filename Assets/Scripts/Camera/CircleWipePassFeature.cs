using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CircleWipePassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PassSettings
    {
        public RenderPassEvent _renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Shader _shader;
        [Range(0, 1)]
        public float _circleSize = 0;
    }

    class CustomRenderPass : ScriptableRenderPass
    {
        const string _profilerTag = "Circle Wipe Pass";

        private PassSettings _passSettings;

        public PassSettings CircleWipeSettings
        {
            get => _passSettings;
            set
            {
                if (_passSettings._circleSize != value._circleSize)
                {
                    _material.SetFloat("_CircleSize", value._circleSize);
                }
                _passSettings = value;
            }
        }

        private Material _material;
        private RenderTargetIdentifier _colorBuffer;

        public CustomRenderPass(PassSettings passSettings)
        {
            _passSettings = passSettings;

            renderPassEvent = _passSettings._renderPassEvent;
            _material = CoreUtils.CreateEngineMaterial(_passSettings._shader);
            _material.SetFloat("_CircleSize", _passSettings._circleSize);
        }

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            _colorBuffer = renderingData.cameraData.renderer.cameraColorTarget;
            ConfigureClear(ClearFlag.Depth, Color.black);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, new ProfilingSampler(_profilerTag)))
            {
                Blit(cmd, _colorBuffer, _colorBuffer, _material, 0);
            }

            // Execute the command buffer and release it.
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    private CustomRenderPass _scriptablePass;
    [SerializeField]
    private PassSettings _passSettings;

    public PassSettings CircleWipeSettings
    {
        get => _passSettings;
        set
        {
            _passSettings = value;
            _scriptablePass.CircleWipeSettings = _passSettings;
        }
    }

    /// <inheritdoc/>
    public override void Create()
    {
        _scriptablePass = new CustomRenderPass(_passSettings);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.camera.cameraType != CameraType.Game)
        {
            return;
        }
        renderer.EnqueuePass(_scriptablePass);
    }
}


