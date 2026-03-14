using UnityEngine;
using UnityEngine.SceneManagement;

public class Credits : MonoBehaviour
{
    public void ExitGame()
    {
        if (Application.platform == RuntimePlatform.WebGLPlayer)
        {
            SceneManager.LoadScene(0);
        }
        else
        {
            Application.Quit();
        }
    }

    public void BonusLevels()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
