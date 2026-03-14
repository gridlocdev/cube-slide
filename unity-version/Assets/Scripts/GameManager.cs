using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    bool gameHasEnded = false;
    public float restartDelay = 1f;

    public GameObject completeLevelUI;

        public PlayerMovement movement;
    public PlayerCollision playerCollision;

    public void Start()
    {
        movement.enabled = true;
    }

    public void LevelComplete()
    {
        // If cube has not collided; 
        if (playerCollision.hasCollided != true)
        {
        completeLevelUI.SetActive(true);
        }
    }

    public void EndGame()
    {
        if (!gameHasEnded)
        {
        gameHasEnded = true;
            // Restarting the Game
            Invoke("Restart", restartDelay);
        }
    }

    void Restart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
