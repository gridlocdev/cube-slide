using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public Rigidbody rb;

    public float forwardForce = 100f;

    public float sidewaysForce = 100f;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    // Unity likes FixedUpdate better than Update() for physics.
    void FixedUpdate()
    {
        // add forward force
        rb.AddForce(0, 0, forwardForce * Time.deltaTime); 

        if (Input.GetKey("d"))
        {
            rb.AddForce(sidewaysForce * Time.deltaTime, 0, 0, ForceMode.VelocityChange);
        }
        else if (Input.GetKey("a"))
        {
            rb.AddForce(-sidewaysForce * Time.deltaTime, 0, 0, ForceMode.VelocityChange);
        }
        if (rb.position.y < -2f)
        {
            FindObjectOfType<GameManager>().EndGame();
        }
    }
}
