using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class FogAlphaOverLifetime : MonoBehaviour
{
    ParticleSystem ps;
    ParticleSystem.Particle[] particleArray;
    int particleCount;
    [Range(0f,1f)]public float firstValueRamp = 0.4f;
    [Range(0f, 1f)]public float secondValueRamp = 0.6f;
    Material[] particleMaterials;
    

    private void Update()
    {
        ps = GetComponent<ParticleSystem>();
        particleCount = ps.GetParticles(particleArray);
        particleMaterials = ps.GetComponent<ParticleSystemRenderer>().sharedMaterials;
       for(int i=0;i<particleCount;i++)
       {
            if(particleArray[i].remainingLifetime>0)
            {
                float ratio =1- particleArray[i].remainingLifetime / particleArray[i].startLifetime;
                Debug.LogFormat("Current ratio from {0} particle: {1}", i, ratio);
                if (ratio < firstValueRamp) ratio /= firstValueRamp;
                else if (ratio > firstValueRamp && ratio < secondValueRamp) ratio = 1;
                else ratio=(1 - ratio) / (1 - secondValueRamp);
                particleMaterials[i].SetFloat("_CurrentAlpha", ratio);
            
            }
       }
    }
}
