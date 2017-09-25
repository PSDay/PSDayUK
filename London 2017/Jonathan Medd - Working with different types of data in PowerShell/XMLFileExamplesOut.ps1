# --- Save XML Doument to a file with Save method
[xml]$XML4 = @'
<breakfast_menu>
    <food>
        <name>Belgian Waffles</name>
        <price>$5.95</price>
        <description>Two of our famous Belgian Waffles with plenty of real maple syrup</description>
        <calories>650</calories>
    </food>
    <food>
        <name>Strawberry Belgian Waffles</name>
        <price>$7.95</price>
        <description>Light Belgian waffles covered with strawberries and whipped cream</description>
        <calories>900</calories>
    </food>
    <food>
        <name>Berry-Berry Belgian Waffles</name>
        <price>$8.95</price>
        <description>Light Belgian waffles covered with an assortment of fresh berries and whipped cream</description>
        <calories>900</calories>
    </food>
    <food>
        <name>French Toast</name>
        <price>$4.50</price>
        <description>Thick slices made from our homemade sourdough bread</description>
        <calories>600</calories>
    </food>
    <food>
        <name>Homestyle Breakfast</name>
        <price>$6.95</price>
        <description>Two eggs, bacon or sausage, toast, and our ever-popular hash browns</description>
        <calories>950</calories>
    </food>
</breakfast_menu>
'@

$XML4.Save('C:\Users\Jonathan\Documents\Development\Presentations\PSDayUK\2017\Data\Example3.xml')

# --- Make the Save method available via a function
function Out-XML {
<#
    .SYNOPSIS
    Output an XML Document object to a file

    .DESCRIPTION
    Output an XML Document object to a file

    .PARAMETER InputObject
    The XML Document object

    .PARAMETER FilePath
    Path to the output file

    .INPUTS
    System.Xml.XmlDocument
    System.String

    .OUTPUTS
    System.IO.FileInfo

    .EXAMPLE
    $XML | Out-File C:\Scripts\Test.xml
#>

[CmdletBinding()][OutputType('System.IO.FileInfo')]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [System.Xml.XmlDocument]$InputObject,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]
        [String]$FilePath
    )

    process {

        # --- Save the file out
        $InputObject.Save($FilePath)

        # --- Output the result
        Get-ChildItem -Path $FilePath 
    }
}


# --- Use the Out-XML function to output to an XML file
$XML4 | Out-XML -FilePath 'C:\Users\Jonathan\Documents\Development\Presentations\PSDayUK\2017\Data\Example4.xml'

# --- Update data in XML using XPath method
$XML4.SelectSingleNode('//food[name="Strawberry Belgian Waffles"]')

$XML4.SelectSingleNode('//food[name="Strawberry Belgian Waffles"]/price').InnerText = '$8.95'

$XML4.SelectSingleNode('//food[name="Strawberry Belgian Waffles"]')

# --- Update data in XML using Object dot notation
$XML4.breakfast_menu.food | where name -eq "French Toast"

($XML4.breakfast_menu.food | where name -eq "French Toast").calories = '650'

$XML4.breakfast_menu.food | where name -eq "French Toast"

# --- Add a node by creating a new element
$food = $XML4.CreateElement('food')
$food.SetAttribute('name','Cereal')
$food.SetAttribute('price','$2.95')
$food.SetAttribute('description','A choice of five different cereals plus milk')
$food.SetAttribute('calories','400')

$XML4.breakfast_menu.AppendChild($food)

$XML4.breakfast_menu.food

# --- Add a node by cloning an existing node. Insert it after a specific node rather than at the end
$newnode = $XML4.breakfast_menu.food[0].CloneNode($true)
$newnode.name = 'Pancakes'
$newnode.price = '$4.95'
$newnode.description = 'Four pancakes and a choice of syrup, lemon juice and chocolate'
$newnode.calories = '550'
$newnode

[void]$XML4.breakfast_menu.InsertAfter($newnode, ($XML4.breakfast_menu.food | where name -eq "French Toast"))

$XML4.breakfast_menu.food

# --- Create a node via Here-String and append to the existing XML. We first need to convert it by using ImportNode
# --- Otherwise PowerShell will throw an error "The node to be inserted is from a different document context."
[xml]$newnode2 = @'
    <food>
        <name>Chocolate Waffles</name>
        <price>$6.95</price>
        <description>Two of our famous Belgian Waffles with plenty of chocolate</description>
        <calories>800</calories>
    </food>
'@
$newnode2.food

[void]$XML4.DocumentElement.AppendChild($XML4.ImportNode($newnode2.food, $true))

$XML4.breakfast_menu.food

# --- Remove a node. Find the node to remove then call the RemoveChild method from the parent
$XML4.breakfast_menu.food | where name -eq "Cereal" | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}

$XML4.breakfast_menu.food