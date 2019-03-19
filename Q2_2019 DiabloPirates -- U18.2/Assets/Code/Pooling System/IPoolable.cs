using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// ANDRES
// ** IPoolable should be used by a MonoBehaviour and must
// be on the root of the prefab, not on any child object.

/// <summary>
/// Interface with events from the pooling system, use this
/// if you want to execute code at spawn/unspawn from pool.
/// </summary>
public interface IPoolable {

    /// <summary>
    /// Called when the object is taken out from the pool
    /// </summary>
    void OnPoolSpawn();

	/// <summary>
	/// Called before the object needs to go back to the pool
	/// </summary>
	void OnPoolUnSpawn();

}
