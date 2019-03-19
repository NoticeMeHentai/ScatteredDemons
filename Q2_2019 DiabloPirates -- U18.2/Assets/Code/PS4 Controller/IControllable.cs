using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// ANDRES


/// <summary>
/// Used to receive updates from Controller component
/// </summary>
public interface IControllable
{
    /// <summary>
    /// Receives the input.
    /// </summary>
    /// <param name="inputs">Inputs.</param>
    void ReceiveInput(Controller.Inputs inputs);
}
