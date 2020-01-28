using System;
using UnityEngine;
using UnityEngine.UI;

public class Score : MonoBehaviour
{
    public Transform player;
    public Text scoreText;
    public Transform endTrigger;

    float playerPosition;
    int MaxDist;
    // Update is called once per frame
    void Update()
    {
        playerPosition = float.Parse(player.position.z.ToString("0"));
        if ((playerPosition / MaxDist * 100) > 100)
        {
            scoreText.text = "100%";
        }
        else
        {
            scoreText.text = (playerPosition / MaxDist * 100).ToString("0");
            scoreText.text += "%";
        }
        
    }

    void Start()
    {
        scoreText.text = "0%";
        MaxDist = Int32.Parse(endTrigger.position.z.ToString("0"));
    }
}
