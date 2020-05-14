function convertto-markdownTable {
    [cmdletbinding()]
    Param(            
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="IndividualAlligned")]
        #[parameter(mandatory=$true, ValueFromPipeline=$true, ParameterSetName="AllAlligned")]
        [parameter(mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Default")]
        [object]$inputObject,
        
        #[parameter(ParameterSetName="IndividualAlligned")]
        #[parameter(ParameterSetName="AllAlligned")]
        [parameter(ValueFromPipeline=$true, ParameterSetName="Default")]
        [int]$width=20,
        
        #[parameter(ParameterSetName="IndividualAlligned")]
        #[parameter(ParameterSetName="AllAlligned")]
        [parameter(ValueFromPipeline=$true, ParameterSetName="Default")]
        [switch]$includeOpen,
        
        [parameter(Mandatory=$true, ParameterSetName="IndividualAlligned")]
        [parameter(ValueFromPipeline=$true, ParameterSetName="Default")]
        [hashtable]$columnAlignment,
        

        [parameter(Mandatory=$true, ParameterSetName="AllAlligned")]
        [parameter(ValueFromPipeline=$true, ParameterSetName="Default")]
        [string]$allColumnsAllignment
    )
    begin {
        $output = ""
        [System.Collections.ArrayList]$properties =[System.Collections.ArrayList]@()
        $firstRun=$true;
        $maxWidth = $width
        [System.Collections.ArrayList]$collection = [System.Collections.ArrayList]@()
        $hinted = $false;
    }
    process {

        $collection.add($inputObject)|out-null
        if($firstRun){
            $properties = $inputObject.psobject.properties | where {$_.MemberType -eq "NoteProperty"} | select -ExpandProperty Name
            foreach($property in $properties){
                try {
                    if($maxWidth -lt $inputObject.$property.tostring().length){                    
                        $maxWidth = $inputObject.$property.tostring().length
                    }
                } catch {}
                try{
                    if($includeOpen){                        
                        $output += "|$property$(" ".toString() * (($width - "$property".length)))"            
                    } else {
                        $output += "$property$(" ".toString() * (($width - "$property".length)))|"            
                    }
                } catch [system.ArgumentOutOfRangeException] {
                    if(!$hinted){
                        $hinted = $true                            
                    }
                }
            }
            if($includeOpen){
                $output += "|`n|"
            } else {
                $output += "`n"
            }

            foreach($property in $properties){
                if($columnAlignment.$property){
                    switch($columnAlignment.$property){
                        Right { 
                            $AllignmentSymbol = @{
                                L=" ";
                                R=":";
                            }
                        }
                        Left { 
                        $AllignmentSymbol = @{
                                L=":";
                                R=" ";
                            }
                        }
                        Center {
                            $AllignmentSymbol = @{
                                L=":";
                                R=":";
                            }
                        }
                        default { 
                            $AllignmentSymbol = @{
                                L=" ";
                                R=" ";
                            }
                        }
                    }
                } else {
                    $AllignmentSymbol = @{
                        L=" ";
                        R=" ";
                    }
                    
                    switch($allColumnsAllignment){
                        Left {
                        $AllignmentSymbol = @{
                                L=":";
                                R=" ";
                            }
                        }
                                                        
                        Right {
                            $AllignmentSymbol = @{
                                L=" ";
                                R=":";
                            }
                        }
                        Center {
                            $AllignmentSymbol = @{
                                L=":";
                                R=":";
                            }                                
                        }                    
                        Default {
                            $AllignmentSymbol = @{
                                L=" ";
                                R=" ";
                            }                                                            
                        }        
                    }
                }
                $output += "$($AllignmentSymbol.L)"+("-"*($width-2)) +"$($AllignmentSymbol.R)|"
            }
                $AllignmentSymbol = " ";

            if($includeOpen){
                $output += "`n"
                $output += "|"                
            } else {
                $output += "`n"      
            }          
            foreach($property in $properties){
                try {
                    if([string]::IsNullOrEmpty($inputObject.$property)){                        
                        $output += " "*$width +"|"
                    } else {                    
                        $output += "$($inputObject.$property.ToString() + (" "*($width - ($inputObject.$property.toString().length))))|"                
                    }
                } catch [system.ArgumentOutOfRangeException] {
                    if(!$hinted){
                        $hinted = $true
                    }
                }
            }
            $output += "`n"
            $firstRun=$false
        } else {
            foreach($property in $properties){           
                try {
                    if($maxWidth -lt $inputObject.$property.tostring().length){                    
                        $maxWidth = $inputObject.$property.tostring().length                            
                    }
                } catch {}
                if([string]::IsNullOrEmpty($inputObject.$property)){
                    $output += " "*$width +"|"
                } else {
                    if($includeOpen){
                        if($properties.IndexOf($property) -eq 0){
                            $output += "|"
                        }
                    }
                    try {
                        if($includeOpen){
                            $output += "$($inputObject.$property.toString() + (" "*($width - ($inputObject.$property.tostring().length))))"
                        } else {
                            $output += "$($inputObject.$property.toString() + (" "*($width - ($inputObject.$property.tostring().length))))|"
                        }
                    } catch [system.ArgumentOutOfRangeException] {
                        if(!$hinted){
                            $hinted = $true
                        }
                    }
                    if($includeOpen){
                        $output +="|"
                    }
                }
            }
            $output += "`n"
        }
    }
    end {
        if($maxWidth -gt $width){
            write-verbose "This dataset requires a minimum -width of $($maxWidth)"
            write-verbose "Reruning with -width $maxwidth"
            $collection | convertto-markdownTable -width $maxWidth -includeOpen:$includeOpen.IsPresent 
        } else {
            write-output $output
        }
    }
}
$proc = get-process 

$proc | select Name, Handles, Npm -First 3| convertto-markdownTable -includeOpen -allColumnsAllignment Left

$proc | select Name, Handles, Npm -First 3| convertto-markdownTable -allColumnsAllignment Center

$proc | select Name, Handles, Npm -First 3 | convertto-markdownTable -includeOpen -columnAlignment @{Handles="Right"} 

$proc | select Name, Handles, Npm -First 3 | convertto-markdownTable -columnAlignment @{NPM="Center"}   
