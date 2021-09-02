using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CircleWipePassFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        const string _profilerTag = "Circle Wipe Pass";

        private Material _material;
        private RenderTargetIdentifier _colorBuffer;

        public CustomRenderPass(Shader shader, float circleSize)
        {
            _material = CoreUtils.CreateEngineMaterial(shader);
            CircleSize = circleSize;
        }

        public float CircleSize
        {
            set => _material.SetFloat("_CircleSize", value);
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
    private RenderPassEvent _renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    [SerializeField]
    private Shader _shader;
    [SerializeField]
    [Range(0, 1)]
    private float _circleSize = 0;

    public float CircleSize
    {
        get => _circleSize;
        set
        {
            _circleSize = value;
            _scriptablePass.CircleSize = _circleSize;
        }
    }

    /// <inheritdoc/>
    public override void Create()
    {
        _scriptablePass = new CustomRenderPass(_shader, _circleSize);
        _scriptablePass.renderPassEvent = _renderPassEvent;
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


