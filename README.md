## Get Local Network Info

This is a PowerShell script to ping hosts on the local network.

It saves the information and allows the user to choose whether to output
the data to the screen in a DataGrid, or save the file to the temp directory 
on the C: drive.

It also takes the MAC Address (LinkLayerAddress) and performs a lookup
on macvendors.com.

In order to abide by the rules, we have to put a small delay in the webrequests and responses from macvendors.

## To use the script:

### Preparation:

1. Check your organization's policy for use of open source applications and seek approval, if necessary.   The script is presented, to allow detail and function review.

2. For simplicity, copy and paste the script into PowerShell ISE.

(Don't forget to set your execution policy.)

<img src=gridview.PNG>