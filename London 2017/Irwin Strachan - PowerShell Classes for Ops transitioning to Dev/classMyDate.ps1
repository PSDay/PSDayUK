Class MyDate {
    #Properties
    [String]$Day   
    [String]$NextWeek
    #Hidden Property will not be visible but it is accesible
    Hidden $InvalidDate

    #default Constructors
    MyDate() {
        $this.Day = (Get-Date).DateTime
        $this.NextWeek = (Get-Date).AddDays(7).DateTime
        $this.InvalidDate = $null
    }

    MyDate($dt) {
        try{
            if((Get-date $dt).GetDateTimeFormats().Contains($dt)){
                $this.Day = (Get-Date $dt).DateTime
                $this.NextWeek = (Get-Date $dt).AddDays(7).DateTime
                $this.InvalidDate = $null
            }
        }
        catch{
            $this.InvalidDate = $dt
            Write-Warning -Message "Invalid date: $($dt). DateTime format should be valid. Use (Get-Culture).DateTimeFormat for reference)."
        }
    }

    #Static Methods cannot use $This.
    Static [String]AddDaysFromToday([int]$Days) {
        return ( '{0}' -f ((Get-Date) + (New-TimeSpan -Days $Days)).DateTime)
    }

    Static [String]AddWeeksFromToday([int]$Weeks) {
        return ( '{0}' -f ((Get-Date) + (New-TimeSpan -Days ($Weeks * 7))).DateTime)
    }

    [String]AddWeeksFromDay([int]$wk) {
        $this.VerifyDay()
        return ('{0}' -f $([datetime]$this.Day + (New-TimeSpan -Days ($wk * 7))).DateTime)
    }

    [String]AddDaysFromDay([int]$dy) {
        $this.VerifyDay()
        return ('{0}' -f $([datetime]$this.Day + (New-TimeSpan -Days $dy)).DateTime)
    }

    #Void Method to verify if Date is valid
    VerifyDay(){
        if ([DateTime]::TryParse($this.Day, [ref](Get-Culture).LCID)) {
            $this.Day = (Get-Date $this.Day).DateTime
            $this.NextWeek = (Get-Date $this.Day).AddDays(7).DateTime
            $this.InvalidDate = $null
        }
        else {
            $this.InvalidDate = $this.Day
            $this.Day = $null
            $this.NextWeek = $null
            Write-Warning -Message "Invalid date: $($this.Day). Date format should be valid. Use (Get-Culture).DateTimeFormat to find a valid pattern"
        }
    }
} 

#region Main

#region reviewing the Class
#Overload Definitions
[MyDate]::new

#Get the basic information from the Class
[MyDate]::new() | Get-Member

#To get the hidden property use -Force
[MyDate]::new() | Get-Member -Force

#To get the Static methods
[MyDate]::new() | Get-Member -Static
#endregion

#region Example 1
#initiate without a day will give you current day
$day = [MyDate]::new()
$day

#Call Methods Add* 
$day.AddWeeksFromDay(2)
$day.AddDaysFromDay(23)

#Change Date & verify 
$day.Day = '08/07/1969'
$day
$day.VerifyDay()
$day

#Change Date & call addDaysFromDate Method
$day.Day = '22/09/2017'
$day.AddDaysFromDay(2)
$day

#Change Date to FullDateTimePAttern & call addWeeksFormDate Method
$day.Day = 'Friday, 29 September 2017 00:00:00'
$day.AddWeeksFromDay(2)
$day

#Change Date to MonthDayPattern
$day.Day = '29 September'
$day.AddDaysFromDay(2)
$day
#endregion

#region Example 2
#initiate with a random valid date format
$randomDay = [MyDate]::new('14/09/2015')
$randomDay

#The method name says what it will do
$randomDay.AddWeeksFromDay(3)
$randomDay.AddDaysFromDay(2)

#Use the static method to get the weeks from random day
[MyDate]::AddWeeksFromToday(2)
[MyDate]::AddDaysFromToday(2)
#endregion

#region Example 3
#initiate with an invalid date
$invalid = [MyDate]::new('09/14/2015')
$invalid
$invalid.InvalidDate

#Repair the damage
$invalid.Day = '22/09/2017'
#Only Day is filled in
$invalid
#Verify that the date is correct this time around
$invalid.VerifyDay()
$invalid
#Verify that InvalidDate is empty
$invalid.InvalidDate
#endregion

#endregion
