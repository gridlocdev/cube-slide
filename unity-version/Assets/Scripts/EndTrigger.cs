using UnityEngine;

public class EndTrigger : MonoBehaviour
{
    public PlayerMovement movement;
    public GameManager gameManager;
    void OnTriggerEnter()
    {
        movement.enabled = false;
        gameManager.LevelComplete();
    }
}
