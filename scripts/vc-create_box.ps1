# Load access token from environment variable
$access_token = $env:VAGRANT_CLOUD_TOKEN

# Set variables
$username = "maroskukan"
$box_name = "ubuntu2304"
$box_description = "Ubuntu 23.04 Lunar Lubster amd64 eufi image"

# Create the JSON request payload
$requestBody = @{
    box = @{
        username = $username
        name = $box_name
        is_private = $false
        short_description = $box_description
    }
} | ConvertTo-Json

# Make the API request to create the box
$response = Invoke-RestMethod -Method Post -Uri "https://app.vagrantup.com/api/v1/boxes" -Headers @{
    Authorization = "Bearer $access_token"
    'Content-Type' = 'application/json'
} -Body $requestBody

# Check if the request was successful
if ($response.tag -eq "maroskukan/ubuntu2304") {
    Write-Host "Box created successfully!"
}
else {
    Write-Host "Failed to create the box. " # Error message: $($response.error)"
}
