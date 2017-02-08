<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>ciremailnotification</title>
<cfquery name="ciremailnotification" datasource="voyager">

SELECT
	PATRON.PATRON_ID, 
	PATRON.LAST_NAME, 
	PATRON.FIRST_NAME, 
	CIRC_TRANSACTIONS.CHARGE_DATE, 
	PATRON_ADDRESS.ADDRESS_LINE1, 
	PATRON_ADDRESS.ADDRESS_TYPE, 
	CIRC_TRANSACTIONS.CHARGE_DUE_DATE, 
	CIRC_TRANSACTIONS.ITEM_ID, 
	CIRC_TRANSACTIONS.CHARGE_LOCATION,
	BIB_VW.TITLE, 
	ITEM_VW.CALL_NO,
	ITEM_VW.BARCODE,
	ITEM_VW.PERM_ITEM_TYPE,
	ITEM.TEMP_LOCATION
	
FROM 
    wmpatrsndb.PATRON,
	wmpatrsndb.CIRC_TRANSACTIONS,
	wmpatrsndb.PATRON_ADDRESS,
	wmpatrsndb.ITEM_VW,
	wmpatrsndb.ITEM,
	wmpatrsndb.BIB_VW

WHERE 
	PATRON.PATRON_ID = CIRC_TRANSACTIONS.PATRON_ID
	AND PATRON.PATRON_ID = PATRON_ADDRESS.PATRON_ID
	AND CIRC_TRANSACTIONS.ITEM_ID = ITEM_VW.ITEM_ID
	AND CIRC_TRANSACTIONS.ITEM_ID = ITEM.ITEM_ID
	AND ITEM_VW.MFHD_ID = BIB_VW.MFHD_ID
	AND ((PATRON_ADDRESS.ADDRESS_TYPE)=3)
	AND (CIRC_TRANSACTIONS.CHARGE_DATE)>= SYSDATE -1/144
	And ITEM_VW.PERM_ITEM_TYPE NOT LIKE 'E-%'
	AND ITEM_VW.PERM_ITEM_TYPE != 'T- ReserveBk'
	AND ITEM.TEMP_LOCATION != '9'

ORDER BY CIRC_TRANSACTIONS.CHARGE_DATE DESC

</cfquery>

<body>

<cfoutput query="ciremailnotification" group = "PATRON_ID">


	<cfmail from="do-not-reply-notice@wpunj.edu" to="#ADDRESS_LINE1#" subject="Library Checkout Receipt: #FIRST_NAME# #LAST_NAME#" type="html">
	
<p>#DateFormat(Now())#</p>
<p>Library</br>
<cfif #CHARGE_LOCATION# is '23'>Media Services (IRT)
<cfelseif #CHARGE_LOCATION# is '39'>Periodicals & Document Delivery Department
<cfelse>Lending Services Department</cfif></p>

<p>Dear #FIRST_NAME# #LAST_NAME#</p>
<p><h3>What you have checked out:</h3></p>
<cfoutput>
<p>Location: 	<cfif #CHARGE_LOCATION# is '23'>Media Services (IRT)
				<cfelseif #CHARGE_LOCATION# is '39'>Periodicals & Document Delivery Department
				<cfelse>Lending Services Department</cfif></br>
Title: 		<strong>#TITLE#</strong></br>
Barcode: 	#BARCODE#</br>
Call Number: 	#CALL_NO#</br>
<strong>Due Date: 	#DateFormat(CHARGE_DUE_DATE)#</strong></p>
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
