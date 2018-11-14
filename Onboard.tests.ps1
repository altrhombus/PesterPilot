$userName = "USERNAME"
$domain = "@domain.com"
Describe -Name "Active Directory - User Validation" -Tags @("Simple") -Fixture {
    BeforeAll {
        $userObject = Get-ADUser $userName -Properties *
    }
    Context -Name "UPN Sanity Checks" -Fixture {
        It -Name "UPN matches firstname.lastname" {
            ([string]$userObject.GivenName, ".", [string]$userObject.Surname, $domain -join "") | Should -Be ([string]$userObject.UserPrincipalName) -Because "UPNs should match the user's firstname, a period, then their last name"
        }
        It -Name "UPN is lowercase" {
            [string]$userObject.UserPrincipalName | Should -BeExactly ([string]$userObject.UserPrincipalName).ToLower() -Because "the UPN should be lowercase."
        }
        It -Name "UPN matches EmailAddress" {
            [string]$userObject.UserPrincipalName | Should -Be ([string](Get-AdUser $userName -Properties EmailAddress).EmailAddress) -Because "the Email Address should match the UPN, which follows the firstname.lastname format"
        }
        It -Name "UPN matches SIP Address" {
            ("sip:", [string]$userObject.UserPrincipalName -join "") | Should -Be ([string](Get-ADUser $userName -Properties msRTCSIP-PrimaryUserAddress).'msRTCSIP-PrimaryUserAddress') -Because "the SIP Address should match the UPN, which follows the firstname.lastname format"
        }
        It -Name "SIP matches EUM Address" {
            $eum = [string]($userObject.proxyAddresses | Where-Object { $_ -cmatch "EUM" })
            $eumString = $eum.IndexOf(";")
            $eum.Substring(0,$eumString) | Should -Be ("EUM:", (([string](Get-ADUser $userName -Properties msRTCSIP-PrimaryUserAddress).'msRTCSIP-PrimaryUserAddress').Trim("sip:")) -join "") -Because "EUM will not function when the SIP doesn't match"
        }
    }
    Context -Name "User Profile Information" -Fixture {
        It -Name "Company is Set" {
            [string]$userObject.Company | Should -Not -BeNullOrEmpty -Because "the company field should be set"
        }
        It -Name "Department is Set" {
            [string]$userObject.Department | Should -Not -BeNullOrEmpty -Because "the department field should be set"
        }
        It -Name "Employee ID is Set" {
            [string]$userObject.EmployeeID | Should -Not -BeNullOrEmpty -Because "all employees have an ID"
        }
        It -Name "Title is Set" {
            [string]$userObject.title | Should -Not -BeNullOrEmpty -Because "all employees have titles"
        }
        It -Name "Manager is Set" {
            [string]$userObject.Manager | Should -Not -BeNullOrEmpty -Because "the manager field should be set"
        }
        It -Name "Phone Number is Set" {
            [string]$userObject.telephoneNumber | Should -Not -BeNullOrEmpty -Because "most employees should have a phone number"
        }
        It -Name "Phone Number is Formatted Correctly" {
            [string]$userObject.telephoneNumber  | Should -Match ("^(?:(?:\+1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?$") -Because "Mark wants our GAL to look nice"
        }
    }
    Context -Name "Location Information" -Fixture {
        It -Name "Country is Set" {
            [string]$userObject.c | Should -Not -BeNullOrEmpty
        }
        It -Name "City is Set" {
            [string]$userObject.l | Should -Not -BeNullOrEmpty
        }
        It -Name "Office is Set" {
            [string]$userObject.Office | Should -Not -BeNullOrEmpty
        }
        It -Name "Postal Code is Set" {
            [string]$userObject.PostalCode | Should -Not -BeNullOrEmpty
        }
        It -Name "State is Set" {
            [string]$userObject.st | Should -Not -BeNullOrEmpty
        }
        It -Name "Street Address is Set" {
            [string]$userObject.StreetAddress | Should -Not -BeNullOrEmpty
        }

    }
}