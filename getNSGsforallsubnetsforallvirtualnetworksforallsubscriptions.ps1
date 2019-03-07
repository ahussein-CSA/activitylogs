#######################################################################################################
# Script: Get a list of all NSGs for all Subnets within Virtual networks for all subscriptions- Azure
# Author: Ahmed Hussein - Microsoft 
# Date: Feb 2019
# Version: 1.0
# References: 
# GitHub: 
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# IN NO EVENT SHALL MICROSOFT AND/OR ITS RESPECTIVE SUPPLIERS BE
# LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
# ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
# OF THIS CODE OR INFORMATION.
#
#
########################################################################################################


# Login to Azure - if already logged in, use existing credentials.

Write-Host "Authenticating to Azure..." -ForegroundColor Cyan

try

{

    $AzureLogin = Get-AzureRmSubscription 

}

catch

{

    $null = Login-AzureRmAccount

    $AzureLogin = Get-AzureRmSubscription

}

# Authenticate to Azure if not already authenticated 


If($AzureLogin)

{
    $SubscriptionArray = Get-AzureRmSubscription

    write-host "You have " $SubscriptionArray.Count " subscriptions under your accounts" -ForegroundColor white

    $virtualNetworksinfo = @()
    $subnets = @()


    ForEach ($vsub in $SubscriptionArray)

    {

        Write-Host "Selecting Azure Subscription: $($vsub.SubscriptionID) ..." -ForegroundColor Cyan

        $NULL = Select-AzureRmSubscription -SubscriptionId $($vsub.SubscriptionID)

        $SubscriptionID = Get-AzureRmSubscription -SubscriptionId $vsub.SubscriptionID | Select-Object SubscriptionId


        

        $NULL = Select-AzureRmSubscription -SubscriptionId $($SubscriptionID.SubscriptionID)

        
        $virtualNetworksinfo = Get-AzureRmVirtualNetwork | Select-Object name , resourcegroupname , Subnets

        foreach($vnet in $virtualNetworksinfo) 
        {

            Write-Host "Querying VirtualNetwork : $($vnet.Name) ..." -ForegroundColor Green
            $subnets = $vnet | Select-Object -ExpandProperty Subnets

            foreach ($subnet in $subnets) 
            {

                if (!($subnet.NetworkSecurityGroup.id))

            {
                # Write-Host "NO NSG attached for the subnet $($subnet.Name)"

            }
            
            else 
            {
                 $subnet | Select-Object name, @{label="NSG_ID";expression={$_.NetworkSecurityGroup.id}} | fl
                 # get the interfaces as well

                  

            }
        
            }

            
            
            

        }


        
        
    }


        

}

