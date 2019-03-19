using System.Collections.Generic;
using UnityEngine;
// ANDRES MALDONADO

/// <summary>
/// A component that returns inputs 
/// </summary>
public class Controller : MonoBehaviour
{
    // NOTE: This component needs a correctly configured Unity Input
    // ++ Change Class name to PS4 Controller, and add gyroscope if
    //      possible, also vibrations, and color

    public enum ControllerType
    {
        ANY, P1, P2, P3, P4
    }
    // :: Settings
    public ControllerType controlledBy = ControllerType.P1;
    private string pp; // Player Prefix
    public bool sendInput = true;
    private IControllable[] controledScripts;

    private void Awake()
    {
        // - Player Prefix, also space/underscore after it
        pp = controlledBy.ToString() + " ";

    }

    void Update()
    {
        if (!sendInput || controledScripts == null)
        {
            return;
        }
        Inputs input = new Inputs
        {
            LAnalog = LAnalog,
            RAnalog = RAnalog,

            DPad = LAnalog,

            Cross = Cross,
            Circle = Circle,
            Square = Square,
            Triangle = Triangle,

            L1 = L1,
            L2 = L2,
            R1 = R1,
            R2 = R2,
            Options = Options,
        };
        foreach (var controlled in controledScripts)
        {
            controlled.ReceiveInput(input);
        }
    }

    private void OnEnable()
    {
        pp = controlledBy.ToString() + " ";
        // === 
        controledScripts = GetComponents<IControllable>();
        if (controledScripts == null)
        {
            //Debug.LogError("No IControllable found on: " + name);
            return;
        }
        RefreshInputString();
    }


    // - This is used so string.Concat() doesn't execute every call, generating garbage
    internal void RefreshInputString()
    {
        P_LX = pp + _LX;
        P_LY = pp + _LY;
        P_RX = pp + _RX;
        P_RY = pp + _RY;
        P_CROSS = pp + _CROSS;
        P_CIRCLE = pp + _CIRCLE;
        P_SQUARE = pp + _SQUARE;
        P_TRIANGLE = pp + _TRIANGLE;
        P_OPTIONS = pp + _OPTIONS;
        P_L1 = pp + _L1;
        P_L2 = pp + _L2;
        P_R1 = pp + _R1;
        P_R2 = pp + _R2;
        P_DPADX = pp + _DPADX;
        P_DPADY = pp + P_DPADY;
    }

    #region Inmutable Glossary
    const string _LX = "LX";
    const string _LY = "LY";
    const string _RX = "RX";
    const string _RY = "RY";
    const string _CROSS = "Cross";
    const string _CIRCLE = "Circle";
    const string _SQUARE = "Square";
    const string _TRIANGLE = "Triangle";
    const string _OPTIONS = "Options";
    const string _L1 = "L1";
    const string _L2 = "L2";
    const string _R1 = "R1";
    const string _R2 = "R2";
    const string _DPADX = "DpadX";
    const string _DPADY = "DpadY";
    #endregion
    #region Name Holders
    private string P_LX;
    private string P_LY;
    private string P_RX;
    private string P_RY;
    private string P_CROSS;
    private string P_CIRCLE;
    private string P_SQUARE;
    private string P_TRIANGLE;
    private string P_OPTIONS;
    private string P_L1;
    private string P_L2;
    private string P_R1;
    private string P_R2;
    private string P_DPADX;
    private string P_DPADY;
    #endregion

    public struct ButtonState
    {
        public bool hold;
        public bool press;
        public bool release;
    }

    public struct Inputs
    {
        //:: Analogs
        public Vector2 LAnalog;
        public Vector2 RAnalog;
        // :: Directional Pad
        public Vector2 DPad;

        public ButtonState Cross;
        public ButtonState Circle;
        public ButtonState Square;
        public ButtonState Triangle;
        // :: Triggers
        public ButtonState L1;
        public ButtonState L2;
        public ButtonState R1;
        public ButtonState R2;
        // :: System Button
        public ButtonState Options;
    }

    #region Inputs Properties
    //:: Analogs
    public Vector2 LAnalog
    {
        get { return new Vector2(Input.GetAxis(P_LX), Input.GetAxis(P_LY)); }
    }
    public Vector2 RAnalog
    {
        get { return new Vector2(Input.GetAxis(P_RX), Input.GetAxis(P_RY)); }
    }
    // :: Directional Pad
    public Vector2 DPad
    {
        get { return new Vector2(Input.GetAxis(P_DPADX), Input.GetAxis(P_DPADY)); }
    }
    // :: Main Actions
    public ButtonState Cross
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_CROSS),
                press = Input.GetButtonDown(P_CROSS),
                release = Input.GetButtonUp(P_CROSS),
            };
        }
    }
    public ButtonState Circle
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_CIRCLE),
                press = Input.GetButtonDown(P_CIRCLE),
                release = Input.GetButtonUp(P_CIRCLE),
            };
        }
    }
    public ButtonState Square
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_SQUARE),
                press = Input.GetButtonDown(P_SQUARE),
                release = Input.GetButtonUp(P_SQUARE),
            };
        }
    }
    public ButtonState Triangle
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_TRIANGLE),
                press = Input.GetButtonDown(P_TRIANGLE),
                release = Input.GetButtonUp(P_TRIANGLE),
            };
        }
    }
    // :: Triggers
    public ButtonState L1
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_L1),
                press = Input.GetButtonDown(P_L1),
                release = Input.GetButtonUp(P_L1),
            };
        }
    }
    public ButtonState L2
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_L2),
                press = Input.GetButtonDown(P_L2),
                release = Input.GetButtonUp(P_L2),
            };
        }
    }
    public ButtonState R1
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_R1),
                press = Input.GetButtonDown(P_R1),
                release = Input.GetButtonUp(P_R1),
            };
        }
    }
    public ButtonState R2
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_R2),
                press = Input.GetButtonDown(P_R2),
                release = Input.GetButtonUp(P_R2),
            };
        }
    }
    // :: System Button
    public ButtonState Options
    {
        get
        {
            return new ButtonState()
            {
                hold = Input.GetButton(P_OPTIONS),
                press = Input.GetButtonDown(P_OPTIONS),
                release = Input.GetButtonUp(P_OPTIONS),
            };
        }
    }

    #endregion
}

// ** JoystickIcon.png designed by Smashicons from www.flaticon.com