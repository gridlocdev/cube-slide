using UnityEngine;
using UnityEngine.SceneManagement;

public class BallObstacleMovement : MonoBehaviour
{
    public Rigidbody rb;
    public float sidewaysForce;


    void OnEnable()
    {
        Debug.Log("OnEnable called");
        rb.AddForce(sidewaysForce * Time.deltaTime * -3f, -10, 0, ForceMode.VelocityChange);
    }
    

    void OnCollisionEnter(Collision collisionInfo)
    {
        if (collisionInfo.collider.tag == "BallReflector")
        {
            Debug.Log("Hit Obj!");
            if (collisionInfo.transform.localPosition.x > rb.transform.localPosition.x) {
                rb.AddForce(sidewaysForce * Time.deltaTime * -3, -10, 0, ForceMode.VelocityChange);
            }
            else {
                rb.AddForce(sidewaysForce * Time.deltaTime * 3, -10, 0, ForceMode.VelocityChange);
            }
                
        }
    }
}
