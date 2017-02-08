<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>ciremailnotification</title>
<cfquery name="ciremailnotificationrenew" datasource="voyager">

SELECT 
PATRON.PATRON_ID, 
PATRON.LAST_NAME, 
PATRON.FIRST_NAME, 
RENEW_TRANSACTIONS.RENEW_DATE, 
PATRON_ADDRESS.ADDRESS_LINE1, 
PATRON_ADDRESS.ADDRESS_TYPE, 
RENEW_TRANSACTIONS.RENEW_DUE_DATE, 
CIRC_TRANSACTIONS.ITEM_ID, BIB_VW.TITLE, 
ITEM_VW.CALL_NO, 
ITEM_VW.BARCODE, 
CIRC_TRANSACTIONS.CHARGE_LOCATION, 
ITEM_VW.PERM_ITEM_TYPE, 
ITEM_VW.PERM_LOCATION_CODE, 
ITEM.TEMP_LOCATION

FROM 
(((((PATRON INNER JOIN CIRC_TRANSACTIONS ON PATRON.PATRON_ID = CIRC_TRANSACTIONS.PATRON_ID) 
INNER JOIN PATRON_ADDRESS ON PATRON.PATRON_ID = PATRON_ADDRESS.PATRON_ID) 
INNER JOIN ITEM_VW ON CIRC_TRANSACTIONS.ITEM_ID = ITEM_VW.ITEM_ID) 
INNER JOIN BIB_VW ON ITEM_VW.MFHD_ID = BIB_VW.MFHD_ID) 
INNER JOIN ITEM ON CIRC_TRANSACTIONS.ITEM_ID = ITEM.ITEM_ID) 
INNER JOIN RENEW_TRANSACTIONS ON CIRC_TRANSACTIONS.CIRC_TRANSACTION_ID = RENEW_TRANSACTIONS.CIRC_TRANSACTION_ID

WHERE 

 ((PATRON_ADDRESS.ADDRESS_TYPE)=3)
	AND (RENEW_TRANSACTIONS.RENEW_DATE)>= SYSDATE -1/24
	And ITEM_VW.PERM_ITEM_TYPE NOT LIKE 'E-%'
	AND ITEM_VW.PERM_ITEM_TYPE != 'T- ReserveBk'
	AND ITEM.TEMP_LOCATION != '9'


ORDER BY RENEW_TRANSACTIONS.RENEW_DATE DESC

</cfquery>

<body>

<cfoutput query="ciremailnotificationrenew" group = "PATRON_ID">

	<cfmail from="do-not-reply-notice@wpunj.edu" to="#ADDRESS_LINE1#" subject="Library Renewal Receipt: #FIRST_NAME# #LAST_NAME#" type="html">
	
<p>#DateFormat(Now())#</p>
<p>Library</br>
<cfif #CHARGE_LOCATION# is '23'>Media Services (IRT)
<cfelseif #CHARGE_LOCATION# is '39'>Periodicals & Document Delivery Department
<cfelse>Lending Services Department</cfif></p>

<p>Dear #FIRST_NAME# #LAST_NAME#</p>
<p><h3>What you have renewed:</h3></p>
<cfoutput>
<p>Location: 	<cfif #CHARGE_LOCATION# is '23'>Media Services (IRT)
				<cfelseif #CHARGE_LOCATION# is '39'>Periodicals & Document Delivery Department
				<cfelse>Lending Services Department</cfif></br>
Title: 		<strong>#TITLE#</strong></br>
Barcode: 	#BARCODE#</br>
Call Number: 	#CALL_NO#</br>
<strong>Renew Due Date: 	#DateFormat(RENEW_DUE_DATE)#</strong></p>
</cfoutput>

	<p>If you have any further questions, please do not hesitate to contact us at:</br>
David and Lorraine Cheng Library</br>
<cfif #CHARGE_LOCATION# is '23'>Media Services (IRT)</br>Phone: 973-720-xxxx
<cfelseif #CHARGE_LOCATION# is '39'>Periodicals & Document Delivery Department</br>Phone: 973-720-xxxx
<cfelse>Lending Services Department</br>Phone: 973-720-xxxx</cfif></p>

	</cfmail>


</br>
</cfoutput>

</body>
</html>
