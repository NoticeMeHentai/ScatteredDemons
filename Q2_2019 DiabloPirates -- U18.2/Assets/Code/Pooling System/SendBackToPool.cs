using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// ANDRES
/* CHANGELOG
 * v2 [jan2019]
 * + Reference fixed
 * + Force no loop, and callback
*/

[AddComponentMenu("Effects/Particle System Pooling")]
public class SendBackToPool : MonoBehaviour {
	[Header("If Particle System is contained under a GameObject use this")]
	public Transform parent;

    //:: Refefrences
    private ParticleSystem ps;

    public void Start() {
        ps = GetComponent<ParticleSystem>();
        ps.Stop();
        var mainModule = ps.main; 
        mainModule.stopAction = ParticleSystemStopAction.Callback;
        mainModule.loop = false;
        if(mainModule.playOnAwake)
            ps.Play();
    }

    // This is called from a Particle System callback
    public void OnParticleSystemStopped() {
		GameObject gmObj;
		gmObj = parent ? parent.gameObject : gameObject;
		Pooling.SendToPool(gmObj);
	}
}
