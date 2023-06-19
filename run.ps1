$dockerfilePath = ".devcontainer/Dockerfile"
$imageName = "demo"
$Port="8443"
$dockePort=$Port:8443
# Check if the Docker image already exists
$imageExists = docker images --format "{{.Repository}}:{{.Tag}}" | Where-Object { $_ -eq $imageName }

if ($imageExists) {
    Write-Host "Docker image '$imageName' found."
} else {
    Write-Host "Docker image '$imageName' not found. Building Docker image..."
    docker build -t $imageName -f $dockerfilePath .
}

$containerName = "demo"
#$containerVolume = "$(Get-Location -PSProvider FileSystem):$(Get-Location)"

# Check if the container is already running
$containerStatus = docker ps -a --filter "name=$containerName" --format "{{.Status}}"
if ($containerStatus -like "*Up*") {
    Write-Host "Container '$containerName' is already running."
} else {
    # Start the container if it's not running
    $containerExists = docker ps -a --filter "name=$containerName" --format "{{.Names}}"
    if ($containerExists -contains $containerName) {
        docker start $containerName
        Write-Host "Container '$containerName' started."
    } else {
        # Create and start the container with the mounted volume
        docker run --name $containerName -d -v "$($pwd):/config/workspace" -p "$($Port):8443" -e PUID=1000 -e GUID=1000 -e SUDO_PASSWORD=abc $imageName
        Write-Host "Container '$containerName' created and started with volume mount."
    }
    
    Start-Sleep 3
    Start-Process "http://localhost:$Port"
}
