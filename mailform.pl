#!/usr/bin/perl

                         ### *** IMPORTANT *** ###

       ### *** Make sure the path to PERL above is correct *** ###


      #################################################################
      #                                                               #
      #                       Mail Form Ver 2.0                       #
      #                                                               #
      #                              by                               #
      #                        Ranson Johnson                         #
      #                                                               #
      # E-Mail: ranson@rlaj.com                                       #
      #                                                               #
      # Script name: mailform.pl                                      #
      #                                                               #
      # Copywrite 1997/2000 by Ranson's Scripts all rights reserved   #
      # Sale or re-distribution of this program without prior written #
      # permision is prohibited. you may modify this program for      #
      # your own use.                                                 #
      #################################################################


                      ### *** IMPORTANT *** ###

### *** If FTP'ing this file, be sure to send in ASCII format *** ###

# You must chmod the cgi's to 755 
# For information on chmod see Ranson's FAQ's

#  Configure the varialbles in the configuration section below
#    be careful to not disturb the single (') or double quotes (") 
#    surounding each variable, or the semicolon (;) at the end of 
#    each line.


# This program is set up for Unix mail - Sendmail - /usr/sbin/sendmail
#
# And NT mail SendMail.pm - A mail module for NT Servers
# 
# Ask your server admin for the SMTP server to use for your mail.
# 
# If you need the path to the require 'SendMail.pm' 
# ASK YOUR SERVER ADMINISTRATOR FOR THE PATH TO THIS DIRECTORY
#
# We can not help with this.

# The securiety routine below is to keep users from accessing this program
# from their computer or another server.
# If you are getting an invalid referer error, you may need to put the
# domain name for your site in the tag below. Relpace the "$ENV{'SERVER_NAME'}"
# with the domain name for your site. 

if($ENV{'HTTP_REFERER'} !~ /$ENV{'SERVER_NAME'}/) { &invalid_referer; }


            ### *** DO NOT CHANGE ANYTHING BELOW*** ###



                         ### *** *** ###
                         ### *** *** ###

&parse_data;

$operating_system = "$FORM{'XX-OS'}";
$Define_SMTP_Server = "$FORM{'XX-SMPT'}";
$Set_Debug = "$FORM{'XX-debug'}";
$mailprog = "$FORM{'XX-MailProgram'}"; 


print "Content-Type: text/html\n\n";


            ### *** Check for Required Fields *** ###

if ($FORM{'XX-send-to-email'} eq "") {
&format_error("The 'XX-send-to-email' is not present on the form, please see the read-me file.");
}
if ($FORM{'XX-send-to-email'} !~ /^[^@]+@([-\w]+\.)+[A-Za-z]{2,4}$/) {
&format_error("The 'XX-send-to-email' is not present on the form, or it is not formatted correctly.");
}
if ($FORM{'XX-subject'} eq "") {
&format_error("The 'XX-subject' is not present on the form, please see the read-me file.");
}
if ($FORM{'XX-attach_file'} ne "" && (! -e "$FORM{'XX-attach_file'}")) {
&open_error("The program can not find the attchment file specified on your form. Check the path and file name.");
}


if ($FORM{'REQUIRED'} ne "") {
@Required = split(/,/,$FORM{'REQUIRED'});
foreach $field (sort(@Required)) {
&required("$field") unless($FORM{$field} ne "");
 }
}
&format_mail;


                 ### *** SEND THE MAIL *** ###

sub format_mail {

if ($FORM{'XX-sort'} =~ /yes/i) {
@Form_Data = sort(@FORM);
}else{
@Form_Data = @FORM;
}

if ($FORM{'XX-Sort_Order'}) {
@sort_fields = split(/,/, $FORM{'XX-Sort_Order'});
foreach $sortfield(@sort_fields) {
foreach $formfield (@Form_Data) {
    ($key, $val) = split(/=/,$formfield); 
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;
if (($key eq "$sortfield")) {
$Mail_Body .= "$key - $val\n\n";
   }
  }
 }
}else{
foreach $formfield (@Form_Data) {
    ($key, $val) = split(/=/,$formfield); 
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;
if ($key !~ /XX|REQUIRED/) {
$Mail_Body .= "$key - $val\n\n";
  }
 }
}
if ($FORM{'XX-attach_file'} && ($operating_system =~ /unix/i)) {
$Mail_Body .= "\n";
  open (TEXT, "uuencode $FORM{'XX-attach_file'} $FORM{'XX-attach_file_name'} |");
  while (<TEXT>)  {
    $Mail_Body .= $_;
  }
 close TEXT;
}
if ($FORM{'XX-attach_file'} && ($operating_system =~ /windows/i)) {
$Mail_Body .= "\n";
  open (TEXT, "$FORM{'XX-attach_file'}");
  while (<TEXT>)  {
    $Mail_Body .= $_;
  }
 close TEXT;
}
if ($operating_system =~ /windows/i) {
&windows_mail;
}else{
&unix_mail;
 }
} # End sub format_mail


                ### *** DO NOT EDIT BELOW *** ###

sub unix_mail {

if ($FORM{'XX-MailProgram'} && (!-e "$mailprog")) {
&open_error("The mail program is incorrect for your server. $mailprog");
}

        open (MAIL, "|$mailprog -t -oi -oem");
        print MAIL"To: $FORM{'XX-send-to-email'}\n";
        print MAIL"From: $FORM{'XX-email'}\n";
        print MAIL"Subject: $FORM{'XX-subject'}\n\n";


   print MAIL "$Mail_Body";
close (MAIL);
} # End unix mail

                        ### *** :) *** ###


sub windows_mail {
eval {
$path = $0;
$filename = $path;
		
		$filename =~ s/^.*\\//;
		$path =~ s/$filename//;
		$path =~ s/\\$//;
		unshift (@INC, "$path");
		require 'SendMail.pm';  
                  };
        if ($@) {
                print "<PRE>\n\n";
        if ($! =~ /No such file/i) {
                print "Error Finding the SendMail.pm File: \n\n";
                print "$@\n";
                print "Make sure the SendMail.pm file is in this directory.\n";
                print "You may need to put the complete path in the require statement.\n\n";
                print "The require statement is on line 180 of this file.\n";
                print "$0";
                print "</PRE>";
        }
}

# WINDOWS MAIL

$sm = new SendMail("$Define_SMTP_Server");
if ($Set_Debug eq "1") {
$sm->setDebug($sm->ON);
}else{
$sm->setDebug($sm->OFF);
}$sm->From("$FORM{'XX-email'}");
$sm->Subject("$FORM{'XX-subject'}");
$sm->To("$FORM{'XX-send-to-email'}");
$sm->setMailBody("$Mail_Body");
if ($sm->sendMail() != 0) {
print "Content-type: text/plain\n\n";
  print $sm->{'error'}."\n";
  exit -1;
 }
} # End windows mail


                   ### *** Redirect *** ###

if ($FORM{'XX-redirect-to-url'} ne "") {
    print <<"~EOT~";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<title></title>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=ISO-8859-1">
<META HTTP-EQUIV="Refresh" CONTENT="0; URL=$FORM{'XX-redirect-to-url'}"></HEAD>
<BODY BGCOLOR="FFFFFF">
</BODY>
</HEAD>
~EOT~
}else{
           ### *** Just Print Thank You Screen *** ###

    print <<"EOT";

<HTML>
<HEAD>
<TITLE>Mail Sent</TITLE>
</HEAD>
<BODY BGCOLOR=#FFFFFF Link=#0000FF vlink=#1D307E>
<P>
<B><FONT COLOR=000000 SIZE=+2>Thank You</FONT>
<BR>
<FONT COLOR=FF0000 SIZE=+1>Your Mail Has Been Sent</FONT></B>
<P>
&nbsp;
<P>
</BODY>
</HTML>

EOT
        ## DO NOT DISTURB THE LINE ABOVE 
exit;
}


                         ### *** END OF PROGRAM *** ###

sub parse_data {

  local (*FORM) = @_ if @_;
  local ($i, $key, $val);

  # Read in text
  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $FORM = $ENV{'QUERY_STRING'};
  } 
  elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$FORM,$ENV{'CONTENT_LENGTH'});
  }
  @FORM = split(/[&;]/,$FORM); 
  foreach $i (0 .. $#FORM) 
  {
    # Convert plusses to spaces
    $FORM[$i] =~ s/\+/ /g;

    # Split into key and value
    # splits on the first =
    ($key, $val) = split(/=/,$FORM[$i],2); 

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    $val =~ s/`//g;
    $val =~ s/\*//g;
    $val =~ s/<!--(.|\n)*-->//g;
    $FORM{$key} .= "\0" if (defined($FORM{$key})); 
    $FORM{$key} .= $val;
  }
  return scalar(@FORM);
 
} # End sub parse


                         ### *** *** ###

sub required {

    local ($errorname) = @_;
    $errorname =~ s/XX\-//;
    print <<"EOT";

<HTML>
<HEAD>
<TITLE>Form Error!</TITLE>
</HEAD>
<BODY BGCOLOR=#FFFFFF Link=#0000FF vlink=#1D307E>
<P>
<B><FONT COLOR=000000 SIZE=+2>Form Error</FONT>
&nbsp; &nbsp; 
<FONT COLOR=FF0000 SIZE=+2>$errorname</FONT></B>
<P>
&nbsp;
<P>
<CENTER>
<B><FONT FACE="Arial" COLOR="000080" SIZE="+1">
A Required field on the form has been left blank.
<BR> 
Please go back to the form and check the field.</FONT></B>
<P>
<form><input type="button" value="BACK" onClick=history.back()>
<P>
</CENTER>
</BODY>
</HTML>

EOT
        ## DO NOT DISTURB THE LINE ABOVE 
exit;
}

                         ### *** *** ###

sub open_error
    {

    local ($errorname) = @_;
    print <<"EOT";
<HTML>
<HEAD>
<TITLE>Open Error!</TITLE>
</HEAD>
<BODY BGCOLOR=#FFFFFF Link=#0000FF vlink=#1D307E>
<P>
<HR>
<P>
<H1>Error!</H1>
<P>
<H3>$errorname</H3>
<P>
<B>$!</B>  
<P>
</BODY>
</HTML>

EOT

exit;
} # End sub open_error


sub format_error {

    local ($errorname) = @_;
    print <<"EOT";
<HTML>
<HEAD>
<TITLE>Open Error!</TITLE>
</HEAD>
<BODY BGCOLOR=#FFFFFF Link=#0000FF vlink=#1D307E>
<P>
<HR>
<P>
<H1>Error!</H1>
<P>
<H3>$errorname</H3>
<P>
</BODY>
</HTML>
EOT
exit;
}

                        ### *** :) *** ###

sub invalid_referer {

print <<"Close~//~Print";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<title>Referer Error</title>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=ISO-8859-1">
</HEAD>
<BODY BGCOLOR="#EEF3F9" TEXT="#000000">
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 Width="100%">
<TR>
        <TH BGCOLOR="#D0D8EA" Colspan=4><BR>
<B><FONT SIZE="+3">An Error Has Occured - Invalid Referer</FONT></B>

</TH> 
</TR>
<TR>
<TD BGCOLOR="#D0D8EA"><FONT SIZE="-3">&nbsp;</FONT></TD><TD BGCOLOR="#000080" Colspan=3><FONT SIZE="1">&nbsp;</FONT></TD>
</TR>
<TR>
<TD BGCOLOR="#D0D8EA"><FONT SIZE="6">&nbsp;</FONT></TD><TD BGCOLOR="#000080"><FONT SIZE="6">&nbsp;</FONT></TD><TD BGCOLOR="#D0D8EA" Colspan=2><FONT SIZE="1">&nbsp;</FONT></TD>
</TR>
<TR>
<TD BGCOLOR="#D0D8EA" Width="5%">
<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>
</TD>
<TD BGCOLOR="#000080" Width="2%"><FONT SIZE="1">&nbsp;</FONT></TD>
<TD BGCOLOR="#D0D8EA" Width="5%">&nbsp;</TD>
<TD Valign=top>
<BR><BR>
<CENTER>
<B><FONT COLOR="#A6471A" SIZE="+1">
The System Administrator has determined that this program
<BR>
can not be accessed from the page you came from.
</FONT></B>
<P>
<FORM>
<TABLE BORDER=1 BGCOLOR=#FF0000 cellpadding=3 cellspacing=0>
<TR><TD>
<input type="button" value="BACK" onClick=history.back()></TD>
</TR></TABLE>
</FORM>
<P>
<B><FONT COLOR="#621E42" SIZE="+1">Please go back to the Previous page and inform the webmaster.</FONT> 
<P>&nbsp;<P>
<FONT COLOR="" SIZE="">If you feel this is in error, contact the 
<A HREF="mailto:$FORM{'XX-send-to-email'}">webmaster</A> for this site.</FONT>
</CENTER>
</TR>
</TABLE>

<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>&nbsp;<P>
</BODY>
</HTML>
Close~//~Print
exit;
}

                        ### *** :) *** ###



__END__

