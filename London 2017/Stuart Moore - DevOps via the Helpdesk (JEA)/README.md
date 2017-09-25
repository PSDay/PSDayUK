# psday.uk-2017
Demo code and slide deck from PsDay.uk 22nd September 2017

Presentation Title: DevOps via the HelpDesk

An introduction to using Just Enough Administration to allow access to elevated commands for normal users without giving them explicit rights

There is an issue with the implicit remoting demo in JeaDemo3.ps1 if you're running PS 5.1 - https://github.com/PowerShell/PowerShell/issues/4195

Assumes you have a VM running  under Hyper-V as they make use of Direct connect

Register-DemoModule is an internal function setup in JeaDemo.ps2. It's not the greatest, but it worked

Any comments or problems let me know.