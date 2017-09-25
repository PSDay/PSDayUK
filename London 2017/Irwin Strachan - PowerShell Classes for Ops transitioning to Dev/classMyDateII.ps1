Class MyDateII {
    #Properties
    [String]$Day   
    [String]$NextWeek
    #Hidden Property will not be visible but it is accesible
    Hidden $InvalidDate

    #default Constructors
    MyDateII() {
        $this.Day = (Get-Date).DateTime
        $this.NextWeek = (Get-Date).AddDays(7).DateTime
        $this.InvalidDate = $null
    }

    MyDateII($dt) {
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

    [String]RemoveDaysFromNextWeek([int]$dy){
        $this.VerifyNextWeek()
        return ('{0}' -f $([datetime]$this.NextWeek - (New-TimeSpan -Days $dy)).DateTime)
    }

    [String]RemoveWeeksFromNextWeek([int]$wk){
        $this.VerifyNextWeek()
        return ('{0}' -f $([datetime]$this.NextWeek - (New-TimeSpan -Days ($wk * 7))).DateTime)
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

    VerifyNextWeek(){
        if ([DateTime]::TryParse($this.NextWeek, [ref](Get-Culture).LCID)) {
            $this.NextWeek = (Get-Date $this.NextWeek).DateTime
            $this.Day = (Get-Date $this.NextWeek).AddDays(-7).DateTime
            $this.InvalidDate = $null
        }
        else {
            $this.InvalidDate = $this.NextWeek
            $this.Day = $null
            $this.NextWeek = $null
            Write-Warning -Message "Invalid date: $($this.NextWeek). Date format should be valid. Use (Get-Culture).DateTimeFormat to find a valid pattern"
        }
    }
} 


#region reviewing the Class
#Overload Definitions
[MyDateII]::new

#Get the basic information from the Class
[MyDateII]::new() | Get-Member

#To get the hidden property use -Force
[MyDateII]::new() | Get-Member -Force

#To get the Static methods
[MyDateII]::new() | Get-Member -Static
#endregion

#region Example 1
#initiate without a day will give you current day
$day = [MyDateII]::new()
$day

#Call Methods Add* 
$day.AddWeeksFromDay(2)
$day.AddDaysFromDay(23)
$day.RemoveDaysFromNextWeek(2)
$day.RemoveWeeksFromNextWeek(2)

#Change NextWeek Property
$day.NextWeek = '08/07/1969'
$day.VerifyNextWeek()

$day.NextWeek = '08/07/1968'
$day.RemoveDaysFromNextWeek(4)
#endregion

#endregion
