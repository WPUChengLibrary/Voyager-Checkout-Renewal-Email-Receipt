#!/usr/local/bin/perl -w

###############################################################
# Sends email to patron automaticly within 10 min.                                          #
# Set up the Schedule tasks in ColdFusion Administrator or Crontab to run the script every 10 min.
#JUNE, 2017 - Hao Zeng                                    #  
###############################################################

use strict;
use DBI;

my $TDAY=`date +%e-%h-%Y`;


$ENV{ORACLE_SID} = "VGER";
$ENV{ORACLE_HOME} = "/oracle/app/oracle/product/11.2.0.3/db_1";
# $ENV{ORACLE_HOME} = "/oracle/app/oracle/product/10.2.0/db_1";

#  Your database name
my $db_name = "wmpatrsndb";

#  Report directory where you will store the output
#  file prior to transfering it to WebVoyage.
my $report_dir = ".";

#  Voyager (Oracle) read-only username and password
my $username = "ro_xxxdb";
my $password = "ro_xxxdb";
my $sql_option = "1";
my $character_set = "marc8";

&DoQuery;

##########################################################
#  DoQuery
##########################################################


sub DoQuery {
    # Connect to Oracle database
    my $dbh = DBI->connect('dbi:Oracle:', $username, $password)
	|| die "Could not connect: $DBI::errstr";

    # Prepare the SQL statement
    my $sth = $dbh->prepare(&ConstructSQL_Patron) || die $dbh->errstr;
    # Run the SQL query
    $sth->execute || die $dbh->errstr;
    while( my @patron = $sth->fetchrow_array() ) 
	{
	my $patronid = $patron[0];
	for ($patronid){
		my $sth = $dbh->prepare(&ConstructSQL_Patron_Information) || die $dbh->errstr;
		$sth->execute($patronid) || die $dbh->errstr;
		while( my (@patron_info) = $sth->fetchrow_array() ) 
		{
		my $to = 'zengh@wpunj.edu';
		my $from = 'do-not-reply@library.wpunj.edu'; 
		open(MAIL, "|/usr/sbin/sendmail -t");
		# Email Header
		print MAIL "To: $to\n";
		print MAIL "From: $from\n";
		print MAIL "Subject: Cheng Library Checkout Receipt: $patron_info[1] $patron_info[2]\n";
		print MAIL "Content-type: text/html\n";
		# Email Body
		print MAIL "$TDAY</br>
					David and Lorraine Cheng Library</br>
					Lending Services Department</br></br>
					Dear $patron_info[1] $patron_info[2]</br></br>
					What you have checked out:</br></br>";
		# Checkout items list.
		my $sth = $dbh->prepare(&ConstructSQL_Item) || die $dbh->errstr;
		$sth->execute($patronid) || die $dbh->errstr;
		while( my (@item) = $sth->fetchrow_array() ) {
			print MAIL "Title: 		<strong>$item[5]</strong></br>
						Barcode: 	$item[7]</br>
						Call Number: $item[6]</br>
						Due Date: <strong>$item[2]</strong></br></br>";
			}
		print MAIL "</br></br>If you have any further questions, please do not hesitate to contact us at:</br>
					David and Lorraine Cheng Library</br>
					Lending Services Department</br>
					Phone: 973-720-3180";
		close(MAIL);
					}
		}

	}
	$sth->finish;
    $dbh->disconnect;
}
##########################################################
#  ConstructSQL
##########################################################
sub ConstructSQL_Patron {
    if ($sql_option eq "1") {
	return ("
SELECT DISTINCT
	$db_name.CIRC_TRANSACTIONS.PATRON_ID
FROM 
	$db_name.CIRC_TRANSACTIONS
WHERE 
	($db_name.CIRC_TRANSACTIONS.CHARGE_DATE)>= SYSDATE -1/144
	");
    } else {
	print "Error: no SQL option selected.\n";
	exit (22);
    }
}

sub ConstructSQL_Patron_Information {
    if ($sql_option eq "1") {
	return ("
SELECT DISTINCT
	$db_name.PATRON.PATRON_ID, 
	$db_name.PATRON.LAST_NAME, 
	$db_name.PATRON.FIRST_NAME, 
	$db_name.PATRON_ADDRESS.ADDRESS_LINE1
FROM 
    $db_name.PATRON,
	$db_name.PATRON_ADDRESS
WHERE 
	$db_name.PATRON.PATRON_ID = ?
	AND $db_name.PATRON.PATRON_ID = $db_name.PATRON_ADDRESS.PATRON_ID
	AND (($db_name.PATRON_ADDRESS.ADDRESS_TYPE)=3)
	");
    } else {
	print "Error: no SQL option selected.\n";
	exit (22);
    }
}


sub ConstructSQL_Item {
    if ($sql_option eq "1") {
	return ("
SELECT DISTINCT
	$db_name.CIRC_TRANSACTIONS.PATRON_ID, 
	$db_name.CIRC_TRANSACTIONS.CHARGE_DATE, 
	$db_name.CIRC_TRANSACTIONS.CHARGE_DUE_DATE, 
	$db_name.CIRC_TRANSACTIONS.ITEM_ID, 
	$db_name.CIRC_TRANSACTIONS.CHARGE_LOCATION,
	$db_name.BIB_VW.TITLE, 
	$db_name.ITEM_VW.CALL_NO,
	$db_name.ITEM_VW.BARCODE,
	$db_name.ITEM_VW.PERM_LOCATION
FROM 
	$db_name.CIRC_TRANSACTIONS,
	$db_name.ITEM_VW,
	$db_name.BIB_VW
WHERE 
	$db_name.CIRC_TRANSACTIONS.PATRON_ID = ?
	AND $db_name.CIRC_TRANSACTIONS.ITEM_ID = $db_name.ITEM_VW.ITEM_ID
	AND $db_name.ITEM_VW.MFHD_ID = $db_name.BIB_VW.MFHD_ID
	AND ($db_name.CIRC_TRANSACTIONS.CHARGE_DATE)>= SYSDATE -1/144
	AND $db_name.ITEM_VW.PERM_LOCATION != '9'
ORDER BY $db_name.CIRC_TRANSACTIONS.CHARGE_DATE DESC
	");
    } else {
	print "Error: no SQL option selected.\n";
	exit (22);
    }
}
