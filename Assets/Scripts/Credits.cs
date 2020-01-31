using UnityEngine;
using UnityEngine.SceneManagement;

public class Credits : MonoBehaviour
{
    public void ExitGame()
    {
        Debug.Log("quit");
        Application.Quit();
    }

    public void BonusLevels()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
