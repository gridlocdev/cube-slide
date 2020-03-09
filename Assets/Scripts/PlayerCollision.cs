using UnityEngine;
using UnityEngine.Audio;

public class PlayerCollision : MonoBehaviour
{
    public PlayerMovement movement;

    public bool hasCollided = false;

    public AudioSource hitSource;

    void Start()
    {
        hitSource = GetComponent<AudioSource>();
    }

    void OnCollisionEnter(Collision collisionInfo)
    {
        if (collisionInfo.collider.tag == "Obstacle" || 
            collisionInfo.collider.tag == "Thump1" || 
            collisionInfo.collider.tag == "Thump2" ||
            collisionInfo.collider.tag == "BallReflector")
        {
            hitSource.Play();
            movement.enabled = false;
            hasCollided = true;
            FindObjectOfType<GameManager>().EndGame();
        }
    }

}
