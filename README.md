# Cube Slide

A 3D puzzle game built with Godot 4.6.

## Web Export

Export the game for web using the Godot CLI:

```sh
godot --headless --export-release "Web" build/web/index.html
```

## Running Locally

Serve the exported build with the required CORS headers:

```sh
python3 serve.py --root build/web
```

This opens `http://127.0.0.1:8060` in your browser. Use `--no-browser` to disable auto-open, or `--port <N>` to change the port.
