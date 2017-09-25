# --- What are the built in cmdlets for working with XML
Get-Command *XML* -CommandType Cmdlet

# --- This is what happens with Import-CliXML and Export-CliXML
# --- Create an XML based representation of an object and store it in a file
Get-ChildItem .\Data | Export-Clixml .\Data\Example1.XML

Invoke-Item .\Data\Example1.XML

Import-Clixml .\Data\Example1.XML

# --- Type of object is maintained
Import-Clixml .\Data\Example1.XML | Get-Member

# --- Similarly ConvertTo-XML is used to create an XML based representation of an object.
# --- The results stays in the PowerShell session, not output to a file
$XML0 = Get-ChildItem .\Data | ConvertTo-Xml
$XML0

# --- Create an XML document object then load data from a file
$XML1 = New-Object System.Xml.XmlDocument
$XML1

$XMLFile = Resolve-Path .\Data\Example2.XML
$XML1.Load($XMLFile)
$XML1

# --- Or use the [xml] type accelerator
[xml]$XML2 = Get-Content  .\Data\Example2.XML
$XML2

# --- Observe that we also have an object of type XmlDocument
$XML2.GetType()

# --- Use XPath to navigate the XML tree
$XML1.SelectNodes('//food')

$XML1.SelectSingleNode('//food[2]')

$XML1.SelectSingleNode('//food[name="Strawberry Belgian Waffles"]')

$XML1.SelectNodes('//food[calories="900"]')

# --- Use Select-XML and XPath to navigate the XML tree. This returns any 'food' nodes
# --- Expand the nodes
$XML1 | Select-XML -XPath '//food' | Select-Object -ExpandProperty Node

# --- Use Object Dot Notation to navigate the XML tree
$XML2.breakfast_menu.food

$XML2.breakfast_menu.food[2]

$XML2.breakfast_menu.food | where name -eq "Strawberry Belgian Waffles"

$XML2.breakfast_menu.food | where calories -eq 900

# --- Or use a Here-String. It's possible your XML data may not come from a file, perhaps a WebService
[xml]$XML3 = @'
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

$XML3.breakfast_menu.food[0].price