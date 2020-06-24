# Configure the App Service deployment to use a GitHub repo
param([Parameter(Mandatory)][string] $GitHubRepo = "https://github.com/microsoft/TailwindTraders-Website", 
        [string] $branch = "main", 
        [Parameter(Mandatory)][string] $AppServiceName, 
        [Parameter(Mandatory)][string] $ResourceGroupName)
az webapp deployment source config --branch $branch --manual-integration --name $AppServiceName --repo-url $GitHubRepo --resource-group $ResourceGroupName
