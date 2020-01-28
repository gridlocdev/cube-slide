using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelSelect : MonoBehaviour
{
    public GameObject levelText;

    public void SelectLevel()
    {
        Debug.Log(levelText.name);
        SceneManager.LoadScene(levelText.name);
    }
}
