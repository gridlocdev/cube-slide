using UnityEngine;
using UnityEngine.Audio;

public class PlayerCollision : MonoBehaviour
{
    public PlayerMovement movement;

    public AudioSource hitSource;

    void Start()
    {
        hitSource = GetComponent<AudioSource>();
    }

    void OnCollisionEnter(Collision collisionInfo)
    {
        if (collisionInfo.collider.tag == "Obstacle")
        {
            hitSource.Play();
            movement.enabled = false;
            FindObjectOfType<GameManager>().EndGame();
        }
    }

}
