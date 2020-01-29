using UnityEngine;

public class ThumpMovement : MonoBehaviour
{
    int frameCount = 0;
    bool thumpBeat = true;

    public Rigidbody rb;
    public int jumpHeight;

    // Start is called before the first frame update
    void Start()
    {
        Jump();
        thumpBeat = !thumpBeat;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        frameCount++;
        if (frameCount % 270 == 0)
        {
            Jump();
            thumpBeat = !thumpBeat;
        }
                
    }

    void Jump()
    {
        if (thumpBeat)
        {
            if (this.tag == "Thump1")
            {

                Debug.Log("Called!");
                rb.AddForce(0, jumpHeight, 0, ForceMode.VelocityChange);
            }
        }
        else
        {
            if (this.tag == "Thump2")
            {
                rb.AddForce(0, jumpHeight, 0, ForceMode.VelocityChange);
            }
        }
    }
}
