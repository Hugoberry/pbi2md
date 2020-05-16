$a = Get-Content -raw 'C:\git\hub\pbi2md\seed\test-unzipped\00\Report\Layout-Section-Main.json' |
     convertfrom-json

# relationships
#$a.config.relationships

# filters
#$a.filters

# unwrapping
$a.visualContainers |  
    Select-Object  -expand config |  
    Select-Object Name, SingleVisualGroup, SingleVisual | 
    ForEach-Object {
        #$_.name
        if($_.SingleVisualGroup){
        #    $_.SingleVisualGroup.displayName
        } else {
            $_.SingleVisual.visualType
            if($_.SingleVisual.projections){
                $_.SingleVisual.projections.PSObject.Properties | ForEach-Object {
                    Write-Host "##",$_.Name
                    $_.Value | ForEach-Object { 
                        Write-Host "#### $($_.queryRef)"
                    }
                }
            }
        }
    }
