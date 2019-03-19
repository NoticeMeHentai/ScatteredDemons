using System.Collections.Generic;
using UnityEngine;

// ANDRES
// Based on this code https://gist.github.com/quill18/5a7cfffae68892621267

/// <summary>
/// Use this to spawn GameObjects that will be used frequently.
/// <para></para>
/// Use <see cref="GetFromPool(GameObject, Vector3, Quaternion)"/> instead of
/// Instantiate().
/// <para></para>
/// Use <see cref="SendToPool"/> instead of
/// Destroy().
/// </summary>
static public class Pooling
{

    #region Work Notes
    /*
		// Done ; -- ToDo ; ++ Idea ; ** Note
    
        -- (no new tasks)
	*/
    #endregion

    #region Scene Pools
    private static class ScenePools
    {
        private static Dictionary<string, Transform> nameTransformPairs;
        private static GameObject rootGmObj;

        static void Initialize()
        {
            nameTransformPairs = new Dictionary<string, Transform>();
            rootGmObj = new GameObject("POOLS");
            Object.DontDestroyOnLoad(rootGmObj);
        }

        public static Transform GetTransform(Category poolName)
        {
            // - Initialize if needed
            if (nameTransformPairs == null) { Initialize(); }
            string name = poolName.ToString().ToUpper();
            if (nameTransformPairs.ContainsKey(name))
            {
                // Send reference
                return nameTransformPairs[name];
            }
            // - Create object then send reference
            GameObject newObject = new GameObject(name);
            newObject.transform.SetParent(rootGmObj.transform);
            nameTransformPairs.Add(name, newObject.transform);
            return newObject.transform;
        }
    }
    #endregion

    #region Pool Class
    public class Pool
    {
        public GameObject prefab;
        public bool preload;
        public int initialQuantity;

        int nextId = 1;
        Stack<GameObject> inactives;

        // Used to make new pools on runtime
        public Pool(GameObject prefab, int initQtty)
        {
            this.prefab = prefab;
            inactives = new Stack<GameObject>(initQtty);
        }
        // Returns one inactive object on top of inactives stack.
        public GameObject PopFromPool(Vector3 pos, Quaternion rot)
        {
            GameObject obj;
            // Initialize Stack if needed
            if (inactives == null)
            {
                inactives = new Stack<GameObject>(initialQuantity);
            }

            if (inactives.Count == 0)
            {  // New object needed from pool
                obj = Object.Instantiate(prefab, pos, rot);
                obj.name = prefab.name + "(" + (nextId++) + ")" + "::PoolMember";
                obj.AddComponent<PoolMember>().Initialize(this);
            }
            else
            { // if there's objects available in this pool
                obj = inactives.Pop();
                // If the obj doesnt exist anymore, call the next one in the stack
                if (obj == null)
                {
                    return PopFromPool(pos, rot); // ** Posible error on network ids
                }
            }

            obj.transform.position = pos;
            obj.transform.rotation = rot;
            obj.SetActive(true);

            return obj;
        }

        public void PushToPool(GameObject obj)
        {
            obj.SetActive(false);
            inactives.Push(obj);
        }
    }
    #endregion

    #region Pooling System Methods
    // All the pools
    static Dictionary<GameObject, Pool> pools;

    public enum Category
    {
        Projectiles, Enemies, VisualEffects,
    }

    // ================

    static void BeginDictionaryOrNewPool(GameObject prefab = null, int qty = 5)
    {
        if (pools == null)
        {
            pools = new Dictionary<GameObject, Pool>(); // ++ Can this be next to declaration??
        }
        if (prefab != null & pools.ContainsKey(prefab) == false)
        {
            //Debug.Log("[Pooling] New pool for: " + prefab.name + " has been created");
            pools[prefab] = new Pool(prefab, qty);
        }
    }

    /// <summary>
    /// Spawns the prefabs then deactivates them ready to be used.
    /// <para></para>
    /// <b>NOTE</b>: This will call Awake() and Start() on the spawned objects 
    /// but it DOES NOT call <see cref="IPoolable.OnPoolSpawn"/> nor 
    /// <see cref="IPoolable.OnPoolUnSpawn"/>. 
    /// </summary>
    /// <param name="prefab">Prefab.</param>
    /// <param name="qty">Quantity.</param>
	static public void Preload(GameObject prefab, int qty = 1)
    {
        BeginDictionaryOrNewPool(prefab, qty);
        // Make an array to grab the objects we're about to pre-spawn.
        GameObject[] obs = new GameObject[qty];
        for (int i = 0; i < qty; i++)
        {
            obs[i] = pools[prefab].PopFromPool(Vector3.zero, Quaternion.identity);
        }
        // Now despawn them all.
        for (int i = 0; i < qty; i++)
        {
            PoolMember member = obs[i].GetComponent<PoolMember>();
            member.myPool.PushToPool(obs[i]); // Push without calling the recycle event
        }
    }

    /// <summary>
    /// Gets one inactive object from a pool then activates it. If
    /// the object doesn't exist, a new pool will be created.
    /// This will call <see cref="IPoolable.OnPoolSpawn"/>
    /// </summary>
    /// <param name="prefab">Find this object on any pool</param>
    /// <param name="pos">Position world space.</param>
    /// <param name="rot">Rotation.</param>
    static public GameObject GetFromPool(GameObject prefab, Vector3 pos, Quaternion rot)
    {
        BeginDictionaryOrNewPool(prefab, 1);
        GameObject obj = pools[prefab].PopFromPool(pos, rot);
        obj.GetComponent<PoolMember>().OnDeployFromPool();
        return obj;
    }

    /// <summary>
    /// Gets one inactive object from a pool then activates it. If
    /// the object doesn't exist, a new pool will be created.
    /// This will call <see cref="IPoolable.OnPoolSpawn"/>
    /// Additionally it will assign to a category.
    /// <para></para>
    /// <b>NOTE</b>: Categories are marked as <see langword="DontDestroyOnLoad"/>
    /// </summary>
    /// <returns>The from pool.</returns>
    /// <param name="prefab">Prefab.</param>
    /// <param name="pos">Position.</param>
    /// <param name="rot">Rotation.</param>
    /// <param name="category">Category.</param>
    static public GameObject GetFromPool(GameObject prefab, Vector3 pos, Quaternion rot, Category category)
    {
        BeginDictionaryOrNewPool(prefab, 1);
        GameObject obj = pools[prefab].PopFromPool(pos, rot);
        obj.transform.SetParent(ScenePools.GetTransform(category));
        obj.GetComponent<PoolMember>().OnDeployFromPool();
        return obj;
    }

    /// <summary>
    /// Collects the object to its pool then deactivates it, ready for next use.
    /// If it doesn't have a pool, it will be destroyed.
    /// This will call <see cref="IPoolable.OnPoolUnSpawn"/>
    /// </summary>
    static public void SendToPool(GameObject obj)
    {
        // ++ Instead of getComponent compare to an array
        PoolMember member = obj.GetComponent<PoolMember>();
        if (member)
        {
            member.OnRecycleToPool();
            member.myPool.PushToPool(obj);
        }
        else
        {
            Debug.LogWarning("Object '" + obj.name + "' wasn't spawned from a pool. Destroying it instead.");
            Object.Destroy(obj);
        }

    }
    #endregion
    // ================
    #region PoolMember Helper Component
    /// <summary>
    /// Component added on runtime to objects used by the pooling system,
    /// used to identify parent Pool, and call events in IPoolable
    /// </summary>
	class PoolMember : MonoBehaviour
    {
        public Pooling.Pool myPool;
        public bool usesInterface;
        private IPoolable[] poolInterfaces;

        public void Initialize(Pool parentPool)
        {
            myPool = parentPool;
            poolInterfaces = GetComponentsInChildren<IPoolable>();//GetComponents<IPoolable>();
            if (poolInterfaces.Length > 0)
            {
                usesInterface = true;
                //for (int i = 0; i < poolInterfaces.Length; i++)
                //{
                //    //poolInterfaces[i].SetusesPooling(true);
                //}
            }

        }

        public void OnDeployFromPool()
        {
            if (usesInterface)
            {
                for (int i = 0; i < poolInterfaces.Length; i++)
                {
                    poolInterfaces[i].OnPoolSpawn();
                }
            }
        }

        public void OnRecycleToPool()
        {
            if (usesInterface)
            {
                for (int i = 0; i < poolInterfaces.Length; i++)
                {
                    poolInterfaces[i].OnPoolUnSpawn();
                }
            }
        }

    }
    #endregion
}
