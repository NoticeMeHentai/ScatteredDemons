using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IkiEngine;

public class Labyrinth : MonoBehaviour
{

    [Range(10,50)]public int zCount = 15;
    [Range(10, 50)] public int xCount = 15;

    //public float SizeX = 10.0f;
    //public float SizeZ = 10.0f;
    [Range(0.5f, 3f)] public float CellSize = 1f;
    [Range(0.5f, 3f)] public float Height = 1f;

    public int debugIterations = 1000;


    public float UVTilingX = 5.0f;
    public float UVTilingZ = 5.0f;

    enum Directions {Up, Down, Left, Right};
    private Directions currentDirection;

    private Mesh indoor;

    public struct Cell
    {
        public float height;
        public int[] indexTL;
        public int[] indexTR;
        public int[] indexBL;
        public int[] indexBR;
        public bool wallT;
        public bool wallB;
        public bool wallL;
        public bool wallR;
        public bool inwardNormalT;
        public bool inwardNormalB;
        public bool inwardNormalL;
        public bool inwardNormalR;
    }

    

    public void RegenerateMesh()
    {
        Debug.Log("Building Mesh");

        if (indoor != null)
            DestroyImmediate(indoor);

        indoor = new Mesh();
        indoor.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;

        if (zCount % 2 == 0) zCount++;
        if (xCount % 2 == 0) xCount++;

        Cell[,] cells = new Cell[xCount, zCount];

        //Labyrinth Creation
        RegenerateLabyrinth(ref cells);
        

        for(int z=0; z<zCount;z++)
        {
            for(int x=0; x<xCount;x++)
            {
                float height = cells[x, z].height;

                // Left wall
                if (x>0)
                {
                    float leftHeight = cells[x - 1, z].height;
                    cells[x, z].wallL = (height != leftHeight);
                    cells[x, z].inwardNormalL = (height < leftHeight);
                }
                // Right wall
                if (x<(xCount-1))
                {
                    float rightHeight = cells[x + 1, z].height;
                    cells[x, z].wallR = (height != rightHeight);
                    cells[x, z].inwardNormalR = (height < rightHeight);
                }
                // Top wall
                if (z>0)
                {
                    float topHeight = cells[x, z - 1].height;
                    cells[x, z].wallT = (height != topHeight);
                    cells[x, z].inwardNormalT = (height < topHeight);
                }
                // Bottom wall
                if (z<(zCount-1))
                {
                    float bottomHeight = cells[x, z + 1].height;
                    cells[x, z].wallB = (height != bottomHeight);
                    cells[x, z].inwardNormalB = (height < bottomHeight);
                }
            }
        }

        List<Vector3> vertexPositions = new List<Vector3>();
        List<Vector2> vertexUVs = new List<Vector2>();
        List<Vector3> vertexNormals = new List<Vector3>();
        List<Color> vertexColor = new List<Color>();

        float SizeX = CellSize*xCount;
        float SizeZ = CellSize*zCount;

        float CellSizeX = CellSize;
        float CellSizeZ = CellSize;

        //Debug.LogFormat("xCount: = {0}, zCount: {1}, Size: {6}, SizeX: {2}, SizeZ: {3}, CellSizeX:{4}, CellSizeZ:{5}", xCount, zCount, SizeX, SizeZ, CellSizeX, CellSizeZ, Size);

        float CellUVSizeX = 1.0f / xCount;
        float CellUVSizeZ = 1.0f / zCount;
        
        for (int z = 0; z < zCount; z++)
        {
            for (int x = 0; x < xCount; x++)
            {
                float fxPos = ((float)x / xCount);
                float fzPos = ((float)z / zCount);

                // top left corner
                if ((!cells[x, z].wallT) && (z>0))
                {
                    cells[x, z].indexTL[1] = cells[x, z - 1].indexBL[1];
                }
                else if ((!cells[x, z].wallL) && (x>0))
                {
                    cells[x, z].indexTL[1] = cells[x - 1, z].indexTR[1];
                }
                else
                {
                    Vector3 position = new Vector3();
                    Vector3 normal = Vector3.up;
                    Vector2 uv = new Vector2();
                    Color color = Color.red;

                    position.x = (fxPos - 0.5f) * SizeX;
                    position.z = (fzPos - 0.5f) * SizeZ;
                    position.y = cells[x, z].height * Height;

                    uv.x = fxPos * UVTilingX;
                    uv.y = fzPos * UVTilingZ;

                    vertexPositions.Add(position);
                    vertexUVs.Add(uv);
                    vertexNormals.Add(normal);
                    vertexColor.Add(color);

                    cells[x, z].indexTL[1] = vertexPositions.Count - 1;
                }

                //top right corner
                if ((!cells[x, z].wallT) && (z > 0))
                {
                    cells[x, z].indexTR[1] = cells[x, z - 1].indexBR[1];
                }
                else
                {
                    Vector3 position = new Vector3();
                    Vector3 normal = Vector3.up;
                    Vector2 uv = new Vector2();
                    Color color = Color.red;

                    position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                    position.z = (fzPos - 0.5f) * SizeZ;
                    position.y = cells[x, z].height * Height;

                    uv.x = (fxPos + CellUVSizeX) * UVTilingX;
                    uv.y = fzPos  * UVTilingZ;

                    vertexPositions.Add(position);
                    vertexUVs.Add(uv);
                    vertexNormals.Add(normal);
                    vertexColor.Add(color);

                    cells[x, z].indexTR[1] = vertexPositions.Count - 1;
                }

                // bottom left corner
                if ((!cells[x, z].wallL) && (x > 0))
                {
                    cells[x, z].indexBL[1] = cells[x - 1, z].indexBR[1];
                }
                else
                {
                    Vector3 position = new Vector3();
                    Vector3 normal = Vector3.up;
                    Vector2 uv = new Vector2();
                    Color color = Color.red;

                    position.x = (fxPos - 0.5f) * SizeX;
                    position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                    position.y = cells[x, z].height * Height;

                    uv.x = fxPos * UVTilingX;
                    uv.y = (fzPos + CellUVSizeZ) * UVTilingZ;

                    vertexPositions.Add(position);
                    vertexUVs.Add(uv);
                    vertexNormals.Add(normal);
                    vertexColor.Add(color);

                    cells[x, z].indexBL[1] = vertexPositions.Count - 1;
                }

                // bottom right corner
                {
                    Vector3 position = new Vector3();
                    Vector3 normal = Vector3.up;
                    Vector2 uv = new Vector2();
                    Color color = Color.red;

                    position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                    position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                    position.y = cells[x, z].height * Height;

                    uv.x = (fxPos + CellUVSizeX) * UVTilingX;
                    uv.y = (fzPos + CellUVSizeZ) * UVTilingZ;

                    vertexPositions.Add(position);
                    vertexUVs.Add(uv);
                    vertexNormals.Add(normal);
                    vertexColor.Add(color);

                    cells[x, z].indexBR[1] = vertexPositions.Count - 1;
                }

                if (cells[x,z].wallT)
                {
                    if ((x > 0) && (cells[x-1, z].wallT) && 
                        (cells[x,z].height == cells[x-1,z].height))
                    {
                        cells[x, z].indexTL[2] = cells[x-1, z].indexTR[2];
                    }
                    else
                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x,z].inwardNormalT?
                            Vector3.forward : Vector3.back;
                        Vector2 uv = new Vector2();
                        Color color = Color.blue;

                        position.x = (fxPos - 0.5f) * SizeX;
                        position.z = (fzPos - 0.5f) * SizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = fxPos * UVTilingX;
                        uv.y = (cells[x,z].height+1f)*0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexTL[2] = vertexPositions.Count - 1;
                    }

                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalT ?
                            Vector3.forward : Vector3.back;
                        Vector2 uv = new Vector2();
                        Color color = Color.blue;

                        position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                        position.z = (fzPos - 0.5f) * SizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = (fxPos + CellUVSizeX) * UVTilingX;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexTR[2] = vertexPositions.Count - 1;
                    }
                }

                if (cells[x, z].wallB)
                {
                    if ((x>0) && (cells[x - 1, z].wallB) && 
                        (cells[x,z].height == cells[x-1,z].height))
                    {
                        cells[x, z].indexBL[2] = cells[x-1, z].indexBR[2];
                    }
                    else
                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalB ?
                            Vector3.back : Vector3.forward;
                        Vector2 uv = new Vector2();
                        Color color = Color.blue;

                        position.x = (fxPos - 0.5f) * SizeX;
                        position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = fxPos * UVTilingX;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexBL[2] = vertexPositions.Count - 1;
                    }

                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalB ?
                            Vector3.back : Vector3.forward;
                        Vector2 uv = new Vector2();
                        Color color = Color.blue;

                        position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                        position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = (fxPos + CellUVSizeX) * UVTilingX;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexBR[2] = vertexPositions.Count - 1;
                    }

                }

                if (cells[x,z].wallL)
                {
                    if ((z>0) && (cells[x, z-1].wallL) && 
                        (cells[x,z].height == cells[x, z-1].height))
                    {
                        cells[x, z].indexTL[0] = cells[x, z - 1].indexBL[0];
                    }
                    else
                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalL ?
                            Vector3.right : Vector3.left;
                        Vector2 uv = new Vector2();
                        Color color = Color.green;

                        position.x = (fxPos - 0.5f) * SizeX;
                        position.z = (fzPos - 0.5f) * SizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = fzPos * UVTilingZ;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexTL[0] = vertexPositions.Count - 1;
                    }

                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalL ?
                           Vector3.right : Vector3.left;
                        Vector2 uv = new Vector2();
                        Color color = Color.green;

                        position.x = (fxPos - 0.5f) * SizeX;
                        position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = (fzPos + CellUVSizeZ) * UVTilingZ;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexBL[0] = vertexPositions.Count - 1;
                    }
                }

                if (cells[x, z].wallR)
                {
                    if ((z > 0) && (cells[x, z - 1].wallR) && 
                        (cells[x,z].height == cells[x,z-1].height))
                    {
                        cells[x, z].indexTR[0] = cells[x, z - 1].indexBR[0];
                    }
                    else
                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalR ?
                            Vector3.left : Vector3.right;
                        Vector2 uv = new Vector2();
                        Color color = Color.green;

                        position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                        position.z = (fzPos - 0.5f) * SizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = fzPos * UVTilingZ;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexTR[0] = vertexPositions.Count - 1;
                    }

                    {
                        Vector3 position = new Vector3();
                        Vector3 normal = cells[x, z].inwardNormalR ?
                             Vector3.left: Vector3.right;
                        Vector2 uv = new Vector2();
                        Color color = Color.green;

                        position.x = (fxPos - 0.5f) * SizeX + CellSizeX;
                        position.z = (fzPos - 0.5f) * SizeZ + CellSizeZ;
                        position.y = cells[x, z].height * Height;

                        uv.x = (fzPos + CellUVSizeZ) * UVTilingZ;
                        uv.y = (cells[x, z].height + 1f) * 0.5f;

                        vertexPositions.Add(position);
                        vertexUVs.Add(uv);
                        vertexNormals.Add(normal);
                        vertexColor.Add(color);

                        cells[x, z].indexBR[0] = vertexPositions.Count - 1;
                    }
                }
            }
        }

        indoor.vertices = vertexPositions.ToArray();
        indoor.colors = vertexColor.ToArray();
        indoor.uv = vertexUVs.ToArray();
        indoor.normals = vertexNormals.ToArray();

        List<int> triangles = new List<int>();

        for (int z = 0; z < zCount; z++)
        {
            for (int x = 0; x < xCount; x++)
            {
                triangles.Add(cells[x, z].indexTL[1]);
                triangles.Add(cells[x, z].indexBL[1]);
                triangles.Add(cells[x, z].indexTR[1]);

                triangles.Add(cells[x, z].indexBL[1]);
                triangles.Add(cells[x, z].indexBR[1]);
                triangles.Add(cells[x, z].indexTR[1]);

                if (cells[x, z].wallB)
                {
                    triangles.Add(cells[x, z].indexBL[2]);
                    triangles.Add(cells[x, z + 1].indexTL[2]);
                    triangles.Add(cells[x, z].indexBR[2]);

                    triangles.Add(cells[x, z + 1].indexTL[2]);
                    triangles.Add(cells[x, z + 1].indexTR[2]);
                    triangles.Add(cells[x, z].indexBR[2]);
                }

                if (cells[x,z].wallR)
                {
                    triangles.Add(cells[x, z].indexBR[0]);
                    triangles.Add(cells[x + 1, z].indexBL[0]);
                    triangles.Add(cells[x, z].indexTR[0]);

                    triangles.Add(cells[x + 1, z].indexBL[0]);
                    triangles.Add(cells[x + 1, z].indexTL[0]);
                    triangles.Add(cells[x, z].indexTR[0]);
                }
            }
        }

        indoor.triangles = triangles.ToArray();

//        indoor.RecalculateNormals();
        indoor.RecalculateTangents();
        indoor.RecalculateBounds();

        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (meshFilter == null)
            meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = indoor;

        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        if (meshRenderer == null)
            meshRenderer = gameObject.AddComponent<MeshRenderer>();

        MeshCollider meshCollider = GetComponent<MeshCollider>();
        if (meshCollider == null)
            meshCollider = gameObject.AddComponent<MeshCollider>();
        meshCollider.sharedMesh = indoor;
    }

    public void RegenerateLabyrinth(ref Cell[,] cells)
    {
        int maxVisitedCells = ((xCount - 1) / 2) * ((zCount - 1) / 2);
        List<int2> lastVisitedCells = new List<int2>();
        bool foundRight = true;
        bool foundLeft = true;
        bool foundUp = true;
        bool foundDown = true;
        bool foundAWay = true;

        int2 currentPos = new int2(1, 1);
        int currentVisitedCells = 1;
        lastVisitedCells.Add(currentPos);
        cells[1, 1].height = 0;

        //First pass to set everything as a wall
        for(int z=0;z<zCount;z++)
        {
            for (int x = 0; x < xCount; x++)
            {
                cells[x, z].height = 1f;
                cells[x, z].indexBL = new int[3];
                cells[x, z].indexBR = new int[3];
                cells[x, z].indexTL = new int[3];
                cells[x, z].indexTR = new int[3];
                for (int i = 0; i < 3; i++)
                {
                    cells[x, z].indexBL[i] = -1;
                    cells[x, z].indexBR[i] = -1;
                    cells[x, z].indexTL[i] = -1;
                    cells[x, z].indexTR[i] = -1;
                }

            }

        }

        //We construct the path
        while(currentVisitedCells< maxVisitedCells)
        {
            currentDirection = (Directions)Random.Range(0, 4);
            Debug.Log((int)currentDirection);
            switch (currentDirection)
            {
                case Directions.Up:
                    if (currentPos.y + 2 < zCount && cells[currentPos.x, currentPos.y + 2].height != 0)
                    {
                        cells[currentPos.x, currentPos.y + 1].height = 0;
                        cells[currentPos.x, currentPos.y + 2].height = 0;
                        lastVisitedCells.Add(currentPos);
                        currentPos.y += 2;
                        foundUp = true;
                        foundAWay = true;
                        Debug.Log("FoundUp");
                    }
                    else
                    {
                        foundUp = false;
                        foundAWay = false;
                    }
                    break;
                case Directions.Down:
                    if (currentPos.y - 2 > 0 && cells[currentPos.x, currentPos.y - 2].height != 0)
                    {
                        cells[currentPos.x, currentPos.y - 1].height = 0;
                        cells[currentPos.x, currentPos.y - 2].height = 0;
                        lastVisitedCells.Add(currentPos);
                        currentPos.y -= 2;
                        foundDown = true;
                        foundAWay = true;
                        Debug.Log("FoundDown");
                    }
                    else
                    {
                        foundDown = false;
                        foundAWay = false;
                    }
                    break;
                case Directions.Left:
                    if (currentPos.x - 2 > 0 && cells[currentPos.x - 2, currentPos.y].height != 0)
                    {
                        cells[currentPos.x - 1, currentPos.y].height = 0;
                        cells[currentPos.x - 2, currentPos.y].height = 0;
                        lastVisitedCells.Add(currentPos);
                        currentPos.x -= 2;
                        foundLeft = true;
                        Debug.Log("FoundLeft");
                        foundAWay = true;
                    }
                    else
                    {
                        foundLeft = false;
                        foundAWay = false;
                    }
                    break;
                case Directions.Right:
                    if (currentPos.x + 2 < xCount && cells[currentPos.x + 2, currentPos.y].height != 0)
                    {
                        cells[currentPos.x + 1, currentPos.y].height = 0;
                        cells[currentPos.x + 2, currentPos.y].height = 0;
                        lastVisitedCells.Add(currentPos);
                        currentPos.x += 2;
                        foundRight = true;
                        Debug.Log("FoundRight");
                        foundAWay = true;
                    }
                    else
                    {
                        foundRight = false;
                        foundAWay = false;
                    }
                    break;
                default:
                    break;
            }
            if(!foundRight&&!foundLeft&&!foundUp&&!foundDown)
            {
                lastVisitedCells.Remove(currentPos);
                currentPos = lastVisitedCells[lastVisitedCells.Count - 1];
                foundDown = true; foundLeft = true; foundUp = true; foundDown = true;
                Debug.Log("None found... regressing");
            }
            else if (foundAWay)
            {
                foundAWay = false;
                currentVisitedCells++;
            }

            
        }
    }
}
