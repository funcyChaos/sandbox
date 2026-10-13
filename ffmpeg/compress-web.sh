# First attempt, AI Slop
ffmpeg -i input.mov -c:v libx264 -preset slow -b:v 1500k -c:a aac -b:a 96k -movflags +faststart output.mp4

# Less agressive
ffmpeg -i input.mov -c:v libx264 -preset slow -b:v 4500k -c:a aac -b:a 128k -movflags +faststart output.mp4