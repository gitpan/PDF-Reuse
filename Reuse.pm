package PDF::Reuse;

use 5.006;
use strict;
use warnings;

require    Exporter;                  
require    Digest::MD5;
use autouse 'Carp' => qw(carp
                         cluck
                         croak);

use autouse 'Compress::Zlib' => qw(compress($));
use autouse 'Data::Dumper'   => qw(Dumper);
use AutoLoader qw(AUTOLOAD);


our $VERSION = '0.10';
our @ISA     = qw(Exporter);
our @EXPORT  = qw(prFile
                  prPage
                  prId
                  prIdType
                  prInitVars
                  prEnd
                  prExtract
                  prForm
                  prImage
                  prJpeg
                  prDoc
                  prDocForm
                  prFont
                  prFontSize
                  prGraphState
                  prGetLogBuffer
                  prAdd
                  prBar
                  prText
                  prMoveTo
                  prScale
                  prDocDir
                  prLogDir
                  prLog
                  prVers
                  prCid
                  prJs
                  prInit
                  prField
                  prTouchUp
                  prCompress
                  prMbox
                  prBookmark);

our ($utfil, $utrad, $slutNod, $formRes, $formCont,
    $formRot, $del1, $del2, $obj, $nr,
    $vektor, $parent, $resOffset, $resLength, $infil, $seq, $imSeq, $rform, $robj,
    $page, $Annots, $Names, $AARoot, $AAPage, $sidObjNr,  
    $AcroForm, $interActive, $NamesSaved, $AARootSaved, $AAPageSaved, $root,
    $AcroFormSaved, $AnnotsSaved, $id, $ldir, $checkId, $formNr, $imageNr, 
    $filnamn, $interAktivSida, $taInterAkt, $type, $runfil, $checkCs,
    $confuseObj, $compress,$pos, $fontNr, $objNr, $xPos, $yPos,
    $defGState, $gSNr, $pattern, $shading, $colorSpace, $totalCount);
 
our (@kids, @counts, @size, @formBox, @objekt, @parents, @aktuellFont, @skapa,
    @jsfiler, @inits, @bookmarks);
 
our ( %old, %oldObject, %resurser, %form, %image, %objRef, %nyaFunk, %fontSource, 
     %sidFont, %sidXObject, %sidExtGState, %font, %intAct, %fields, %script, 
     %initScript, %sidPattern, %sidShading, %sidColorSpace, %knownToFile,
     %processed);

our $stream  = '';
our $idTyp   = '';
our $ddir    = '';
our $log     = '';

#########################
# Konstanter för objekt
#########################

use constant   oPOS       => 0;
use constant   oSIZE      => 1;
use constant   oSTREAMP   => 2;
use constant   oKIDS      => 3;
use constant   oFORM      => 4;  
use constant   oIMAGE     => 5;  
use constant   oIMAGENR   => 6;  
use constant   oWIDTH     => 7;  
use constant   oHEIGHT    => 8;  
use constant   oTYPE      => 9;
use constant   oNAME      => 10;

###################################
# Konstanter för formulär
###################################

use constant   fOBJ       => 0;
use constant   fRESOFFSET => 1;   
use constant   fRESLENGTH => 2;   
use constant   fBBOX      => 3;
use constant   fSTAMP     => 4;
use constant   fIMAGES    => 5;
use constant   fMAIN      => 6;
use constant   fKIDS      => 7;
use constant   fNOKIDS    => 8;
use constant   fID        => 9;
use constant   fVALID     => 10;

####################################
# Konstanter för images
####################################

use constant   imWIDTH     => 0;   
use constant   imHEIGHT    => 1; 
use constant   imXPOS      => 2;
use constant   imYPOS      => 3;
use constant   imXSCALE    => 4;
use constant   imYSCALE    => 5;
use constant   imIMAGENO   => 6;

#####################################
# Konstanter för interaktiva objekt
#####################################

use constant   iNAMES     => 1;
use constant   iACROFORM  => 2;
use constant   iAAROOT    => 3;
use constant   iANNOTS    => 4;
use constant   iSTARTSIDA => 5;
use constant   iAAPAGE    => 6;

#####################################
# Konstanter för fonter
#####################################
   
use constant   foREFOBJ     => 0;
use constant   foINTNAMN    => 1;
use constant   foEXTNAMN    => 2;
use constant   foORIGINALNR => 3;
use constant   foSOURCE     => 4;

our $xScale   = 1;
our $yScale   = 1;
our $touchUp  = 1;
our $lastFile = '+';

our %stdFont = 
       ('Times-Roman'           => 'Times-Roman',
        'Times-Bold'            => 'Times-Bold',
        'Times-Italic'          => 'Times-Italic',
        'Times-BoldItalic'      => 'Times-BoldItalic',
        'Courier'               => 'Courier',
        'Courier-Bold'          => 'Courier-Bold',
        'Courier-Oblique'       => 'Courier-Oblique',
        'Courier-BoldOblique'   => 'Courier-BoldOblique',
        'Helvetica'             => 'Helvetica',
        'Helvetica-Bold'        => 'Helvetica-Bold',
        'Helvetica-Oblique'     => 'Helvetica-Oblique',
        'Helvetica-BoldOblique' => 'Helvetica-BoldOblique',
        'Symbol'                => 'Symbol',
        'ZapfDingbats'          => 'ZapfDingbats',
        'TR'  => 'Times-Roman',
        'TB'  => 'Times-Bold',
        'TI'  => 'Times-Italic',
        'TBI' => 'Times-BoldItalic',
        'C'   => 'Courier',
        'CB'  => 'Courier-Bold',
        'CO'  => 'Courier-Oblique',
        'CBO' => 'Courier-BoldOblique',
        'H'   => 'Helvetica',
        'HB'  => 'Helvetica-Bold',
        'HO'  => 'Helvetica-Oblique',
        'HBO' => 'Helvetica-BoldOblique',
        'S'   => 'Symbol',
        'Z'   => 'ZapfDingbats');

our $genLowerX    = 0;
our $genLowerY    = 0;
our $genUpperX    = 595,
our $genUpperY    = 842;
our $genFont      = 'Helvetica';
our $fontSize     = 12;

keys(%resurser)  = 10;


    
sub prFont
{   my $nyFont = shift;
    my ($intnamn, $extnamn, $objektnr, $oldIntNamn, $oldExtNamn);
    
    if (! $pos)
    {  errLog("No output file, you have to call prFile first");
    }
    $oldIntNamn = $aktuellFont[foINTNAMN];
    $oldExtNamn = $aktuellFont[foEXTNAMN]; 
    if ($nyFont)
    {  ($intnamn, $extnamn, $objektnr) = findFont($nyFont);
    }
    else
    {   $intnamn = $aktuellFont[foINTNAMN];
        $extnamn = $aktuellFont[foEXTNAMN];
    }
    if ($runfil)
    {  $log .= "Font~$nyFont\n";
    }
    if (wantarray)
    {  return ($intnamn, $extnamn, $oldIntNamn, $oldExtNamn);
    }
    else
    {  return $intnamn;
    }
}

sub prFontSize
{   my $fSize = shift || 12;
    my $oldFontSize = $fontSize;
    if ($fSize !~ m'\D')
    { $fontSize = $fSize;
      if ($runfil)
      {  $log .= "FontSize~$fontSize\n";
      }
    }
    if (! $pos)
    {  errLog("No output file, you have to call prFile first");
    }

    return ($fontSize, $oldFontSize);    
}
    
sub prFile
{  if ($pos)
   {  prEnd();
      close UTFIL;
   }
   $filnamn = shift || '-';
   my $kortNamn;
   if ($filnamn ne '-')
   {   my $ri  = rindex($filnamn,'/');
       if ($ri > 0)
       {  $kortNamn = substr($filnamn, ($ri + 1));
          $utfil = $ddir ? $ddir . $kortNamn : $filnamn; 
       }
       else
       {  $utfil = $ddir ? $ddir . $filnamn : $filnamn;
       }
       $ri = rindex($utfil,'/');
       if ($ri > 0)
       {   my $dirdel = substr($utfil,0,$ri);
           if (! -e $dirdel)
           {  mkdir $dirdel || errLog("Couldn't create dir $dirdel, $!");
           }
       }
       else
       {  $ri = rindex($utfil,'\\');
          if ($ri > 0)
          {   my $dirdel = substr($utfil,0,$ri);
              if (! -e $dirdel)
              {  mkdir $dirdel || errLog("Couldn't create dir $dirdel, $!");
              }
          }
       }

   }
   else
   {   $utfil = $filnamn;
   }
   open (UTFIL, ">$utfil") || errLog("Couldn't open file $utfil, $!");
   binmode UTFIL;
   $utrad = '%PDF-1.4' . "\n" . '%âãÏÓ' . "\n";
   
   $pos   = syswrite UTFIL, $utrad; 

   if (defined $ldir)
   {   if ($utfil eq '-')
       {   $kortNamn = 'stdout';
       }
       if ($kortNamn)
       {  $runfil = $ldir . $kortNamn  . '.dat';
       }
       else
       {  $runfil = $ldir . $filnamn  . '.dat';
       }
       open (RUNFIL, ">>$runfil") || errLog("Couldn't open loggfile $runfil, $!");
       $log .= "Vers~$VERSION\n";        
   }

   
   @parents     = ();
   @kids        = ();
   @counts      = ();
   @objekt      = ();
   $objNr       = 2; # Reserverat objekt 1 för root och 2 för initial sidnod
   $parents[0]  = 2;
   $page        = 0;
   $formNr      = 0;
   $imageNr     = 0;
   $fontNr      = 0;
   $gSNr        = 0;
   $pattern     = 0;
   $shading     = 0;
   $colorSpace  = 0;
   %font        = ();
   %resurser    = ();
   %fields      = ();
   @jsfiler     = ();
   @inits       = ();
   %nyaFunk     = ();
   %objRef      = ();
   %knownToFile = ();
   @aktuellFont = ();
   %processed   = ();
   @bookmarks   = ();
   undef $defGState;
   undef $interActive;
   undef $NamesSaved;
   undef $AARootSaved;
   undef $AcroFormSaved;
   $checkId    = '';
   # undef $aktNod;
   undef $confuseObj;
   $fontSize  = 12;
   $genLowerX = 0;
   $genLowerY = 0;
   $genUpperX = 595,
   $genUpperY = 842;
   
   prPage(1);
   $stream = ' ';                
   if ($runfil)
   {  $filnamn = prep($filnamn);
      $log .= "File~$filnamn\n";
   }
   1;
}


sub prPage
{  my $noLogg = shift;
   if (length($stream) > 0)
   { skrivSida();
   }
   $page++;
   $objNr++;
   $sidObjNr = $objNr;

   #
   # Resurserna nollställs
   #
  
   %sidXObject    = ();
   %sidExtGState  = ();
   %sidFont       = ();
   %sidPattern    = ();
   %sidShading    = ();
   %sidColorSpace = ();
   $xPos          = 0;
   $yPos          = 0;
   $xScale        = 1;
   $yScale        = 1;
   undef $interAktivSida;
   undef $checkCs;
   if (($runfil) && (! $noLogg))
   {  $log .= "Page~\n";
       print RUNFIL $log;
       $log = '';
   }
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
   1;
    
}

sub prText
{ my $xPos = shift;
  my $yPos = shift;
  my $TxT  = shift;

  if (! defined $TxT)
  {  $TxT = '';
  } 

  if (($xPos !~ m'[\d\.]+'o) || (! defined $xPos))
  { errLog("Illegal x-position for text: $xPos");
  } 
  if (($yPos !~ m'[\d\.]+'o) || (! defined $yPos))
  { errLog("Illegal y-position for text: $yPos");
  }

  if ($runfil)
  {   my $Texten   = prep($TxT);
      $log .= "Text~$xPos~$yPos~$Texten\n";
  } 

  $TxT =~ s|\(|\\(|gos;
  $TxT =~ s|\)|\\)|gos;

  if (! $aktuellFont[foINTNAMN])
  {  findFont();
  }
  my $Font        = $aktuellFont[foINTNAMN];        # Namn i strömmen
  $sidFont{$Font} = $aktuellFont[foREFOBJ];

  $stream .= "\nBT /$Font $fontSize Tf ";
  $stream .= "$xPos $yPos Td \($TxT\) Tj ET\n";
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  1;
   
}


sub prAdd
{  my $contents = shift;
   $stream .= "\n$contents\n";
   if ($runfil)
   {   $contents = prep($contents);
       $log .= "Add~$contents\n";
   }
   $checkCs = 1;
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
   1;
}

      
################# Ett grafiskt "formulär" ################

sub prForm
{ my ($sidnr, $adjust, $effect, $tolerant);
  my $param = shift;
  if (ref($param) eq 'HASH')
  {  $infil    = $param->{'file'};
     $sidnr    = $param->{'page'} || 1;
     $adjust   = $param->{'adjust'} || '';
     $effect   = $param->{'effect'} || 'print';
     $tolerant = $param->{'tolerant'} || '';
  }
  else
  {  $infil    = $param;
     $sidnr    = shift || 1;
     $adjust   = shift || '';
     $effect   = shift || 'print';
     $tolerant = shift || '';
  }
  
  my $refNr;
  my $namn;
  $type = 'form';  
  my $fSource = $infil . '_' . $sidnr;
  if (! exists $form{$fSource})
  {  $formNr++;
     $namn = 'Fm' . $formNr;
     $knownToFile{$fSource} = $namn;
     my $action;
     if ($effect eq 'load')
     {  $action = 'load'
     }
     else
     {  $action = 'print'
     }     
     $refNr         = getPage($infil, $sidnr, $action);
     if ($refNr)
     {  $objRef{$namn} = $refNr; 
     }
     else
     {  if ($tolerant)
        {  undef $namn;
        }
        else
        {  my $mess = "$fSource can't be used as a form. Try e.g. to\n"
                    . "save the file as postscript, and redistill\n";
           errLog($mess);
        }
     }
  }
  else
  {  if (exists $knownToFile{$fSource})
     {  $namn = $knownToFile{$fSource};
     }
     else
     {  $formNr++;
        $namn = 'Fm' . $formNr;
        $knownToFile{$fSource} = $namn;
     }
     if (exists $objRef{$namn})
     {  $refNr = $objRef{$namn};
     }
     else
     {  if (! $form{$fSource}[fVALID])
        {  my $mess = "$fSource can't be used as a form. Try e.g. to\n"
                    . "save the file as postscript, and redistill\n";
           if ($tolerant)
           {  cluck $mess;
              undef $namn;
           }
           else
           {  errLog($mess);
           }
        }
        elsif ($effect ne 'load')
        {  $refNr         =  byggForm($infil, $sidnr);
           $objRef{$namn} =  $refNr;
        }
     }
  }
  my @BBox = @{$form{$fSource}[fBBOX]};
  if (($effect eq 'print') && ($form{$fSource}[fVALID]))
  {   if (! defined $defGState)
      { prDefaultGrState();
      }
  
      if ($adjust)
      {   $stream .= "q\n";
          my ($m1, $m2, $m3, $m4, $m5, $m6) = calcMatrix(@BBox, $adjust);
          $stream .= "$m1 $m2 $m3 $m4 $m5 $m6 cm\n";
      
      }
      $stream .= "\n/Gs0 gs\n";   
      if ($refNr)
      {  $stream .= "/$namn Do\n";
         $sidXObject{$namn} = $refNr;
      }
      if ($adjust)
      {  $stream .= "Q\n";
      }
      $sidExtGState{'Gs0'} = $defGState;
  }
  if ($runfil)
  {  $infil = prep($infil);
     $log .= "Form~$infil~$sidnr~$adjust~$effect~$tolerant\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  if (($effect ne 'print') && ($effect ne 'add'))
  {  undef $namn;
  }
  if (wantarray)
  {  my $images = 0;
     if (exists $form{$fSource}[fIMAGES])
     {  $images = scalar(@{$form{$fSource}[fIMAGES]});
     } 
     return ($namn, $BBox[0], $BBox[1], $BBox[2], 
             $BBox[3], $images);
  }
  else
  {  return $namn;
  }
}



##########################################################
sub prDefaultGrState
##########################################################
{  $objNr++;
   $defGState = $objNr;
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }

   $objekt[$objNr] = $pos;
   $utrad = "$objNr 0 obj\n" . '<</Type/ExtGState/SA false/SM 0.02/TR2 /Default'
           . ">>\nendobj\n";
   $pos += syswrite UTFIL, $utrad;
   $objRef{'Gs0'} = $objNr;
   return ('Gs0', $defGState);
}

######################################################
# En font lokaliseras och fontobjektet skrivs ev. ut
######################################################

sub findFont()
{  no warnings;
   my $Font = shift || '';
      
   if (! (exists $fontSource{$Font}))        #  Fonten måste skapas
   {  if (exists $stdFont{$Font})
      {  $Font = $stdFont{$Font};}
      else
      {  $Font = $genFont; }                 # Helvetica sätts om inget annat finns
      if (! (exists $font{$Font}))
      {  $objNr++;
         $fontNr++;
         my $fontAbbr           = 'Ft' . $fontNr; 
         my $fontObjekt         = "$objNr 0 obj\n<</Type/Font/Subtype/Type1" .
                               "/BaseFont/$Font/Encoding/WinAnsiEncoding>>\nendobj\n";
         $font{$Font}[foINTNAMN]      = $fontAbbr; 
         $font{$Font}[foREFOBJ]       = $objNr;
         $objRef{$fontAbbr}           = $objNr;
         $fontSource{$Font}[foSOURCE] = 'Standard';
         $objekt[$objNr]              = $pos;
         $pos += syswrite UTFIL, $fontObjekt;
      }
   }
   else
   {  if (defined $font{$Font}[foREFOBJ])       # Finns redan i filen
      {  ; }
      else
      {  if ($fontSource{$Font}[foSOURCE] eq 'Standard')
         {   $objNr++;
             $fontNr++;
             my $fontAbbr           = 'Ft' . $fontNr; 
             my $fontObjekt         = "$objNr 0 obj\n<</Type/Font/Subtype/Type1" .
                                      "/BaseFont/$Font/Encoding/WinAnsiEncoding>>\nendobj\n";
             $font{$Font}[foINTNAMN]    = $fontAbbr; 
             $font{$Font}[foREFOBJ]     = $objNr;
             $objRef{$fontAbbr}         = $objNr;
             $objekt[$objNr]            = $pos;
             $pos += syswrite UTFIL, $fontObjekt;
         }
         else
         {  my $fSource = $fontSource{$Font}[foSOURCE];
            my $ri      = rindex($fSource, '_');
            my $Source  = substr($fSource, 0, $ri);
            my $Page    = substr($fSource, ($ri + 1));
            
            if (! $fontSource{$Font}[foORIGINALNR])
            {  errLog("Couldn't find $Font, aborts");
            }
            else
            {  my $namn = extractObject($Source, $Page,
                                        $fontSource{$Font}[foORIGINALNR], 'Font');
            } 
         }
      }
   }

   $aktuellFont[foEXTNAMN]   = $Font;
   $aktuellFont[foREFOBJ]    = $font{$Font}[foREFOBJ];
   $aktuellFont[foINTNAMN]   = $font{$Font}[foINTNAMN];
   
   $sidFont{$aktuellFont[foINTNAMN]} = $aktuellFont[foREFOBJ];
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }

   return ($aktuellFont[foINTNAMN], $aktuellFont[foEXTNAMN], $aktuellFont[foREFOBJ]);  
}

sub skrivSida
{  my ($compressFlag, $streamObjekt, @extObj);
   if ($checkCs)
   {  @extObj = ($stream =~ m'/(\S+)\s*'gso);
      checkContentStream(@extObj);
   }
   if (( $compress ) && ( length($stream)  > 100 ))
   {   my $output = compress($stream);
       if ((length($output) > 25) && (length($output) < (length($stream))))
       {  $stream = $output;
          $compressFlag = 1;
       }       
   }
      
   if (! $parents[0])
   { $objNr++;
     $parents[0] = $objNr;
   }
   $parent = $parents[0];

   ##########################################   
   #  Interaktiva funktioner läggs ev. till
   ##########################################

   if ($interAktivSida)
   {  my ($infil, $sidnr) = split(/\s+/, $interActive);
      AcroFormsEtc($infil, $sidnr);
      $NamesSaved     = $Names;
      $AARootSaved    = $AARoot;
      $AnnotsSaved    = $Annots; 
      $AAPageSaved    = $AAPage; 
      $AcroFormSaved  = $AcroForm;
   }

   ##########################
   # Skapa resursdictionary
   ##########################
   my $resursDict = "/ProcSet[/PDF/Text]";
   if (scalar %sidFont)
   {  $resursDict .= '/Font << ';
      my $i = 0;
      for (keys %sidFont)
      {  $resursDict .= "/$_ $sidFont{$_} 0 R";
      }
      
      $resursDict .= " >>";
   }
   if (scalar %sidXObject)
   {  $resursDict .= '/XObject<<';
      for (keys %sidXObject)
      {  $resursDict .= "/$_ $sidXObject{$_} 0 R";
      }
      $resursDict .= ">>";
   }
   if (scalar %sidExtGState)
   {  $resursDict .= '/ExtGState<<';
      for (keys %sidExtGState)
      {  $resursDict .= "\/$_ $sidExtGState{$_} 0 R";
      }
      $resursDict .= ">>";
   }
   if (scalar %sidPattern)
   {  $resursDict .= '/Pattern<<';
      for (keys %sidPattern)
      {  $resursDict .= "/$_ $sidPattern{$_} 0 R";
      }
      $resursDict .= ">>";
   }
   if (scalar %sidShading)
   {  $resursDict .= '/Shading<<';
      for (keys %sidShading)
      {  $resursDict .= "/$_ $sidShading{$_} 0 R";
      }
      $resursDict .= ">>";
   }
   if (scalar %sidColorSpace)
   {  $resursDict .= '/ColorSpace<<';
      for (keys %sidColorSpace)
      {  $resursDict .= "/$_ $sidColorSpace{$_} 0 R";
      }
      $resursDict .= ">>";
   }

      
   my $resursObjekt;
   
   if (exists $resurser{$resursDict})
   {  $resursObjekt = $resurser{$resursDict};  # Fanns ett identiskt,
   }                                           # använd det
   else
   {   $objNr++;
       if ( keys(%resurser) < 10)
       {  $resurser{$resursDict} = $objNr;  # Spara 10 första resursobjekten
       }
       $resursObjekt   = $objNr;
       $objekt[$objNr] = $pos;
       $resursDict     = "$objNr 0 obj\n<<$resursDict>>\nendobj\n";
       $pos += syswrite UTFIL, $resursDict ;
    }
    my $sidObjekt;

    if (! $touchUp)
    {   #
        # Contents objektet skapas
        #

        my $devX = "900";
        my $devY = "900";

        my $mellanObjekt = '<</Type/XObject/Subtype/Form/FormType 1';
        if (defined $resursObjekt)
        {  $mellanObjekt .= "/Resources $resursObjekt 0 R";
        }
        $mellanObjekt .= "/BBox \[$genLowerX $genLowerY $genUpperX $genUpperY\]" .
                     "/Matrix \[ 1 0 0 1 -$devX -$devY \]";

        my $langd = length($stream);
    
        $objNr++;
        $objekt[$objNr] = $pos;        
        if (! $compressFlag)
        {   $mellanObjekt  = "$objNr 0 obj\n$mellanObjekt/Length $langd>>stream\n" 
                           . $stream;
            $mellanObjekt .= "endstream\nendobj\n";
        }
        else
        {   $stream = "\n" . $stream . "\n";
            $langd++;
            $mellanObjekt  = "$objNr 0 obj\n$mellanObjekt/Filter/FlateDecode"
                           .  "/Length $langd>>stream" . $stream;
            $mellanObjekt .= "endstream\nendobj\n";
        }

        $pos += syswrite UTFIL, $mellanObjekt;
        $mellanObjekt = $objNr;

        if (! defined $confuseObj)
        {  $objNr++;
           $objekt[$objNr] = $pos;

           $stream = "\nq\n1 0 0 1 $devX $devY cm\n/Xwq Do\nq\n";
           $langd = length($stream);
           $confuseObj = $objNr;
           $stream = "$objNr 0 obj\n<</Length $langd>>\nstream\n" . "$stream";
           $stream .= "\nendstream\nendobj\n";
           $pos += syswrite UTFIL, $stream;
        }
        $sidObjekt = "$sidObjNr 0 obj\n<</Type/Page/Parent $parent 0 R/Contents $confuseObj 0 R"
                      . "/MediaBox \[$genLowerX $genLowerY $genUpperX $genUpperY\]"
                      . "/Resources <</ProcSet[/PDF/Text]/XObject<</Xwq $mellanObjekt 0 R>>>>";
    }
    else
    {   my $langd = length($stream);
    
        $objNr++;
        $objekt[$objNr] = $pos; 
        if (! $compressFlag)
        {  $streamObjekt  = "$objNr 0 obj\n<</Length $langd>>\nstream\n" . $stream;
           $streamObjekt .= "\nendstream\nendobj\n";
        }
        else
        {  $stream = "\n" . $stream . "\n";
           $langd++;

           $streamObjekt  = "$objNr 0 obj\n<</Filter/FlateDecode"
                             . "/Length $langd>>stream" . $stream;
           $streamObjekt .= "endstream\nendobj\n";
        }

        $pos += syswrite UTFIL, $streamObjekt;
        $streamObjekt = $objNr;
        ##################################
        # Så skapas och skrivs sidobjektet 
        ##################################

        $sidObjekt = "$sidObjNr 0 obj\n<</Type/Page/Parent $parent 0 R/Contents $streamObjekt 0 R"
                      . "/MediaBox \[$genLowerX $genLowerY $genUpperX $genUpperY\]"
                      . "/Resources $resursObjekt 0 R";
    }
    
    $stream = '';

     if (defined $AnnotsSaved)
    {  $sidObjekt .= "/Annots $AnnotsSaved";
       undef $AnnotsSaved;
    }
    if (defined $AAPageSaved)
    {  $sidObjekt .= "/AA $AAPageSaved";
       undef $AAPageSaved;
    }
    $sidObjekt .= ">>\nendobj\n";
    $objekt[$sidObjNr] = $pos;
    $pos += syswrite UTFIL, $sidObjekt;
    push @{$kids[0]}, $sidObjNr;
    $counts[0]++;
    if ($counts[0] > 9)
    {  ordnaNoder(8); }
}


sub prEnd
{   if (! $pos)
    {  return;
    }
    if ($stream)
    { skrivSida(); }
    skrivUtNoder();
   
    ###################
    # Skriv root 
    ###################

    if (! defined $objekt[$objNr])
    {  $objNr--;                   # reserverat sidobjektnr utnyttjades aldrig
    }

    $utrad = "1 0 obj\n<</Type/Catalog/Pages $slutNod 0 R";
    if (defined $NamesSaved)
    {  $utrad .= "\/Names $NamesSaved 0 R\n"; 
    }
    elsif ((scalar %fields) || (scalar @jsfiler))
    {  $Names = behandlaNames();
       $utrad .= "\/Names $Names 0 R\n";
    }
    if (defined $AARootSaved)
    {  $utrad .= "/AA $AARootSaved\n";
    } 
    if ((scalar @inits) || (scalar %fields))
    {  my $nyttANr = skrivKedja();
       $utrad .= "/OpenAction $nyttANr 0 R";
    }
     
    if (defined $AcroFormSaved)
    {  $utrad .= "/AcroForm $AcroFormSaved\n";
    } 
   
    if (scalar @bookmarks)
    {  my $outLine = ordnaBookmarks();
       $utrad .= "/Outlines $outLine 0 R\n";
    }
 
    $utrad .= ">>\nendobj\n";

    $objekt[1] = $pos;
    $pos += syswrite UTFIL, $utrad;
    my $antal = $#objekt;
    my $startxref = $pos;
    my $xrefAntal = $antal + 1;
    $pos += syswrite UTFIL, "xref\n";
    $pos += syswrite UTFIL, "0 $xrefAntal\n";
    $pos += syswrite UTFIL, "0000000000 65535 f \n";
    
    for (my $i = 1; $i <= $antal; $i++)
    {  $utrad = sprintf "%.10d 00000 n \n", $objekt[$i];
       $pos += syswrite UTFIL, $utrad;
    }
    
    $utrad  = "trailer\n<<\n/Size $xrefAntal\n/Root 1 0 R\n";
    if ($idTyp ne 'None')
    {  my ($id1, $id2) = definieraId();
       $utrad .= "/ID [<$id1><$id2>]\n";
       $log  .= "IdType~rep\n";
       $log  .= "Id~$id1\n";
    }
    $utrad .= ">>\nstartxref\n$startxref\n";
    $pos += syswrite UTFIL, $utrad; 
    $pos += syswrite UTFIL, "%%EOF\n";
    close UTFIL;

    if ($runfil)
    {   if ($log)
        { print RUNFIL $log;
        }
        close RUNFIL;
    }
    $log    = '';
    $runfil = '';
    $pos    = 0;
    1;   
}
    
sub ordnaNoder
{  my $antBarn = shift;
   my $i       = 0;
   my $j       = 1;
      
   while  ($antBarn < $#{$kids[$i]})
   {  # 
      # Skriv ut aktuell förälder
      # flytta till nästa nivå
      #
      $vektor = '[';
      
      for (@{$kids[$i]})
      {  $vektor .= "$_ 0 R "; }
      $vektor .= ']';

      if (! $parents[$j])
      {  $objNr++;
         $parents[$j] = $objNr;
      }
      
      my $nodObjekt;
      $nodObjekt = "$parents[$i] 0 obj\n<</Type/Pages/Parent $parents[$j] 0 R\n/Kids $vektor\n/Count $counts[$i]\n>>\nendobj\n";
      
      $objekt[$parents[$i]] = $pos;
      $pos += syswrite UTFIL, $nodObjekt;
      $counts[$j] += $counts[$i];
      $counts[$i]  = 0;
      $kids[$i]    = [];
      push @{$kids[$j]}, $parents[$i];
      undef $parents[$i];
      $i++;
      $j++;
   }
}
          
sub skrivUtNoder
{  no warnings;
   my $i;
   my $j;
   my $si = -1;
   my $nodObjekt;
   #
   # Hitta slutnoden
   #
   for (@parents)
   { $slutNod = $_; 
     $si++;
   }
   
   for ($i = 0; $parents[$i] ne $slutNod; $i++)
   {  if (defined $parents[$i])  # Bara definierat om det finns kids
      {  $vektor = '[';
         for (@{$kids[$i]})
         {  $vektor .= "$_ 0 R "; }
         $vektor .= ']';
         ########################################
         # Hitta förälder till aktuell förälder
         ########################################
         my $nod;
         for ($j = $i + 1; (! $nod); $j++)
         {  if ($parents[$j])
            {  $nod = $parents[$j];
               $counts[$j] += $counts[$i];
               push @{$kids[$j]}, $parents[$i];
            }
         }
      
         $nodObjekt = "$parents[$i] 0 obj\n<</Type/Pages/Parent $nod 0 R\n/Kids $vektor\n/Count $counts[$i]\n>>\nendobj\n";
      
         $objekt[$parents[$i]] = $pos;
         $pos += syswrite UTFIL, $nodObjekt;
      }
   }
   #####################################
   #  Så ordnas och skrivs slutnoden ut
   #####################################
   $vektor = '[';
   for (@{$kids[$si]})
   {  $vektor .= "$_ 0 R "; }
   $vektor .= ']';
   $nodObjekt  = "$slutNod 0 obj\n<</Type/Pages\n/Kids $vektor\n/Count $counts[$si]";
   #$nodObjekt .= "/MediaBox \[$genLowerX $genLowerY $genUpperX $genUpperY\]";
   $nodObjekt .= " >>\nendobj\n";
   $objekt[$slutNod] = $pos;
   $pos += syswrite UTFIL, $nodObjekt;
          
}

sub findGet
{  my ($fil, $cid) = @_;
   $fil =~ s|\s+$||o;
   my ($req, $extFil, $tempFil, $fil2, $tStamp, $res);
   
   if (-e $fil)
   {  $tStamp = (stat($fil))[9];
      if ($cid)
      { 
        if ($cid eq $tStamp)
        {  return ($fil, $cid);
        }
      }
      else
      {  return ($fil, $tStamp);
      }
   }
   if ($cid)
   {  $fil2 = $fil . $cid;
      if (-e $fil2)
      {  return ($fil2, $cid);
      }
   }
   errLog("The file $fil can't be found, aborts");  
}
   
sub definieraId
{  if ($idTyp eq 'rep')
   {  if (! defined $id)
      {  errLog("Can't replicate the id if is missing, aborting"); 
      }
      my $tempId = $id;
      undef $id;
      return ($tempId, $tempId);
   }
   elsif ($idTyp eq 'add')
   {  $id++;
      return ($id, $id);
   }
   else   
   {  my $str = time();
      $str .= $filnamn . $pos;
      $str  = Digest::MD5::md5_hex($str);      
      return ($str, $str);
   }     
}
1;

__END__

=head1 NAME

PDF::Reuse - Reuse and mass produce PDF documents with this module   

=head1 SYNOPSIS

   use PDF::Reuse;                     
   prFile('myFile.pdf');                   # Mandatory function
   prText(100, 500, 'Hello World !');
   prEnd();                                # Mandatory function to flush buffers

=head1 DESCRIPTION

This module could be used when you want to mass produce similar (but not identical)
PDF documents and reuse templates, JavaScripts and some other components. It is
functional to be fast, and to give your programs capacity to produce many pages
per second and very big PDF documents if necessary.

The module produces PDF-1.4 files. Some features of PDF-1.5, like "object streams"
and "cross reference streams",  have not yet been implemented. (If you get problems
with a new document from Acrobat 6.0, try to save it or recreate it as a PDF-1.4
document first, before using it together with this module.) 

=over 2

=item Templates

Use your favorite program, probably a commercial visual tool, to produce single 
PDF-files to be used as templates, and then use this module to B<mass produce> files 
from them. 

(If you want small PDF-files or want special graphics, you can use this module also,
but visual tools are often most practical.)

=item Lists

The module uses "XObjects" extensively. This is a format that makes it possible
create big lists, which are compact at the same time.

=item JavaScript

You can attach JavaScripts to your PDF-files, and "initiate" them (Acrobat 5.0, 
Acrobat Reader 5.1 or higher).
You can have libraries of JavaScripts. No cutting or pasting, and those who include 
the scripts in documents only need to know how to initiate them. (Of course those
who write the scripts have to know Acrobat JavaScript well.) 

=item PDF-operators

The module gives you a good possibility to program at a "low level" with the basic
graphic operators of PDF, if that is what you want to do. You can build your
own libraries of low level routines, with PDF-directives "controlled" by Perl.

=item Archive-format

If you want, you get your new documents logged in a format suitable for archiving 
or transfer.

=back

PDF::Reuse::Tutorial might show you best what you can do with this module.
Look at it first, before proceeding to the functions !

=head1 FUNCTIONS

All functions which are successful return specified values or 1.

Parameters within [] are optional

The module doesn't make any attempt to import anything from encrypted files.

=head2 Mandatory Functions

=head3 prFile ( [$fileName] )           

File to create. If another file is current when this function is called, the first
one is written and closed. Only one file is processed at a single moment. If
$fileName is undefined, output is written to STDOUT.

Look at any program in this documentation for an example. prInitVars() shows how
this function could be used together with a web server.

=head3 prEnd ()

When the processing is going to end, the buffers of the B<last> file has to be written to the disc.
If this function is not called, the page structure, xref part and so on will be 
lost.

Look at any program in this documentation for an example.


=head2 Optional Functions


=head3 prAdd ( $string )

With this command you can add whatever you want to the current content stream.
No syntactical checks are made, but if you use an internal name, the module tries
to add the resource of the "name object" to the "Resources" of current page.
"Name objects" always begin with a '/'. 

(In this documentation I often use talk about an "internal name". It denotes a 
"name object". When PDF::Reuse creates these objects, it assigns Ft1, Ft2, Ft3 ...
for fonts, Im1, Im2, Im3 for images, Fo1 .. for forms, Cs1 .. for Color spaces,
Pt1 .. for patterns, Sh1 .. for shading directories, Gs0 .. for graphic state
parameter dictionaries. These names are kept until the program finishes, 
and my ambition is also to keep the resources available in internal tables.)

This is a simple and very powerful function. You should study the examples and 
the "PDF-reference manual", if you want to use it.(When this text is written,
a possible link to download it is: 
http://partners.adobe.com/asn/developer/acrosdk/docs.html) 

This function is intended to give you detail control at a low level.

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');
   my $string = "150 600 100 50 re\n";  # a rectangle 
   $string   .= "0 0 1 rg\n";           # blue (to fill)
   $string   .= "b\n";                  # fill and stroke
   prAdd($string);                       
   prEnd(); 

=head3 prBar ([$x, $y, $string])

Prints a bar font pattern at the current page.
Returns $internalName for the font.
$x and $y are coordinates in pixels and $string should consist of the characters
'0', '1' and '2' (or 'G'). '0' is a white bar, '1' is a dark bar. '2' and 'G' are
dark, slightly longer bars, guard bars. 
You can use e.g. GD::Barcode or one module in that group to calculate the barcode
pattern. prBar "translates" the pattern to white and black bars.

   use PDF::Reuse;
   use GD::Barcode::Code39;
   use strict;

   prFile('myFile.pdf');
   my $oGdB = GD::Barcode::Code39->new('JOHN DOE');
   my $sPtn = $oGdB->barcode();
   prBar(100, 600, $sPtn);
   prEnd();

Internally the module uses a font for the bars, so you might want to change the font size before calling
this function. In that case, use prFontSize() .
If you call this function without arguments it defines the bar font but does
not write anything to the current page.

B<An easier and often better way to produce barcodes is to use PDF::Reuse::Barcode. 
Look at that module!>

=head3 prBookmark($reference)

Defines a "bookmark". $reference refers to a hash or array of hashes which look
something like this:
 
          {  text  => 'Dokument',
             act   => 'this.pageNum = 0; this.scroll(40, 500);',
             kids  => [ { text => 'Chapter 1',
                          act  => '1, 40, 600'
                        },
                        { text => 'Chapter 2',
                          act  => '10, 40, 600'
                        } 
                      ]
          }

Each hash can have these components:

        text    the text shown beside the bookmark
        act     the action to be triggered. Has to be a JavaScript action.
                (Three simple numbers are translated to page, x and y in the
                sentences: this.pageNum = page; this.scroll(x, y); )
        kids    will have a reference to another hash or array of hashes
        color   3 numbers, RGB-colors e.g. '0.5 0.5 1' for light blue
        style   0, 1, 2, or 3. 0 = Normal, 1 = Italic, 2 = Bold, 3 = Bold Italic



Creating bookmarks for a document:

    use PDF::Reuse;
    use strict;

    my @pageMarks;

    prFile('myDoc.pdf');

    for (my $i = 0; $i < 100; $i++)
    {   prText(40, 600, 'Something is written');
        # ...
        my $page = $i + 1;
        my $bookMark = { text => "Page $page",
                         act  => "$i, 40, 700" };
        push @pageMarks, $bookMark;
        prPage();
    }
    prBookmark( { text => 'Document',
                  kids => \@pageMarks } );
    prEnd();


B<N.B. Traditionally bookmarks have mainly been used for navigation within a document,
but they can be used for many more things. You can e.g. use them to navigate within
your data. You can let your users go to external links also, so they can "drill down"
to other documents.> 


=head3 prCid ( $timeStamp )

An internal function. Don't bother about it. It is used in automatic
routines when you want to restore a document. It gives modification time of
the next PDF-file or JavaScript.
See "Restoring a document from the log" in the tutorial for more about the
time stamp

=head3 prCompress ( [1] )

'1' here is a directive to compress the streams of the current file.
Streams shorter than 101 bytes are not compressed. The streams are compressed in
memory, so probably there is a limit of how big the streams can be.
prCompress(); is a directive not to compress. This is default.

See e.g. "Starting to reuse" in the tutorial for an example.

=head3 prDoc ( $documentName )

Adds a document to the document you are creating. If it is the first interactive
component ( prDoc() or prDocForm() ) the interactive functions are kept and also merged
with JavaScripts you have added (if any).

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');                  # file to make
   prJs('customerResponse.js');           # include a JavaScript file
   prInit('nameAddress(12, 150, 600);');  # init a JavaScript function
   prForm('best.pdf');                    # page 1 from best.pdf
   prPage();                              # page break
   prDoc('long.pdf');                     # a document with 11 pages
   prPage();                              # page break
   prForm('best.pdf');                    # page 1 from best.pdf
   prText(150, 700, 'Customer Data');     # a line of text
   prEnd(); 


=head3 prDocDir ( $directoryName )

Sets directory for produced documents

   use PDF::Reuse;
   use strict;

   prDocDir('C:/temp/doc');
   prFile('myFile.pdf');         # writes to C:\temp\doc\myFile.pdf
   prForm('myFile.pdf');         # page 1 from ..\myFile.pdf
   prText(200, 600, 'New text');
   prEnd();

=head3 prDocForm ( $pdfFile, [$page, $adjust, $effect] )

Reuses an interactive page

Alternatively you can call this function with a hash like this

    my $intName = prDocForm ( {file   => 'myFile.pdf',
                               page   => 2,
                               adjust => 1,
                               effect => 'print' } );


If B<$pageNo> is missing, 1 is assumed. 
B<$adjust>, could be 1 or nothing. If it is given the program tries to
adjust the page to the current media box (paper size). Usually you shouldn't adjust
an interactive page. The graphic and interactive components are independent of 
each other and it is a great risk that any coordination is lost. 
B<$effect> can have 3 values: B<'print'>, which is default, loads the page in an internal
table, adds it to the document and prints it to the current page. B<'add'>, loads the
page and adds it to the document. (Now you can "manually" manage the way you want to
print it to different pages within the document.) B<'load'> just loads the page in an 
internal table. (You can now take I<parts> of a page like fonts and objects and manage
them, without adding all the page to the document.) You don't get any defined internal name of the
form, if you let this parameter be 'load'.

In list context returns B<$internalName, @BoundingBox[1..4], $numberOfImages>.
In scalar context returns B<$internalName> of the graphic form.

This function redefines a page to an "XObject" (the graphic parts), then the 
page can be reused in a much better way. Unfortunately there is an important 
limitation here. "XObjects" can only have single streams. If the page consists
of many streams, you should concatenate them first. Adobe Acrobat can do that.
(If it is an important file, take a copy of it first.Sometimes the procedure fails.)
You open the file with Acrobat and choose the "Touch Up" tool and change anything
graphic in the page. You could e.g. remove 1 space and put it back. Then you
save the file.

   use PDF::Reuse;
   use strict;

   prDocDir('C:/temp/doc');
   prFile('newForm.pdf');
   prField('Mr/Ms', 'Mr');
   prField('First_Name', 'Lars');
   prDocForm('myFile.pdf');
   prFontSize(24);
   prText(75, 790, 'This text is added');
   prEnd();

(You can use the output from the example in prJs() as input to this example.
Remember to save that file before closing it.)


=head3 prExtract ( $pdfFile, $pageNo, $oldInternalName )

B<oldInternalName>, a "name"-object.  This is the internal name you find in the original file.
Returns a B<$newInternalName> which can be used for "low level" programming. You
have better look at graphObj_pl and modules it has generated for this distribution,
e.g. thermometer.pm, to see how this function can be used.  

When you call this function, the necessary objects will be copied to your new
PDF-file, and you can refer to them with the new name you receive.

=head3 prField ( $fieldName, $value )

B<$fieldName> is an interactive field in the document you are creating.
It has to be spelled exactly the same way here as it spelled in the document.
B<$value> is what you want to assigned to the field. 

See prDocForm() for an example

If you are going to assign a value to a field consisting of several lines, you
can write like this:

   my $string = 'This is the first line \\\r second line \\\n 3:rd line';
   prField('fieldName', $string);

You need 3 backslashes to preserve the special characters, if you have single-quotes.

=head3 prFont ( [$fontName] )

Sets current font.

$fontName is an "external" font name. 
In list context returns B<$internalName, $externalName, $oldInternalName,
$oldExternalname> The first two variabels refer to the current font, the two later
to the font before the change. In scalar context returns b<$internalName>

If a font wasn't found, Helvetica will be set.
These names are always recognized:
B<Times-Roman, Times-Bold, Times-Italic, Times-BoldItalic, Courier, Courier-Bold,
Courier-Oblique, Courier-BoldOblique, Helvetica, Helvetica-Bold, Helvetica-Oblique,
Helvetica-BoldOblique> or abbreviated 
B<TR, TB, TI, TBI, C, CB, CO, CBO, H, HB, HO, HBO>. 
(B<Symbol and ZapfDingbats> or abbreviated B<S, Z>, also belong to the predefined
fonts, but there is something with them that I really don't understand. You should
print them first on a page, and then use other fonts, otherwise they are not displayed.)

You can also use a font name from an included page. It has to be spelled exactly as
it is done there. Look in the file and search for "/BaseFont" and the font
name. But take care, e.g. the PDFMaker which converts to PDF from different 
Microsoft programs, only defines exactly those letters you can see on the page. You
can use the font, but perhaps some of your letters were not defined. 

In the distribution there is an utility program, 'reuseComponent_pl', which displays
included fonts in a PDF-file and prints some letters. Run it to see the name of the
font and if it is worth extracting.

   use PDF::Reuse;
   use strict;
   prFile('myFile.pdf');

   ####### One possibility #########

   prFont('Times-Roman');     # Just setting a font
   prFontSize(20);
   prText(180, 790, "This is a heading");

   ####### Another possibility #######

   my $font = prFont('C');    # Setting a font, getting an  
                              # internal name
   prAdd("BT /$font 12 Tf 25 760 Td (This is some other text)Tj ET"); 
   prEnd();

The example above shows you two ways of setting and using a font. One simple, and
one complicated with a possibility to detail control. 


=head3 prFontSize ( [$size] )

Sets current font size, returns B<$actualSize, $fontSizeBeforetheChange>.
prFontSize() sets the size to 12 pixels, which is default. 

=head3 prForm ( $pdfFile, [$page, $adjust, $effect, $tolerant] )

Reuses a page from a PDF-file.

Alternatively you can call this function with a hash like this

    my $internalName = prForm ( {file     => 'myFile.pdf',
                                 page     => 2,
                                 adjust   => 1,
                                 effect   => 'print',
                                 tolerant => 1 } );

if B<$page> is excluded 1 is assumed. B<$adjust>, could be 1 or nothing. If it is 
given, the program tries to adjust the page to the current media box (paper size).
This parameter is useless, unless the next parameter is 'print'.

The next two parameters are a little unusual and you can manage most often without them.

B<$effect> can have 3 values: B<'print'>, which is default, loads the page in an internal
table, adds it to the document and prints it to the current page. B<'add'>, loads the
page and adds it to the document. (Now you can "manually" manage the way you want to
print it to different pages within the document.) B<'load'> just loads the page in an 
internal table. (You can now take I<parts> of a page like fonts and objects and manage
them, without adding all the page to the document.)You don't get any defined 
internal name of the form, if you let this parameter be 'load'.B<tolerant> can be nothing or
something. If it is undefined, you will get an error if your program tries to load
a page which the system cannot really handle, if it e.g. consists of many streams.
If it is set to something, you have to test the first return value $internalName to
know if the function was successful. Look at the program 'reuseComponent_pl' for an 
example of usage.

In list context returns B<$intName, @BoundingBox, $numberOfImages>
In scalar context returns B<$internalName> of the form.

This function redefines a page to an "XObject" (the graphic parts), then the 
page can be reused and referred to as a unit. Unfortunately there is an important 
limitation here. "XObjects" can only have single streams. If the page consists
of many streams, you should concatenate them first. Adobe Acrobat can do that.
(If it is an important file, take a copy of it first. Sometimes the procedure fails.)
You open the file with Acrobat and choose the "Touch Up" tool and change anything
graphic in the page. You could e.g. remove 1 space and put it back. Then you
save the file. You could alternatively save the file as Postscript and redistill it with the
distiller or with Ghost script, but this is a little more risky. You might loose fonts
or something else. An other alternative could be to use prDoc() , but then you get all
the document, and you can only change the appearance of the page with the help of
JavaScript.

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');
   prForm('best.pdf');    # Takes page No 1
   prText(75, 790, 'Dear Mr Gates');
   # ...
   prPage();
   prMbox(0, 0, 900, 960);
   my @vec = prForm(   { file => 'EUSA.pdf',
                         adjust => 1 } );
   prPage();
   prMbox();
   prText(35, 760, 'This is the final page');

   # More text ..

   #################################################################
   # We want to put a miniature of EUSA.pdf, 35 pixels from the left
   # 85 pixels up, and in the format 250 X 200 pixels
   #################################################################

   my $xScale = 250 / ($vec[3] - $vec[1]);
   my $yScale = 200 / ($vec[4] - $vec[2]);
   if ($xScale < $yScale)
   {  $yScale = $xScale;
   }
   else
   {  $xScale = $yScale;
   }

   my $string = "q\n";
   $string   .= "$xScale 0 0 $yScale 35 85 cm\n"; 
   $string   .= "/$vec[0] Do\n";
   $string   .= "Q\n";
   prAdd($string);
   prEnd();

The first prForm(), in the code, is a simple and "normal" way of using the
the function. The second time it is used, the size of the imported page is
changed. It is adjusted to the media box which is current at that moment.
Also data about the form is taken, so you can control more in detail how it
will be displayed. Study the tutorial and the "PDF Reference Manual" for
more information about the "low level" manipulations at the end of the code.

=head3 prGetLogBuffer ()

returns a B<$buffer> of the log of the current page. (It could be used
e.g. to calculate a MD5-digest of what has been registered that far, instead of 
accumulating the single values) A log has to be active, see prLogDir() below

Look at "Using the template" and "Restoring a document from the log" in the
tutorial for examples of usage.

=head3 prGraphState ( $string )

Defines a graphic state parameter dictionary in the current file. It is a "low level"
function. Returns B<$internalName>. The B<$string> has to be a complete dictionary
with initial "<<" and terminating ">>". No syntactical checks are made.
Perhaps you will never have to use this function.

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');

   ###################################################
   # Draw a triangle with Gs0 (automatically defined)
   ###################################################

   my $str = "q\n";
   $str   .= "/Gs0 gs\n";
   $str   .= "150 700 m\n";
   $str   .= "225 800 l\n";
   $str   .= "300 700 l\n";
   $str   .= "150 700 l\n";
   $str   .= "S\n";
   $str   .= "Q\n";
   prAdd($str);

   ########################################################
   # Define a new graph. state param. dic. and draw a new
   # triangle further down 
   ########################################################

   $str = '<</Type/ExtGState/SA false/SM 0.02/TR2 /Default'
                      . '/LW 15/LJ 1/ML 1>>';
   my $gState = prGraphState($str);
   $str  = "q\n";
   $str .= "/$gState gs\n";
   $str .= "150 500 m\n";
   $str .= "225 600 l\n";
   $str .= "300 500 l\n";
   $str .= "150 500 l\n";
   $str .= "S\n";
   $str .= "Q\n";
   prAdd($str);
   
   prEnd();


=head3 prId ( $string )

An internal function. Don't bother about it. It is used e.g. when a document is
restored and an id has to be set, not calculated.

=head3 prIdType ( $string )

An internal function. Avoid using it. B<$string> could be "Rep" for replace or
"None" to avoid calculating an id.

Normally you don't use this function. Then an id is calculated with the help of
Digest::MD5::md5_hex and some data from the run.

=head3 prImage ( $pdfFile [, $pageNo, $imageNo, $effect] )

Reuses an image.

Alternatively you can call this function with the parameters in a hash
like this

    prImage( { file    => 'myFile.pdf',
               pageNo  => 10,
               imageNo => 2,
               effect  => 'print' } );

Returns in scalar context B<$internalName> As a list B<$internalName, $width, $height> 

Assumes that $pageNo and $imageNo are 1, if not specified. If $effect is given and
anything else then 'print', the image will be defined in the document,
but not shown at this moment.

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');
   prMoveTo(10, 400);
   prScale(0.9, 0.8);
   my @vec = prImage('best.pdf');
   prText(35, 760, 'This is some text');
   # ...

   prPage();
   my @vec2 = prImage( { file    => 'destiny.pdf',
                         pageNo  => 1,
                         imageNo => 1,
                         effect  => 'add' } );
   prText(25, 760, "There shouldn't be any image on this page");
   prPage();
   ########################################################
   #  Now we make both images so that they could fit into
   #  a box 300 X 300 pixels, and they are displayed
   ########################################################

   my $xScale = 300 / $vec[1];
   my $yScale = 300 / $vec[2];
   if ($xScale < $yScale)
   {  $yScale = $xScale;
   }
   else
   {  $xScale = $yScale;
   }
   $xScale *= $vec[1];
   $yScale *= $vec[2];
   prText(25, 800, 'This is the first image :');
   my $string = "q\n";
   $string   .= "$xScale 0 0 $yScale 25 450 cm\n";
   $string   .= "/$vec[0] Do\n";
   $string   .= "Q\n";
   prAdd($string);
   $xScale = 300 / $vec2[1];
   $yScale = 300 / $vec2[2];
   if ($xScale < $yScale)
   {  $yScale = $xScale;
   }
   else
   {  $xScale = $yScale;
   }
   $xScale *= $vec2[1];
   $yScale *= $vec2[2];
   prText(25, 400, 'This is the second image :');
   $string  = "q\n";   
   $string .= "$xScale 0 0 $yScale 25 25 cm\n";
   $string .= "/$vec2[0] Do\n";
   $string .= "Q\n";
   prAdd($string);
   prEnd();


On the first page an image is displayed in a simple way. While the second page
is processed, prImage(), loads an image, but it is not shown here. On the 3:rd
page, the two images are scaled and shown with "low level" directives. 

In the distribution there is an utility program, 'reuseComponent_pl', which displays
included images in a PDF-file and their "names".

=head3 prInit ( $string )

B<$string> can be any JavaScript code, but you can only refer to functions included
with prJs. The JavaScript interpreter will not know other functions in the document.
Often you can add new things, but you can't remove or change interactive fields,
because the interpreter hasn't come that far, when initiation is done.

See prJs() for an example

=head3  prInitVars([1])

To initiate global variables. If you run programs with PDF::Reuse as persistent
procedures, you probably need to initiate global variables. 
If you have '1' or anything as parameter, internal tables for forms, images, fonts
and interactive functions are B<not> initiated. The module "learns" offset and sizes of
used objects, and can process them faster, but at the same time the size of the 
program grows.

   use PDF::Reuse;
   use strict;
   prInitVars(1);

   $| = 1;
   print STDOUT "Content-Type: application/pdf \n\n";

   prFile();         # To send the document uncatalogued to STDOUT                

   prForm('best.pdf');
   prText(25, 790, 'Dear Mr. Anders Persson');
   # ...
   prEnd();

If you call this function without parameters all global variables, including the
internal tables, are initiated.


=head3 prJpeg ( $imageFile, $width, $height )

B<$imageFile> contains 1 single jpeg-image. B<$width> and B<$height>
also have to be specified. Returns the B<$internalName>

   use PDF::Reuse;
   use Image::Info qw(image_info dim);
   use strict;

   my $file = 'myImage.jpg';
   my $info = image_info($file);
   my ($width, $height) = dim($info);    # Get the dimensions

   prFile('myFile.pdf');
   my $intName = prJpeg("$file",         # Define the image 
                         $width,         # in the document
                         $height);

   my $str = "q\n";
   $str   .= "$width 0 0 $height 10 10 cm\n";
   $str   .= "/$intName Do\n";
   $str   .= "Q\n";
   prAdd($str);
   prEnd();

This is a little like an extra or reserve routine to add images to the document.
The most simple way is to use prImage()  

=head3 prJs ( $string|$fileName )

To add JavaScript to your new document. B<$string> has to consist only of
JavaScript functions: function a (..){ ... } function b (..) { ...} and so on
If B<$string> doesn't contain '{', B<$string> is interpreted as a filename.
In that case the file has to consist only of JavaScript functions.

   use PDF::Reuse;
   use strict;

   prFile('myFile.pdf');
   prJs('customerResponse.js');
   prInit('nameAddress(0, 100, 700);');
   prEnd();


=head3 prLog ( $string )

Adds whatever you want to the current log (a reference No, a commentary, a tag ?)
A log has to be active see prLogDir()

Look at "Using the template" and "Restoring the document from the log" in
the tutorial for an example.

=head3 prLogDir ( $directory )

Sets a directory for the logs and activates the logging. 
A little log file is created for each PDF-file. Normally it should be much, much
more compact then the PDF-file, and it should be possible to restore or verify 
a document with the help of it. (Of course you could compress or store the logs in a 
database to save even more space.) 

   use PDF::Reuse;
   use strict;

   prDocDir('C:/temp/doc');
   prLogDir('C:/run');

   prFile('myFile.pdf');
   prForm('best.pdf');
   prText(25, 790, 'Dear Mr. Anders Persson');
   # ...
   prEnd();

In this example a log file with the name 'myFile.pdf.dat' is created in the
directory 'C:\run'. If that directory doesn't exist, the system tries to create it.
(But, just as mkdir does, it only creates the last level in a directory tree.)

=head3 prMbox ( [$lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY] )

Defines the format (MediaBox) of the current page. 

If the function or the parameters are missing, they are set to 0, 0, 595, 842 pixels respectively.   

See prForm() for an example.

=head3 prMoveTo ( $x, $y )

Defines positions where to put e.g. next image

See prImage() for an example.

=head3 prPage ( [$noLog] )

Inserts a page break

Don't use the optional parameter, it is only used internally, not to clutter the log,
when automatic page breaks are made.

See prForm() for an example. 

=head3 prScale ( [$xSize, $ySize] )

Each of $xSize and $ySize are set to 1 if missing. You can use this function to
scale an image before showing it.

See prImage() for an example.

=head3 prText ( $x, $y, $string )

Puts B<$string> at position B<$x, $y>
Current font and font size is used. (If you use prAdd() before this function,
many other things could also influence the text.)

See prImage() for an example.  

=head3 prTouchUp ( [1] );

By default and after you have issued prTouchUp(1), you can change the document
with the TouchUp tool from within Acrobat.
If you want to switch off this possibility, you use prTouchUp() without any 
parameter.  Then the user shouldn't be able to change anything graphic by mistake.
He has to do something premeditated and perhaps with a little effort.
He could still save it as Postscript and redistill, or he could remove or add single pages. 
(Here is a strong reason why the log files, and perhaps also check sums, are needed.
It would be very difficult to forge a document unless the forger also has access to your
computer and knows how the check sums are calculated.)

B<Avoid to switch off the TouchUp tool for your templates.> It creates an
extra level within the PDF-documents, but use it for your final documents.
 

See "Using the template" in the tutorial for an example. 

(To encrypt your documents: use the batch utility within Acrobat)

=head3 prVers ( $versionNo )

An internal routine to check version of this module in case a document has to be
restored. 


=head1 SEE ALSO

To program with PDF-operators, look at "The PDF-reference Manual" which probably
is possible to download from http://partners.adobe.com/asn/developer/acrosdk/docs.html
Look especially at chapter 4 and 5, Graphics and Text, and the Operator summary.

Technical Note # 5186 contains the "Acrobat JavaScript Object Specification". I 
downloaded it from http://partners.adobe.com/asn/developer/technotes/acrobatpdf.html

If you are serious about producing PDF-files, you probably need Adobe Acrobat sooner
or later. It has a price tag. Other good programs are GhostScript and GSview. 
I got them via http://www.cs.wisc.edu/~ghost/index.html  Sometimes they can replace Acrobat.
A nice little detail is e.g. that GSview shows the x- and y-coordinats better then Acrobat. If you need to convert HTML-files to PDF, HTMLDOC is a possible tool. Download it from
http://www.easysw.com . A simple tool for vector graphics is Mayura Draw 2.04, download
it from http://www.mayura.com. It is free. I have used it to produce the graphic
OO-code in the tutorial. It produces postscript which the Acrobat Distiller (you get it together with Acrobat)
or Ghostscript can convert to PDF.(The commercial product, Mayura Draw 4.01 or something 
higher can produce PDF-files straight away)

If you want to produce bar codes, you need

   PDF::Reuse::Barcode

If you want to import jpeg-images, you might need

   Image::Info

To get definitions for e.g. colors, take them from

   PDF::API2::Util 

=head1 LIMITATIONS

Metadata, info and many other features of the PDF-format have not been
implemented in this module. 

Many things can be added afterwards, after creating the files. If you e.g. need
files to be encrypted, you can use a standard batch routine within Adobe Acrobat.   

=head1 TODO

I have been experimenting a little with a helper application for Netscape or
Internet Explorer and it is quite obvious that you could get very good performance
and high reliability if you transferred the logs and constructed the documents at
the target computer, instead of the transferring formatted documents.
The reasons are:

The size of a log is usually only a fraction of the formatted document. The logs
keep a time stamp for all source files, so you could have a simple cashing. It is
possible to put a time stamp on the log file and then you get a hierarchal structure.
When the system reads a log file it could quickly find out which source files are
missing. If it encounters the URL and time stamp of cashed log file, that would be
sufficient.  It would not be necessary to get it over the net.
You would minimize the number of conversations and you would also increase the
possibilities to complete a task even if the connections are bad.    

The cash could function as a secondary library for forms and JavaScripts.
When you work with HTML you are usually interested in the most recent version of
of a component. With PDF the emphasis is usually more on exactness, and PDF-documents
tend to be more stable. This strengthens the motive for a functioning cash.

(Also I think you could skip some holy rules from HTML-processing. E.g. if an 
international body has forms and JavaScripts for booking a hotel room, any 
affiliated hotel should have the right to use the common files, so they could be
used via the cash regardless of if you are booking a room in Agadir or Shanghai.
That would create libraries and rational reuse of code. I think security and
legal problems would be possible to handle.)

At the present time PDF cannot compete with HTML, but if you used the log files
and a simple cash, PDF would be just superior for repeated tasks.

=head1 AUTHOR

Lars Lundberg elkelund@worldonline.se

=head1 COPYRIGHT

Copyright (C) 2003 Lars Lundberg, Solidez HB. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 DISCLAIMER

You get this module free as it is, but nothing is guaranteed to work, whatever 
implicitly or explicitly stated in this document, and everything you do, 
you do at your own risk - I will not take responsibility 
for any damage, loss of money and/or health that may arise from the use of this module.

=cut

sub prBookmark
{   my $param = shift;
    if (! ref($param))
    {   $param = eval ($param);
    }
    if (! ref($param))
    {   return undef;
    }
    if (! $pos)
    {  errLog("No output file, you have to call prFile first");
    }
    if (ref($param) eq 'HASH')
    {   push @bookmarks, $param;
    }
    else
    {   push @bookmarks, (@$param);       
    }
    if ($runfil)
    {   local $Data::Dumper::Indent = 0;
        $param = Dumper($param);
        $param =~ s/^\$VAR1 = //;
        $param = prep($param);
        $log .= "Bookmark~$param\n";
    }
    return 1;
}

sub ordnaBookmarks
{   my ($first, $last, $me, $entry, $rad);
    $totalCount = 0;
    if (defined $objekt[$objNr])
    {  $objNr++;
    }
    $me = $objNr;
        
    my $number = $#bookmarks;
    for (my $i = 0; $i <= $number ; $i++)
    {   my %hash = %{$bookmarks[$i]};
        $objNr++;
        $hash{'this'} = $objNr;
        if ($i == 0)
        {   $first = $objNr;           
        }
        if ($i == $number)
        {   $last = $objNr;
        } 
        if ($i < $number)
        {  $hash{'next'} = $objNr + 1;
        }
        if ($i > 0)
        {  $hash{'previous'} = $objNr - 1;
        }
        $bookmarks[$i] = \%hash;
    } 
    
    for $entry (@bookmarks)
    {  my %hash = %{$entry};
       descend ($me, %hash);
    }

    $objekt[$me] = $pos;

    $rad = "$me 0 obj\n<<\n";
    $rad .= "/Type /Outlines\n";
    $rad .= "/Count $totalCount\n";
    if (defined $first)
    {  $rad .= "/First $first 0 R\n";
    }
    if (defined $last)
    {  $rad .= "/Last $last 0 R\n";
    }
    $rad .= ">>\nendobj\n";
    $pos += syswrite UTFIL, $rad;

    return $me;

}

sub descend
{   my ($parent, %entry) = @_;
    my ($first, $last, $count, $me, $rad, $jsObj);
    $totalCount++;
    $count = $totalCount;
    $me = $entry{'this'};
    if (exists $entry{'kids'})
    {   if (ref($entry{'kids'}) eq 'ARRAY')
        {   my @array = @{$entry{'kids'}};
            my $number = $#array;
            for (my $i = 0; $i <= $number ; $i++)
            {   $objNr++;
                $array[$i]->{'this'} = $objNr;
                if ($i == 0)
                {   $first = $objNr;           
                }
                if ($i == $number)
                {   $last = $objNr;
                } 

                if ($i < $number)
                {  $array[$i]->{'next'} = $objNr + 1;
                }
                if ($i > 0)
                {  $array[$i]->{'previous'} = $objNr - 1;
                }
            } 

            for my $element (@array)
            {   descend($me, %{$element})
            }
        }
        else                                          # a hash
        {   my %hash = %{$entry{'kids'}};
            $objNr++;
            $hash{'this'} = $objNr;
            $first        = $objNr;           
            $last         = $objNr;
            descend($me, %hash)
        }
     }     

     if (exists $entry{'act'})
     {   $objNr++;
         $jsObj = $objNr;
         my $code = $entry{'act'};
         if ($code =~ m/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*$/os)
         {  $code = "this.pageNum = $1; this.scroll\\($2, $3\\);";
         }
         else
         {  $code =~ s'\('\\('gso;
            $code =~ s'\)'\\)'gso;
         }
         $objekt[$jsObj] = $pos;
         $rad = "$jsObj 0 obj\n<<\n/S /JavaScript\n/JS ($code)\n>>\nendobj\n";
         $pos += syswrite UTFIL, $rad;
      } 

      $objekt[$me] = $pos;
      $rad = "$me 0 obj\n<<\n";
      if (exists $entry{'text'})
      {   $rad .= "/Title ($entry{'text'})\n";
      }
      $rad .= "/Parent $parent 0 R\n";
      if (defined $jsObj)
      {  $rad .= "/A $jsObj 0 R\n";
      }
      if (exists $entry{'previous'})
      {  $rad .= "/Prev $entry{'previous'} 0 R\n";
      }
      if (exists $entry{'next'})
      {  $rad .= "/Next $entry{'next'} 0 R\n";
      }
      if (defined $first)
      {  $rad .= "/First $first 0 R\n";
      }
      if (defined $last)
      {  $rad .= "/Last $last 0 R\n";
      }
      if ($count != $totalCount)
      {   $count = $totalCount - $count;
          $rad .= "/Count $count\n";
      }
      if (exists $entry{'color'})
      {   $rad .= "/C [$entry{'color'}]\n";
      }
      if (exists $entry{'style'})
      {   $rad .= "/F $entry{'style'}\n";
      }

      $rad .= ">>\nendobj\n";
      $pos += syswrite UTFIL, $rad;
}  


sub prInitVars
{   my $exit = shift;
    $genLowerX    = 0;
    $genLowerY    = 0;
    $genUpperX    = 595,
    $genUpperY    = 842;
    $fontSize     = 12;
    ($utfil, $utrad, $slutNod, $formRes, $formCont,
    $formRot, $del1, $del2, $obj, $nr,
    $vektor, $parent, $resOffset, $resLength, $infil, $seq, $imSeq, $rform, $robj,
    $page, $Annots, $Names, $AARoot, $AAPage, $sidObjNr,  
    $AcroForm, $interActive, $NamesSaved, $AARootSaved, $AAPageSaved, $root,
    $AcroFormSaved, $AnnotsSaved, $id, $ldir, $checkId, $formNr, $imageNr, 
    $filnamn, $interAktivSida, $taInterAkt, $type, $runfil, $checkCs,
    $confuseObj, $compress,$pos, $fontNr, $objNr, $xPos, $yPos,
    $defGState, $gSNr, $pattern, $shading, $colorSpace) = '';

    (@kids, @counts, @size, @formBox, @objekt, @parents, @aktuellFont, @skapa,
     @jsfiler, @inits, @bookmarks) = ();

    ( %old, %oldObject, %resurser,  %objRef, %nyaFunk, 
      %sidFont, %sidXObject, %sidExtGState, %font, %fields, %script,
      %initScript, %sidPattern, %sidShading, %sidColorSpace, %knownToFile,
      %processed) = ();

     $stream = '';
     $idTyp  = '';
     $ddir   = '';
     $log    = '';

     if ($exit)
     {  return 1;
     }
   
     ( %form, %image, %fontSource, %intAct) = ();

     return 1;
}

####################
# Behandla en bild
####################

sub prImage
{ my $param = shift;
  my ($infil, $sidnr, $bildnr, $effect);
  if (ref($param) eq 'HASH')
  {  $infil    = $param->{'file'};
     $sidnr    = $param->{'page'} || 1;
     $bildnr   = $param->{'imageNo'} || 1;
     $effect   = $param->{'effect'} || 'print';
  }
  else
  {  $infil   = $param;
     $sidnr   = shift || 1;
     $bildnr  = shift || 1;
     $effect  = shift || 'print';
  }

  my $refNr;
  my $inamn;
  my $bildIndex;
  my $xc;
  my $yc;
  my $xs;
  my $ys;
  $type = 'image';
  
  $bildIndex = $bildnr - 1;
  my $fSource = $infil . '_' . $sidnr;
  my $iSource = $fSource . '_' . $bildnr;
  if (! exists $image{$iSource})
  {  $imageNr++;
     $inamn = 'Im' . $imageNr;
     $knownToFile{'Im:' . $iSource} = $inamn;
     $image{$iSource}[imXPOS]   = $xPos;
     $image{$iSource}[imYPOS]   = $yPos;
     $image{$iSource}[imXSCALE] = $xScale;
     $image{$iSource}[imYSCALE] = $yScale;
     if (! exists $form{$fSource} )
     {  getPage($infil, $sidnr, '');
        $formNr++;
        my $namn = 'Fm' . $formNr;
        $knownToFile{$fSource} = $namn;          
     }
     my $in = $form{$fSource}[fIMAGES][$bildIndex];
     $image{$iSource}[imWIDTH]  = $form{$fSource}->[fOBJ]->{$in}->[oWIDTH];
     $image{$iSource}[imHEIGHT] = $form{$fSource}->[fOBJ]->{$in}->[oHEIGHT];
     $image{$iSource}[imIMAGENO] = $form{$fSource}[fIMAGES][$bildIndex];
  }
  if (exists $knownToFile{'Im:' . $iSource})
  {   $inamn = $knownToFile{'Im:' . $iSource};
  }
  else
  {   $imageNr++;
      $inamn = 'Im' . $imageNr;
      $knownToFile{'Im:' . $iSource} = $inamn;
  }
  if (! exists $objRef{$inamn})         
  {  $refNr = getImage($infil,  $sidnr, 
                       $bildnr, $image{$iSource}[imIMAGENO]);
     $objRef{$inamn} = $refNr;
  }
     
  my @iData = @{$image{$iSource}};

  if ($effect eq 'print')
  {  
     if (! defined  $defGState)
     { prDefaultGrState();}
  
     $stream .= "\n/Gs0 gs\n";

     if ($xPos)
     {  $xc = $xPos; }
     else
     {  $xc = $iData[imXPOS]; }

     if ($yPos)
     {  $yc = $yPos; }
     else
     {  $yc = $iData[imYPOS]; }

     if ($xScale == 1)
     {  $xs = $iData[imWIDTH] * $iData[imXSCALE]; }
     else
     {  $xs = $iData[imWIDTH] * $xScale; }

     if ($yScale == 1)
     {  $ys = $iData[imHEIGHT] * $iData[imYSCALE]; }
     else
     {  $ys = $iData[imHEIGHT] * $yScale; }

     $stream .= "\nq\n$xs 0 0 $ys $xc $yc cm\n";
     $stream .= "/$inamn Do\nQ\n";
     $sidXObject{$inamn} = $refNr;
     $sidExtGState{'Gs0'} = $defGState;
  }
  if ($runfil)
  {  $infil = prep($infil);
     $log .= "Image~$infil~$sidnr~$bildnr~$effect\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }

  if (wantarray)
  {   return ($inamn, $iData[imWIDTH], $iData[imHEIGHT]);
  }
  else
  {   return $inamn;
  }
}



sub prMbox
{  my $lx = shift || 0;
   my $ly = shift || 0;
   my $ux = shift || 595;
   my $uy = shift || 842;
   
   if ((defined $lx) && ($lx =~ m'^[\d\-\.]+$'o))
   { $genLowerX = $lx; }
   if ((defined $ly) && ($ly =~ m'^[\d\-\.]+$'o))
   { $genLowerY = $ly; } 
   if ((defined $ux) && ($ux =~ m'^[\d\-\.]+$'o))
   { $genUpperX = $ux; } 
   if ((defined $uy) && ($uy =~ m'^[\d\-\.]+$'o))
   { $genUpperY = $uy; } 
   if ($runfil)
   {  $log .= "Mbox~$lx~$ly~$ux~$uy\n";
   }
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
   1;
}



sub prField
{  my ($fieldName, $fieldValue) = @_;
   if ($interAktivSida)
   {  errLog("Too late, has already tried to INITIATE FIELDS within an interactive page");
   }
   elsif (! $pos)
   {  errLog("Too early INITIATE FIELDS, create a file first");
   }
   $fields{$fieldName} = $fieldValue;
   if ($runfil)
   {   $fieldName  = prep($fieldName);
       $fieldValue = prep($fieldValue);
       $log .= "Field~$fieldName~$fieldValue\n";
   } 
   1;
}
############################################################
sub prBar
{ my ($xPos, $yPos, $TxT) = @_; 
 
  $TxT   =~ tr/G/2/;
    
  my @fontSpar = @aktuellFont;
         
  findBarFont();
  
  my $Font = $aktuellFont[foINTNAMN];                # Namn i strömmen
  
  if (($xPos) && ($yPos))
  {  $stream .= "\nBT /$Font $fontSize Tf ";
     $stream .= "$xPos $yPos Td \($TxT\) Tj ET\n";
  }
  if ($runfil)
  {  $log .= "Bar~$xPos~$yPos~$TxT\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  @aktuellFont = @fontSpar;
  return $Font;
  
}

#####################################
# Definiera positionerna för en bild
#####################################

sub prMoveTo
{   $xPos = shift || 0;
    $yPos = shift || 0;
    if ($runfil)
    {  $log .= "MoveTo~$xPos~$yPos\n";
    }
    if (! $pos)
    {  errLog("No output file, you have to call prFile first");
    }
    1;

}

######################################
# Definiera skalan för en bild
###################################### 

sub prScale
{  $xScale = shift || 1;
   $yScale = shift || 1;
   if ($runfil)
   {  $log = "Scale~$xScale~$yScale\n";
   }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  1;
}

sub prExtract
{  my $name = shift;
   my $form = shift;
   my $page = shift || 1;
   if ($name =~ m'^/(\w+)'o)
   {  $name = $1;
   }
   my $fullName = "$name~$form~$page";
   if (exists $knownToFile{$fullName})
   {   return $knownToFile{$fullName};
   }
   else
   {   if ($runfil)
       {  $log = "Extract~$fullName\n";
       }
       if (! $pos)
       {  errLog("No output file, you have to call prFile first");
       }
   
       if (! exists $form{$form . '_' . $page})
       {  prForm($form, $page, undef, 'load', 1);
       }
       $name = extractName($form, $page, $name);
       if ($name)
       {  $knownToFile{$fullName} = $name;
       }
       return $name;
   }
}


########## Extrahera ett dokument ####################       
sub prDoc
{ $infil = shift;

  if ($stream)
  {  if ($stream =~ m'\S+'os)
     {  skrivSida();}
     else
     {  undef $stream; }
  }
   
  if (! $objekt[$objNr])         # Objektnr behöver inte reserveras här
  { $objNr--;
  }
  
  analysera();
  if (($Names) || ($AARoot) || ($AcroForm))
  { $NamesSaved     = $Names;
    $AARootSaved    = $AARoot;
    $AcroFormSaved  = $AcroForm;
    $interActive    = 1;
  }
  if ($runfil)
  {   $infil = prep($infil);
      $log .= "Doc~$infil\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
}

############# Ett interaktivt + grafiskt "formulär" ##########

sub prDocForm
{ my ($sidnr, $adjust, $effect, $action, $tolerant);
  my $param = shift;
  if (ref($param) eq 'HASH')
  {  $infil    = $param->{'file'};
     $sidnr    = $param->{'page'}     || 1;
     $adjust   = $param->{'adjust'}   || '';
     $effect   = $param->{'effect'}   || 'print';
     $tolerant = $param->{'tolerant'} || '';
  }
  else
  {  $infil   = $param;
     $sidnr   = shift  || 1;
     $adjust  = shift  || '';
     $effect  = shift  || 'print';
     $tolerant = shift || '';
  }
  my $namn;
  my $refNr;
  $type = 'docform';
  my $fSource = $infil . '_' . $sidnr; 

  if (! exists $form{$fSource})
  {  $formNr++;
     $namn = 'Fm' . $formNr;
     $knownToFile{$fSource} = $namn;
     if ($effect eq 'load')
     {  $action = 'load'
     }
     else
     {  $action = 'print'
     }     
     $refNr         = getPage($infil, $sidnr, $action);
     if ($refNr)
     {  $objRef{$namn} = $refNr; 
     }
     else
     {  if ($tolerant)
        {  undef $namn;
        }
        else
        {  my $mess = "$fSource can't be used as a form. Try e.g. to\n"
                    . "concatenate the streams of the page\n";
           errLog($mess);
        }
     }
  }
  else
  {  if (exists $knownToFile{$fSource})
     {   $namn = $knownToFile{$fSource};
     }
     else
     {  $formNr++;
        $namn = 'Fm' . $formNr;
        $knownToFile{$fSource} = $namn; 
     }
     if (exists $objRef{$namn})
     {  $refNr = $objRef{$namn};
     }
     else
     {  if (! $form{$fSource}[fVALID])
        {  my $mess = "$fSource can't be used as a form. Try e.g. to\n"
                    . "concatenate the streams of the page\n";
           if ($tolerant)
           {  cluck $mess;
              undef $namn;
           }
           else
           {  errLog($mess);
           }
        }
        elsif ($effect ne 'load')
        {  $refNr         =  byggForm($infil, $sidnr);
           $objRef{$namn} = $refNr;
        }
     }  
  }
  my @BBox = @{$form{$fSource}[fBBOX]};
  if (($effect eq 'print') && ($form{$fSource}[fVALID]))
  {   if ((! defined $interActive)
      && ($sidnr == 1)
      &&  (defined %{$intAct{$fSource}[0]}) )
      {  $interActive = $infil . ' ' . $sidnr;
         $interAktivSida = 1;
      }

      if (! defined $defGState)
      { prDefaultGrState();
      }
  
      if ($adjust)
      {   $stream .= "q\n";
          my ($m1, $m2, $m3, $m4, $m5, $m6) = calcMatrix(@BBox, $adjust);
          $stream .= "$m1 $m2 $m3 $m4 $m5 $m6 cm\n";
      
      }
      $stream .= "\n/Gs0 gs\n";   
      if ($refNr)
      {  $stream .= "/$namn Do\n";
         $sidXObject{$namn} = $refNr;
      }
      if ($adjust)
      {  $stream .= "Q\n";
      }
      $sidExtGState{'Gs0'} = $defGState;
  }
  if ($runfil)
  {   $infil = prep($infil); 
      $log .= "DocForm~$infil~$sidnr~$adjust~$effect~$tolerant\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  if (($effect ne 'print') && ($effect ne 'add'))
  {  undef $namn;
  }
  if (wantarray)
  {  my $images = 0;
     if (exists $form{$fSource}[fIMAGES])
     {  $images = scalar(@{$form{$fSource}[fIMAGES]});
     } 
     return ($namn, $BBox[0], $BBox[1], $BBox[2], 
             $BBox[3], $images);
  }
  else
  {  return $namn;
  }
}

sub calcMatrix
{  my ($left, $bottom, $right, $top, $fill) = @_;

   # $fill = uc($fill);
   my $scaleX = 1;
   my $skewX  = 0;
   my $skewY  = 0;
   my $scaleY = 1; 
   my $transX = 0;
   my $transY = 0;

   my $xDim = $genUpperX - $genLowerX;
   my $yDim = $genUpperY - $genLowerY;
   my $xNy = $right - $left;
   my $yNy = $top - $bottom;
   if ($xNy > $xDim)
   {  $scaleX = $xDim / $xNy; 
   }
   elsif (($xNy < $xDim) && ($fill)) 
   {  $scaleX = $xDim / $xNy;
   }
   
   if ($yNy > $yDim)
   {  $scaleY = $yDim / $yNy; 
   }
   elsif (($yNy < $yDim) && ($fill))
   {  $scaleY = $yDim / $yNy;
   }
   
   if ($scaleY < $scaleX)
   {  $scaleX = $scaleY; 
   }
   elsif ($scaleX < $scaleY)
   {  $scaleY = $scaleX; 
   }
    
   if ($left < 0)
   { $transX = $left; 
   }
   if ($bottom < 0)
   { $transY = $bottom; 
   }  
   return ($scaleX, $skewX, $skewY, $scaleY, $transX, $transY);
}

sub prJpeg
{  my ($iFile, $iWidth, $iHeight) = @_;
   my $iLangd;
   my $namnet;
   if (! $pos)                    # If no output is active, it is no use to continue
   {   return undef;
   }
   my $checkidOld = $checkId;
   ($iFile, $checkId) = findGet($iFile, $checkidOld);
   if ($iFile)
   {  $iLangd = (stat($iFile))[7];
      $imageNr++;
      $namnet = 'Im' . $imageNr;
      $objNr++;
      $objekt[$objNr] = $pos;
      open (BILDFIL, "<$iFile") || errLog("Couldn't open $iFile, $!, aborts");
      binmode BILDFIL;
      my $iStream;
      sysread BILDFIL, $iStream, $iLangd;
      $utrad = "$objNr 0 obj\n<</Type/XObject/Subtype/Image/Name/$namnet" .
                "/Width $iWidth /Height $iHeight /BitsPerComponent 8 /Filter/DCTDecode/ColorSpace/DeviceRGB"
                . "/Length $iLangd >>stream\n$iStream\nendstream\nendobj\n";
      $pos += syswrite UTFIL, $utrad;
      if ($runfil)
      {  $log .= "Cid~$checkId\n";
         $log .= "Jpeg~$iFile~$iWidth~$iHeight\n";
      }
      $objRef{$namnet} = $objNr;
   }
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
   undef $checkId;
   return $namnet;
}

sub checkContentStream
{  for (@_)
   {  if (my $value = $objRef{$_})
      {   my $typ = substr($_, 0, 2);
          if ($typ eq 'Ft')
          {  $sidFont{$_} = $value;
          }
          elsif ($typ eq 'Gs')
          {  $sidExtGState{$_} = $value;
          }
          elsif ($typ eq 'Pt')
          {  $sidPattern{$_} = $value;
          }
          elsif ($typ eq 'Sh')
          {  $sidShading{$_} = $value;
          }
          elsif ($typ eq 'Cs')
          {  $sidColorSpace{$_} = $value;
          }
          else
          {  $sidXObject{$_} = $value;
          }
      }
      elsif (($_ eq 'Gs0') && (! defined $defGState))
      {  my ($dummy, $oNr) = prDefaultGrState();
         $sidExtGState{'Gs0'} = $oNr;
      }
   }    
}

sub prGraphState
{  my $string = shift;
   $gSNr++;
   my $name = 'Gs' . $gSNr ;
   $objNr++;
   $objekt[$objNr] = $pos;
   $utrad = "$objNr 0 obj\n" . $string  . "\nendobj\n";
   $pos += syswrite UTFIL, $utrad;
   $objRef{$name} = $objNr;
   if ($runfil)
   {  $log .= "GraphStat~$string\n";
   }
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
   return $name;
}

##############################################################
# Streckkods fonten lokaliseras och objekten skrivs ev. ut
##############################################################

sub findBarFont()
{  my $Font = 'Bar';
   
   if (exists $font{$Font})              #  Objekt är redan definierat
   {  $aktuellFont[foEXTNAMN]   = $Font;
      $aktuellFont[foREFOBJ]    = $font{$Font}[foREFOBJ];
      $aktuellFont[foINTNAMN]   = $font{$Font}[foINTNAMN];
   }
   else
   {  $objNr++;
      $objekt[$objNr]  = $pos;
      my $encodObj     = $objNr;
      my $fontObjekt   = "$objNr 0 obj\n<< /Type /Encoding\n" .
                         '/Differences [48 /tomt /streck /lstreck]' . "\n>>\nendobj\n";
      $pos += syswrite UTFIL, $fontObjekt;
      my $charProcsObj = createCharProcs();
      $objNr++;
      $objekt[$objNr]  = $pos;
      $fontNr++;
      my $fontAbbr     = 'Ft' . $fontNr; 
      $fontObjekt      = "$objNr 0 obj\n<</Type/Font/Subtype/Type3\n" .
                         '/FontBBox [0 -250 75 2000]' . "\n" .
                         '/FontMatrix [0.001 0 0 0.001 0 0]' . "\n" .
                         "\/CharProcs $charProcsObj 0 R\n" .
                         "\/Encoding $encodObj 0 R\n" .
                         '/FirstChar 48' . "\n" .
                         '/LastChar 50' . "\n" .
                         '/Widths [75 75 75]' . "\n>>\nendobj\n";

      $font{$Font}[foINTNAMN]  = $fontAbbr; 
      $font{$Font}[foREFOBJ]   = $objNr;
      $objRef{$fontAbbr}       = $objNr;
      $objekt[$objNr]          = $pos;
      $aktuellFont[foEXTNAMN]  = $Font;
      $aktuellFont[foREFOBJ]   = $objNr;
      $aktuellFont[foINTNAMN]  = $fontAbbr;
      $pos += syswrite UTFIL, $fontObjekt;
   }
   if (! $pos)
   {  errLog("No output file, you have to call prFile first");
   }
      
   $sidFont{$aktuellFont[foINTNAMN]} = $aktuellFont[foREFOBJ];
}

sub createCharProcs()
{   #################################
    # Fonten (objektet) för 0 skapas
    #################################
    
    $objNr++;
    $objekt[$objNr]  = $pos;
    my $tomtObj = $objNr;
    my $str = "\n75 0 d0\n6 0 69 2000 re\n1.0 g\nf\n";
    my $strLength = length($str);
    $obj = "$objNr 0 obj\n<< /Length $strLength >>\nstream" .
           $str . "\nendstream\nendobj\n";
    $pos += syswrite UTFIL, $obj;

    #################################
    # Fonten (objektet) för 1 skapas
    #################################

    $objNr++;
    $objekt[$objNr]  = $pos;
    my $streckObj = $objNr;
    $str = "\n75 0 d0\n4 0 71 2000 re\n0.0 g\nf\n";
    $strLength = length($str);
    $obj = "$objNr 0 obj\n<< /Length $strLength >>\nstream" .
           $str . "\nendstream\nendobj\n";
    $pos += syswrite UTFIL, $obj;

    ###################################################
    # Fonten (objektet) för 2, ett långt streck skapas
    ###################################################

    $objNr++;
    $objekt[$objNr]  = $pos;
    my $lStreckObj = $objNr;
    $str = "\n75 0 d0\n4 -250 71 2250 re\n0.0 g\nf\n";
    $strLength = length($str);
    $obj = "$objNr 0 obj\n<< /Length $strLength >>\nstream" .
           $str . "\nendstream\nendobj\n";
    $pos += syswrite UTFIL, $obj;
   
    #####################################################
    # Objektet för "CharProcs" skapas
    #####################################################

    $objNr++;
    $objekt[$objNr]  = $pos;
    my $charProcsObj = $objNr;
    $obj = "$objNr 0 obj\n<</tomt $tomtObj 0 R\n/streck $streckObj 0 R\n" .
           "/lstreck $lStreckObj 0 R>>\nendobj\n";
    $pos += syswrite UTFIL, $obj;
    return $charProcsObj;
}



sub prCid
{   $checkId = shift;
    if ($runfil)
    {  $log .= "Cid~$checkId\n";
    }
    1;    
}
    
sub prIdType
{   $idTyp = shift;
    if ($runfil)
    {  $log .= "IdType~rep\n";
    }
    1;
}
         
    
sub prId
{   $id = shift;
    if ($runfil)
    {  $log .= "Id~$id\n";
    }
    if (! $pos)
    {  errLog("No output file, you have to call prFile first");
    }
    1;
}

sub prJs
{   my $filNamnIn = shift;
    my $filNamn;
    if ($filNamnIn !~ m'\{'os)
    {  my $checkIdOld = $checkId;
       ($filNamn, $checkId) = findGet($filNamnIn, $checkIdOld);
       if (($runfil) && ($checkId) && ($checkId ne $checkIdOld))
       {  $log .= "Cid~$checkId\n";
       }
       $checkId = '';
    }
    else
    {  $filNamn = $filNamnIn;
    }
    if ($runfil)
    {  my $filnamn = prep($filNamn);
       $log .= "Js~$filnamn\n";
    }
    if ($interAktivSida)
    {  errLog("Too late, has already tried to merge JAVA SCRIPTS within an interactive page");
    }
    elsif (! $pos)
    {  errLog("Too early for JAVA SCRIPTS, create a file first"); 
    }
    push @jsfiler, $filNamn;
    1;
}

sub prInit
{   my $initText = shift;
    my @fall = ($initText =~ m'([\w\d\_\$]+)\s*\(.*?\)'gs);
    for (@fall)
    {  if (! exists $initScript{$_})
       { $initScript{$_} = 0; 
       }
    }
    push @inits, $initText;
    if ($runfil)
    {   $initText = prep($initText);
        $log .= "Init~$initText\n";
    }
    if ($interAktivSida)
    {  errLog("Too late, has already tried to create INITIAL JAVA SCRIPTS within an interactive page");
    }
    elsif (! $pos)
    {  errLog("Too early for INITIAL JAVA SCRIPTS, create a file first");
    }
    1;
    
}

sub prVers
{   my $vers = shift;            
    ############################################################
    # Om programmet körs om så kontrolleras VERSION
    ############################################################
    if ($vers ne $VERSION)
    {  warn  "$vers \<\> $VERSION might give different results, if comparing two runs \n";
       return undef;
    }
    else
    {  return 1;
    }
}

sub prDocDir
{  $ddir = findDir(shift);
   1;
}

sub prLogDir
{  $ldir = findDir(shift);
   1;
}

sub prLog
{  my $mess = shift;
   if ($runfil)
   {  $mess  = prep($mess);
      $log .= "Log~$mess\n";
      return 1;
   }
   else
   {  errLog("You have to give a directory for the logfiles first : prLogDir <dir> , aborts");
   }
   
}

sub prGetLogBuffer
{  
   return $log;
}

sub findDir
{ my $dir = shift;
  if ($dir eq '.')
  { return undef; }
  if (! -e $dir)
   {  mkdir $dir || errLog("Couldn't create directory $dir, $!");
   }

  if ((-e $dir) && (-d $dir))
  {  if (substr($dir, length($dir), 1) eq '/')
     {  return $dir; }
     else
     {  return ($dir . '/');
     }
  }
  else
  { errLog("Error finding/creating directory $dir, $!");
  }
}

sub prTouchUp
{ $touchUp = shift;
  if ($runfil)
  {  $log .= "TouchUp~$touchUp\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  1;
}

sub prCompress
{ $compress = shift;
  if ($runfil)
  {  $log .= "Compress~$compress\n";
  }
  if (! $pos)
  {  errLog("No output file, you have to call prFile first");
  }
  1;

}

sub prep
{  my $indata = shift;
   $indata =~ s/[\n\r]+/ /sgo;
   $indata =~ s/~/<tilde>/sgo;
   return $indata;
} 

sub offSetSizes
{  my $bytes = shift;
   my ($j, $nr, $xref, $i, $antal, $inrad, $Root, $referens);
   my $buf = '';
   my $res = sysseek INFIL, -50, 2;
   if ($res)
   {  sysread INFIL, $buf, 100;
      if ($buf =~ m'Encrypt'o)
      {  errLog("The file $infil is encrypted, cannot be used, aborts");
      }
      if ($buf =~ m'\bstartxref\s+(\d+)'o)
      {  $xref = $1;
         while ($xref)
         {  $nr++;
            $oldObject{('xref' . "$nr")} = $xref;  # Offset för xref sparas 
            $xref += 5;
            $res = sysseek INFIL, $xref, 0;
            $xref  = 0;
            $inrad = '';
            $buf   = '';
            my $c;
            sysread INFIL, $c, 1;
            while ($c =~ m!\s!s)   
            {  sysread INFIL, $c, 1; }

            while ( (defined $c)
            &&   ($c ne "\n")
            &&   ($c ne "\r") )   
            {    $inrad .= $c;
                 sysread INFIL, $c, 1;
            }

            if ($inrad =~ m'^(\d+)\s+(\d+)'o)
            {   $i     = $1;
                $antal = $2;
            }
            
            # while ($c =~ m!\s!s)   
            # {  sysread INFIL, $c, 1; }
         
            # sysread INFIL, $inrad, 19;

            while ($antal)
            {   for (my $l = 1; $l <= $antal; $l++)
                {  sysread INFIL, $inrad, 20;
                   if ($inrad =~ m'^\s?(\d+) \d+ (\w)\s*'o)
                   {  if ($2 eq 'n')
                      {  if (! (exists $oldObject{$i}))
                         {  $oldObject{$i} = $1; }
                         else
                         {  $nr++;
                            $oldObject{'xref' . "$nr"} = $1;
                         }
                       } 
                    }
                    $i++;
                 }
                 undef $antal;
                 undef $inrad;
                 sysread INFIL, $c, 1;
                 while ($c =~ m!\s!s)   
                 {  sysread INFIL, $c, 1; }

                 while ( (defined $c)
                 &&   ($c ne "\n")
                 &&   ($c ne "\r") )   
                 {    $inrad .= $c;
                      sysread INFIL, $c, 1;
                 }
                 if ($inrad =~ m'^(\d+)\s+(\d+)'o)
                 {   $i     = $1;
                     $antal = $2;
                 }

            }
              
            while ($inrad)
            {   if ($buf =~ m'Encrypt'o)
                {  errLog("The file $infil is encrypted, cannot be used, aborts");
                }
                if ((! $Root) && ($buf =~ m'\/Root\s+(\d+) \d+ R'so))
                {  $Root = $1;
                   if ($xref)
                   { last; }
                }

                if ((! $xref) && ($buf =~ m'\/Prev\s+(\d+)\D'so))
                {  $xref = $1;
                   if ($Root)
                   { last; }
                }
                
                if ($buf =~ m'xref'so)
                {  last; }
                
                sysread INFIL, $inrad, 30;
                $buf .= $inrad;
             }
          }
      }
   }
   ($Root) || errLog("The Root object in $infil couldn't be found, aborting");

   ##############################################################
   # Objekten sorteras i fallande ordning (efter offset i filen)
   ##############################################################

   my @offset = sort { $oldObject{$b} <=> $oldObject{$a} } keys %oldObject;

   
   for (@offset)
   {   $bytes -= $oldObject{$_};
       if ($_ !~ m'xref'o)
       {  $size[$_] = $bytes;
       }
       $bytes = $oldObject{$_};
   } 
   return $Root;
}

          

############################################
# En definitionerna för en sida extraheras
############################################

sub getPage
{  my ($fil, $sidnr, $action)  = @_;

   my ($res, $i, $referens,$objNrSaved,$validStream,
       @underObjekt, @sidObj, $strPos, $startSida, $sidor, $filId);
   my $sidAcc = 0;

   $seq       = 0;
   $imSeq     = 0;
   @skapa     = ();   
   undef $formCont;
   undef $obj;
   undef $formRes;
   undef $resOffset;
   undef $resLength;
   undef $AcroForm;
   undef $Annots;
   undef $Names;
   undef $AARoot; 
   undef $AAPage;
   
   $objNrSaved = $objNr;   
   
   $infil = $fil;
   my $fSource = $infil . '_' . $sidnr;
   my $checkidOld = $checkId;
   ($fil, $checkId) = findGet($fil, $checkidOld);
   if (($ldir) && ($checkId) && ($checkId ne $checkidOld))
   {  $log .= "Cid~$checkId\n";
   }
   $form{$fSource}[fID] =  $checkId;
   $checkId = '';

   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }
   
   my @stati = stat($infil);
   open (INFIL, "<$infil") || errLog("Couldn't open $infil, $!");
   binmode INFIL;

   if ($infil ne $lastFile)
   {  $lastFile = $infil;
      %oldObject = ();
      @size      = ();   
      $root = offSetSizes($stati[7]);
   }

   #############
   # Hitta root
   #############           

   my $offSet = $oldObject{$root};
   my $bytes   = $size[$root];
   my $objektet;
   $res = sysseek INFIL, $offSet, 0;
   sysread INFIL, $objektet, $bytes;
   if ($sidnr == 1) 
   {  if ($objektet =~ m'/AcroForm(\s+\d+ \d+ R)'so)
      {  $AcroForm = $1;
      }
      if ($objektet =~ m'/Names\s+(\d+) \d+ R'so)
      {  $Names = $1;
      } 
      #################################################
      #  Finns ett dictionary för Additional Actions ?
      #################################################
      if ($objektet =~ m'/AA\s*\<\<\s*[^\>]+[^\>]+'so) # AA är ett dictionary
      {  my $k;
         my ($dummy, $obj) = split /\/AA/, $objektet;
         $obj =~ s/\<\</\#\<\</gs;
         $obj =~ s/\>\>/\>\>\#/gs;
         my @ord = split /\#/, $obj;
         for ($i = 0; $i <= $#ord; $i++)
         {   $AARoot .= $ord[$i];
             if ($ord[$i] =~ m'\S+'os)
             {  if ($ord[$i] =~ m'<<'os)
                {  $k++; }
                if ($ord[$i] =~ m'>>'os)
                {  $k--; }
                if ($k == 0)
                {  last; }
             } 
          }
      }
   }
     
   
   #
   # Hitta pages
   #
 
   if ($objektet =~ m'/Pages\s+(\d+) \d+ R'os)
   {  $offSet = $oldObject{$1};
      $bytes   = $size[$1];
      $res  = sysseek INFIL, $offSet, 0;
      sysread INFIL, $objektet, $bytes;
      if ($objektet =~ m'/Count\s+(\d+)'os)
      {  $sidor = $1;
         if ($sidnr <= $sidor)
         {  kolla($objektet, $offSet); 
         }
         if ($sidor > 1)
         {   undef $AcroForm;
             undef $Names;
             undef $AARoot;
             if ($type eq 'docform')
             {  errLog("prDocForm can only be used for single page documents - try prDoc or reformat $infil");
             }
         }
      }
   }
   else
   { errLog("Didn't find Pages in $infil - aborting"); }

   if ($objektet =~ m'/Kids\s*\[([^\]]+)'os)
   {  $vektor = $1; } 
   while ($vektor =~ m'(\d+) \d+ R'go)
   {   push @sidObj, $1;       
   }

   my $bryt1 = -20;                     # Hängslen
   my $bryt2 = -20;                     # Svångrem för att undvika oändliga loopar
   
   while ($sidAcc < $sidnr)
   {  @underObjekt = @sidObj;
      @sidObj     = ();
      $bryt1++;
      for my $uO (@underObjekt)
      {  $offSet = $oldObject{$uO};
         $bytes   = $size[$uO];
         $res  = sysseek INFIL, $offSet, 0;
         sysread INFIL, $objektet, $bytes;
         if ($objektet =~ m'/Count\s+(\d+)'os)
         {  if (($sidAcc + $1) < $sidnr)
            {  $sidAcc += $1; }
            else
            {  kolla($objektet, $offSet, $validStream);
               if ($objektet =~ m'/Kids\s*\[([^\]]+)'os)
               {  $vektor = $1; } 
               while ($vektor =~ m'(\d+) \d+ R'gso)
               {   push @sidObj, $1;  }
               last; 
            }
         }
         else
         {  $sidAcc++; }
         if ($sidAcc == $sidnr)
         {   $seq = $uO;
             last;  }
         $bryt2++;
      }
      if (($bryt1 > $sidnr) || ($bryt2 > $sidnr))   # Bryt oändliga loopar 
      {  last; } 
   }    

   $validStream = kolla($objektet, $offSet);
   $startSida = $seq;
       
   if ($sidor == 1)
   {  #################################################
      # Kontrollera Page-objektet för annoteringar
      #################################################

      if ($objektet =~ m'/Annots\s*([^\/]+)'so)
      {  $Annots = $1;
      } 
      #################################################
      #  Finns ett dictionary för Additional Actions ?
      #################################################
      if ($objektet =~ m'/AA\s*\<\<\s*[^\>]+[^\>]+'so)  # AA är ett dictionary. Hela kopieras
      {  my $k;
         my ($dummy, $obj) = split /\/AA/, $objektet;
         $obj =~ s/\<\</\#\<\</gs;
         $obj =~ s/\>\>/\>\>\#/gs;
         my @ord = split /\#/, $obj;
         for ($i = 0; $i <= $#ord; $i++)
         {   $AAPage .= $ord[$i];
             if ($ord[$i] =~ m'\S+'s)
             {  if ($ord[$i] =~ m'<<'s)
                {  $k++; }
                if ($ord[$i] =~ m'>>'s)
                {  $k--; }
                if ($k == 0)
                {  last; }
             } 
          }
      }
      
   }

   $rform = \$form{$fSource};
   @$$rform[fRESOFFSET]  = $resOffset;
   @$$rform[fRESLENGTH]  = $resLength;
   my @BBox;
   if (defined $formBox[0])
   {  $BBox[0] = $formBox[0]; }
   else
   {  $BBox[0] = $genLowerX; }
 
   if (defined $formBox[1])
   {  $BBox[1] = $formBox[1]; }
   else
   {  $BBox[1] = $genLowerY; }
 
   if (defined $formBox[2])
   {  $BBox[2] = $formBox[2]; }
   else
   {  $BBox[2] = $genUpperX; }
 
   if (defined $formBox[3])
   {  $BBox[3] = $formBox[3]; }
   else
   {  $BBox[3] = $genUpperY; }
 
   @{$form{$fSource}[fBBOX]} = @BBox;

   if ($formCont) 
   {   $seq = $formCont;
       sysseek INFIL, $oldObject{$formCont}, 0;
       sysread INFIL, $objektet, $size[$formCont];
       $robj  = \$$$rform[fOBJ]->{$seq};
   
       $$$robj[oFORM]    = 'Y';
       $form{$fSource}[fMAIN] = $seq;
       if ($objektet =~ m'^(\d+ \d+ obj\s*<<)(.+)(>>\s*stream)'so)
       {  $del1   = $2;
          $strPos = length($2) + length($3);
          $$$robj[oPOS]     = $oldObject{$formCont} + length($1);
          $$$robj[oSIZE]    = $size[$formCont]      - length($1);      
          $$$robj[oSTREAMP] = $strPos;
          $strPos += length($1);          
          my $nyDel1;
          $nyDel1 = '<</Type/XObject/Subtype/Form/FormType 1'; 
          $nyDel1 .= "/Resources $formRes" .
                     "/BBox \[ $BBox[0] $BBox[1] $BBox[2] $BBox[3]\]" .
                     # "/Matrix \[ 1 0 0 1 0 0 \]" .
                     $del1;
          if ($action eq 'print')
          {  $objNr++;
             $objekt[$objNr] = $pos;
          }
          $referens = $objNr;

          $res = ($nyDel1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs);
          if ($res)
          { $$$robj[oKIDS] = 1; }
          if ($action eq 'print')
          {   $utrad  = "$referens 0 obj\n" . "$nyDel1" . "\n>>\nstream";
              $del2   = substr($objektet, $strPos);
              $utrad .= $del2;
              $pos   += syswrite UTFIL, $utrad;
          }
          $form{$fSource}[fVALID] = $validStream;
      }
      else                              # Endast resurserna kan behandlas
      {   $formRes =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;  
      }
   }
   else                                # Endast resurserna kan behandlas
   {  $formRes =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
   } 
      
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  my $Font;
         my $gammal = $$key[0];
         my $ny     = $$key[1];
         sysseek INFIL, $oldObject{$gammal}, 0;
         sysread INFIL, $objektet, $size[$gammal];
         $robj  = \$$$rform[fOBJ]->{$gammal};
               
         if ($objektet =~ m'^(\d+ \d+ obj\s*<<)(.+)(>>\s*stream)'os)
         {  $del1 = $2;
            $strPos = length($2) + length($3);
            $$$robj[oPOS]     = $oldObject{$gammal} + length($1);
            $$$robj[oSIZE]    = $size[$gammal]      - length($1);
            $$$robj[oSTREAMP] = $strPos;
            $strPos += length($1);
 
            ######## En bild ########
            if ($del1 =~ m'/Subtype\s*/Image'so)
            {  $imSeq++;
               $$$robj[oIMAGE]   = 'Y';
               $$$robj[oIMAGENR] = $imSeq;
               push @{$$$rform[fIMAGES]}, $gammal;

               if ($del1 =~ m'/Width\s+(\d+)'os)
               {  $$$robj[oWIDTH] = $1; }
               if ($del1 =~ m'/Height\s+(\d+)'os)
               {  $$$robj[oHEIGHT] = $1; }
            }     
            $res = ($del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs);
            if ($res)
            { $$$robj[oKIDS] = 1; }            
            if ($action eq 'print')
            {   $objekt[$ny] = $pos;
                $utrad = "$ny 0 obj\n<<" . "$del1" . '>>stream';
                $del2   = substr($objektet, $strPos);
                $utrad .= $del2; 
            }
         }
         else
         {  if ($objektet =~ m'^(\d+ \d+ obj)'os)
            {  my $preLength = length($1);
               $$$robj[oPOS]   = $oldObject{$gammal}  + $preLength;
               $$$robj[oSIZE]  = $size[$gammal]       - $preLength;               
               $objektet = substr($objektet, $preLength);
               $res = ($objektet =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs);
               if ($res)
               { $$$robj[oKIDS] = 1; }
               if ($objektet =~ m'/Subtype\s*/Image'so)
               {  $imSeq++;
                  $$$robj[oIMAGENR] = $imSeq;
                  push @{$$$rform[fIMAGES]}, $gammal;
                  ###################################
                  # Sparar dimensionerna för bilden
                  ###################################
                  if ($del1 =~ m'/Width\s+(\d+)'os)
                  {  $$$robj[oWIDTH] = $1; }
      
                  if ($del1 =~ m'/Height\s+(\d+)'os)
                  {  $$$robj[oHEIGHT] = $1; }
               }
               elsif ($objektet =~ m'/BaseFont\s*/([^\s\/]+)'os)
               {  $Font = $1;
                  $$$robj[oTYPE]    = 'Font';
                  $$$robj[oNAME]    = $Font;
                  if (! exists $font{$Font})
                  {  $fontNr++;
                     $font{$Font}[foINTNAMN]          = 'Ft' . $fontNr;
                     $font{$Font}[foORIGINALNR]       = $gammal;
                     $fontSource{$Font}[foSOURCE]     = $fSource;
                     $fontSource{$Font}[foORIGINALNR] = $gammal;
                     if ($action eq 'print')
                     {   $font{$Font}[foREFOBJ]   = $ny;
                         $objRef{'Ft' . $fontNr} = $ny;
                     }
                  }   
               }
               
               if ($action eq 'print')
               {   $objekt[$ny] = $pos;
                   $utrad = "$ny 0 obj\n$objektet";
               }
            }
         }
         if ($action eq 'print')
         {   $pos += syswrite UTFIL, $utrad;
         }
       }
   }
   

   my $ref = \$form{$fSource};
   my @kids;
   my @nokids;  
   
   #################################################################
   # lägg upp vektorer över vilka objekt som har KIDS eller NOKIDS
   #################################################################   

   for my $key (keys %{$$$ref[fOBJ]})
   {   $robj  = \$$$ref[fOBJ]->{$key};
       if (! defined  $$$robj[oFORM])
       {   if (defined  $$$robj[oKIDS])
           {   push @kids, $key; }
           else
           {   push @nokids, $key; }
       }
   }
   if (scalar @kids)
   {  $form{$fSource}[fKIDS] = \@kids; 
   } 
   if (scalar @nokids)
   {  $form{$fSource}[fNOKIDS] = \@nokids; 
   } 
   
   if ($action ne 'print')
   {  $objNr = $objNrSaved;            # Restore objNo if nothing was printed
   }
   else
   {   %{$processed{$infil}} = %old;   # Save account of processed objects
   }
 
   $objNrSaved = $objNr;               # Save objNo

   if ($sidor == 1)
   {   @skapa = ();
       $old{$startSida} = $sidObjNr;
       my $ref = \$intAct{$fSource};
       @$$ref[iSTARTSIDA] = $startSida;
       if (defined $Names)
       {   @$$ref[iNAMES] = $Names;
           quickxform($Names);
       }
       if (defined $AcroForm)
       {   @$$ref[iACROFORM] = $AcroForm;
           $AcroForm =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
       }
       if (defined $AARoot)
       {   @$$ref[iAAROOT] = $AARoot;
           $AARoot =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
       }
       if (defined $AAPage)
       {   @$$ref[iAAPAGE] = $AAPage;
           $AAPage =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
       }
       if (defined $Annots)
       {   @$$ref[iANNOTS] = $Annots;
           $Annots =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
       }
      
      while (scalar @skapa)
      {  my @process = @skapa;
         @skapa = ();
         for my $key (@process)
         {  my $gammal = $$key[0];
            my $ny     = $$key[1];
            sysseek INFIL, $oldObject{$gammal}, 0;
            sysread INFIL, $objektet, $size[$gammal];
            
            $robj  = \$$$ref[fOBJ]->{$gammal};
            if ($objektet =~ m'^(\d+ \d+ obj\s*<<)(.+)(>>\s*stream)'os)
            {  $del1 = $2;
               $strPos = length($2) + length($3);
               $$$robj[oPOS]   = $oldObject{$gammal} + length($1);
               $$$robj[oSIZE]  = $size[$gammal]      - length($1);
               $$$robj[oSTREAMP] = $strPos;
               $strPos += length($1);
   
               $res = ($del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs);
               if ($res)
               { $$$robj[oKIDS] = 1; }  
            }
            else
            {  if ($objektet =~ m'^(\d+ \d+ obj)'os)
               {  my $preLength = length($1);
                  $$$robj[oPOS]   = $oldObject{$gammal}  + $preLength;
                  $$$robj[oSIZE]  = $size[$gammal]       - $preLength;
                  $objektet = substr($objektet, $preLength);
                  #if ($objektet =~ m'/BaseFont\s*/([^\s\/]+)'os)
                  #{  $Font = $1;
                  #   $$$robj[oTYPE]    = 'Font';
                  #   $$$robj[oNAME]    = $Font;
                  #   if (! exists $font{$Font})
                  #   {  $fontNr++;
                  #      $font{$Font}[foINTNAMN]  = 'Ft' . $fontNr;
                  #      $fontSource{$Font}       = $fSource;
                  #      $font{$Font}[fREFOBJ]    = $ny;
                  #      $objRef{'Ft' . $fontNr} = $ny;
                  #   }
                  #}   
                  
                  $res = ($objektet =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs);
                  if ($res)
                  { $$$robj[oKIDS] = 1; }
                }
             }
         }
      }
  }

  $objNr = $objNrSaved;
  %old = ();
   
  close INFIL;
  return $referens;
}  

##################################################
# Översätter ett gammalt objektnr till ett nytt
# och sparar en tabell med vad som skall skapas
##################################################

sub xform
{  if (exists $old{$1})
   {  $old{$1}; }
   else
   {  push @skapa, [$1, ++$objNr];
      $old{$1} = $objNr;                   
   } 
}  
  


sub kolla
{  #
   # Resurser
   #
   my $obj    = shift;
   my $offSet = shift;
   my $valid;
   
 
   if ($obj =~ m'MediaBox\s*\[\s*(\-*\d+)\s+(\-*\d+)\s+(\-*\d+)\s+(\-*\d+)'os)
   { $formBox[0] = $1;
     $formBox[1] = $2;
     $formBox[2] = $3;
     $formBox[3] = $4;
   }
  
   if ($obj =~ m'/Rotate\s+(\d+)'so)
   { $formRot = $1;
   }

   if ($obj =~ m'/Contents\s+(\d+)'so)
   { $formCont = $1;
     $valid    = 1;
   }
   
   if ($obj =~ m'^(.+/Resources)'so)
   {  $resOffset = $offSet + length($1);
      if ($obj =~ m'Resources(\s+\d+ \d+ R)'os)   # Hänvisning
      {  $formRes = $1; }
      else                 # Resurserna är ett dictionary. Hela kopieras
      {  my $dummy;
         my $i;
         my $k;
         undef $formRes;
         ($dummy, $obj) = split /\/Resources/, $obj;
         $obj =~ s/\<\</\#\<\</gs;
         $obj =~ s/\>\>/\>\>\#/gs;
         my @ord = split /\#/, $obj;
         for ($i = 0; $i <= $#ord; $i++)
         {   $formRes .= $ord[$i];
             if ($ord[$i] =~ m'\S+'s)
             {  if ($ord[$i] =~ m'<<'s)
                {  $k++; }
                if ($ord[$i] =~ m'>>'s)
                {  $k--; }
                if ($k == 0)
                {  last; }
             } 
          }
       }
    $resLength = length($formRes);
    }
    return $valid;

}

##############################
# Ett formulär (åter)skapas
##############################

sub byggForm
{  no warnings; 
   my ($infil, $sidnr) = @_;
   
   my $res;
   my $corr;
   my $nyDel1;
   undef $nr;
   @skapa = ();
   
   my $fSource = $infil . '_' . $sidnr;
   my @stati = stat($infil);

   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }

   if ($form{$fSource}[fID] != $stati[9])
   {    errLog("$stati[9] ne $form{$fSource}[fID] aborts");
   }
   if ($checkId) 
   {  if ($checkId ne $stati[9])
      {  my $mess =  "$checkId \<\> $stati[9] \n"
                  . "The Pdf-file $fSource has not the correct modification time. \n"
                  .  "The program is aborted";
         errLog($mess);
      }
      undef $checkId;
    }
    if ($ldir)
    {  $log .= "Cid~$stati[9]\n";
    }

   open (INFIL, "<$infil") || errLog("The file $infil couldn't be opened, aborting $!");
   binmode INFIL;

   ###########################################################
   # Data kopieras till två enklare strukturer för att slippa  
   # alltför komplicerade referenser
   ###########################################################

   my %oHash = %{$form{$fSource}[0]};                 # Objekt hash
  
   my @fData;

   push @fData, (0, @{$form{$fSource}}[1..9]);      # Data om formuläret   

   ####################################################
   # Objekt utan referenser  kopieras och skrivs
   ####################################################   

   for my $key (@{$fData[fNOKIDS]})
   {   if ((defined $old{$key}) && ($objekt[$old{$key}]))    # already processed
       {  next;
       }
       #########################################
       # Vektorn med data om ett objekt kopieras
       #########################################
       
       my @oD = @{$oHash{$key}};   

       if (! defined $old{$key})
       {  $old{$key} = ++$objNr;
       }
       $nr = $old{$key};
       
       $objekt[$nr] = $pos;
       
       sysseek INFIL, $oD[oPOS], 0;
       sysread INFIL, $del1, $oD[oSIZE];
       
       if (defined $oD[oSTREAMP])
       {  $utrad = "$nr 0 obj\n<<" . $del1; }
       else
       {  if ($oD[oTYPE] eq 'Font')
          {  my $Font = $oD[oNAME];
             if (! defined $font{$Font}[foINTNAMN])
             {  $fontNr++;
                $font{$Font}[foINTNAMN]  = 'Ft' . $fontNr;
                $font{$Font}[foREFOBJ]   = $nr;
                $objRef{'Ft' . $fontNr}  = $nr;
             }
          }   
          
          $utrad = "$nr 0 obj" . $del1;     
       }
       $pos += syswrite UTFIL, $utrad;     
   }

   #######################################################
   # Objekt med referenser kopieras, behandlas och skrivs
   #######################################################
   for my $key (@{$fData[fKIDS]})
   {   if ((defined $old{$key}) && ($objekt[$old{$key}]))  # already processed
       {  next;
       }
       my @oD = @{$oHash{$key}};
 
       if (! defined $old{$key})
       {  $old{$key} = ++$objNr;
       }
       $nr = $old{$key};
       
       $objekt[$nr] = $pos;
       
       if (defined $oD[oSTREAMP])
       {  sysseek INFIL, $oD[oPOS], 0;
          sysread INFIL, $del1, $oD[oSTREAMP];
          $del1 =~ s/\b(\d+) \d+ R\b/translate() . ' 0 R'/oegs;
          
          sysseek INFIL, ($oD[oPOS]  + $oD[oSTREAMP]), 0;
          sysread INFIL, $del2, ($oD[oSIZE] - $oD[oSTREAMP]);
           
          $utrad = "$nr 0 obj\n<<" . $del1 . $del2;
       }
       else
       {  sysseek INFIL, $oD[oPOS], 0;
          sysread INFIL, $del1, $oD[oSIZE];
          if (($oD[oTYPE]) && ($oD[oTYPE] eq 'Font'))
          {  my $Font = $oD[oNAME];
             if (! defined $font{$Font}[foINTNAMN])
             {  $fontNr++;
                $font{$Font}[foINTNAMN]  = 'Ft' . $fontNr;
                $font{$Font}[foREFOBJ]   = $nr;
                $objRef{'Ft' . $fontNr} = $nr;
             }
          }   

          $del1 =~ s/\b(\d+) \d+ R\b/translate() . ' 0 R'/oegs;
          $utrad = "$nr 0 obj" . $del1;
       }
       $pos += syswrite UTFIL, $utrad;                
   }

   #################################
   # Formulärobjektet behandlas 
   #################################
   
   my $key = $fData[fMAIN];
   if (! defined $key)
   {  return undef;
   }

   if (exists $old{$key})                      # already processed
   {  close INFIL;
      %{$processed{$infil}} = %old;
      return $old{$key}; 
   }

   my @oD = @{$oHash{$key}};

   $nr = ++$objNr;
   
   $objekt[$nr] = $pos;

   sysseek INFIL, $fData[fRESOFFSET], 0;
   sysread INFIL, $formRes, $fData[fRESLENGTH];
       
   if (defined $oD[oSTREAMP])
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSTREAMP];
  
      $nyDel1 = '<</Type/XObject/Subtype/Form/FormType 1'; 
      $nyDel1 .= "/Resources $formRes" .
                 '/BBox [' .
                 $fData[fBBOX][0]  . ' ' .
                 $fData[fBBOX][1]  . ' ' .
                 $fData[fBBOX][2]  . ' ' .
                 $fData[fBBOX][3]  . ' ]' .  
                 # "\]/Matrix \[ $sX 0 0 $sX $tX $tY \]" .
                 $del1;
      $nyDel1 =~ s/\b(\d+) \d+ R\b/translate() . ' 0 R'/oegs;

      sysseek INFIL, ($oD[oPOS]  + $oD[oSTREAMP]), 0;
      sysread INFIL, $del2, ($oD[oSIZE] - $oD[oSTREAMP]);

      $utrad = "$nr 0 obj" . $nyDel1 . $del2;
   }
   else
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSIZE];

      $nyDel1 = '<</Type/XObject/Subtype/Form/FormType 1'; 
      $nyDel1 .= "/Resources $formRes" .
                '/BBox [' .
                 "$fData[fBBOX][0] " .
                 "$fData[fBBOX][1] " .
                 "$fData[fBBOX][2] " .
                 "$fData[fBBOX][3] " . ']' .
                 # ']/Matrix [ 1 0 0 1 0 0 ]' .
                  $del1 . '>>';
      $nyDel1 =~ s/\b(\d+) \d+ R\b/translate() . ' 0 R'/oegs;
      $utrad = "$nr 0 obj" . $nyDel1;
   }
   $pos += syswrite UTFIL, $utrad;           
         
   close INFIL;

   %{$processed{$infil}} = %old;

   return $nr;   
   
}

##################
#  En bild läses
##################

sub getImage
{  my ($infil, $sidnr, $bildnr, $key) =  @_;
   if (! defined $key)
   {  errLog("Can't find image $bildnr on page $sidnr in file $infil, aborts");
   } 
   
   @skapa = ();
   undef $nr;
   my $res;
   my $corr;
   my $nyDel1;
   my $fSource = $infil . '_' . $sidnr;
   my $iSource = $fSource . '_' . $bildnr;
  
   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }

   my @stati = stat($infil);

   if ($form{$fSource}[fID] != $stati[9])
   {    errLog("$stati[9] ne $form{$fSource}[fID], modification time has changed, aborting");
   }

   if (exists $old{$key})
   {  return $old{$key}; 
   }

   open (INFIL, "<$infil") || errLog("The file $infil couldn't be opened, $!");
   binmode INFIL; 

   my %oHash = %{$form{$fSource}[0]};                 # Objekt hash
      
   #########################################################
   # En bild med referenser kopieras, behandlas och skrivs
   #########################################################

   $nr = ++$objNr;
   $old{$key} = $nr;
   
   $objekt[$nr] = $pos;

   my @oD = @{$oHash{$key}};
       
   $res = sysseek INFIL, $oD[oPOS], 0;
       
   if (defined $oD[oSTREAMP])
   {  $corr = sysread INFIL, $del1, $oD[oSTREAMP];
      $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
      $res = sysread INFIL, $del2, ($oD[oSIZE] - $corr); 
      $utrad = "$nr 0 obj\n<<" . $del1 . $del2;
   }
   else
   {  $res = sysread INFIL, $del1, $oD[oSIZE];
      $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
      $utrad = "$nr 0 obj" . $del1;
   }
   $pos += syswrite UTFIL, $utrad;
   ##################################
   #  Skriv ut underordnade objekt
   ################################## 
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  my $gammal = $$key[0];
         my $ny     = $$key[1];

         my @oD = @{$oHash{$gammal}};

         $res = sysseek INFIL, $oD[oPOS], 0;
         if (defined $oD[oSTREAMP])
         {  $corr = sysread INFIL, $del1, $oD[oSTREAMP];
            $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            $res = sysread INFIL, $del2, ($oD[oSIZE] - $corr); 
            $utrad = "$ny 0 obj\n<<" . $del1 . $del2;
         }
         else
         {  $res = sysread INFIL, $del1, $oD[oSIZE];
            $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            $utrad = "$ny 0 obj" . $del1;
         }
         $objekt[$ny] = $pos;
         $pos += syswrite UTFIL, $utrad;
      }
   }
        
   close INFIL;
   %{$processed{$infil}} = %old; 
   return $nr;   
   
}

##############################################################
#  Interaktiva funktioner knutna till ett formulär återskapas
##############################################################

sub AcroFormsEtc
{  my ($infil, $sidnr) =  @_;
   
   undef $Names;
   undef $AARoot;
   undef $Annots; 
   undef $AAPage; 
   undef $AcroForm;
   @skapa = ();
   
   my $res;
   my $corr;
   my $nyDel1;
   my $fSource = $infil . '_' . $sidnr;
   
   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }
  
   my @stati = stat($infil);
   if ($form{$fSource}[fID] != $stati[9])
   {    print "$stati[9] ne $form{$fSource}[fID]\n";
        errLog("Modification time for $fSource has changed, aborting");
   }
    
   open (INFIL, "<$infil") || errLog("The file $infil couldn't be opened, aborting $!");
   binmode INFIL;

   ###########################################################
   # Data kopieras till två enklare strukturer för att slippa  
   # komplicerade referenser
   ###########################################################

   my %oHash = %{$intAct{$fSource}[0]};         # Objekt hash
  
   my @iData;

   push @iData, (0, @{$intAct{$fSource}}[1..8]);      # Data om interaktivitet

   my $fdSidnr = $iData[iSTARTSIDA];
   $old{$fdSidnr} = $sidObjNr;

   if (($iData[iNAMES]) ||(scalar @jsfiler) || (scalar @inits) || (scalar %fields))
   {  $Names  = behandlaNames($iData[iNAMES], $fSource);
   }
   
   ##################################
   # Referenser behandlas och skrivs
   ##################################
         
   if (defined $iData[iACROFORM])
   {   $AcroForm = $iData[iACROFORM];
       $AcroForm =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;
   }
   if (defined $iData[iAAROOT])
   {  $AARoot = $iData[iAAROOT];
      $AARoot =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;
   }
   
   if (defined $iData[iAAPAGE])
   {   $AAPage = $iData[iAAPAGE];
       $AAPage =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;
   }
   if (defined $iData[iANNOTS])
   {   $Annots = $iData[iANNOTS];
       $Annots =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;
   }

   ##################################
   #  Skriv ut underordnade objekt
   ################################## 
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  
         my $gammal = $$key[0];
         my $ny     = $$key[1];
         
         my @oD = @{$oHash{$gammal}};

         $res = sysseek INFIL, $oD[oPOS], 0;
         if (defined $oD[oSTREAMP])
         {  $corr = sysread INFIL, $del1, $oD[oSTREAMP];
            if (defined  $oD[oKIDS]) 
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $res = sysread INFIL, $del2, ($oD[oSIZE] - $corr); 
            $utrad = "$ny 0 obj\n<<" . $del1 . $del2;
         }
         else
         {  $res = sysread INFIL, $del1, $oD[oSIZE];
            if (defined  $oD[oKIDS])
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $utrad = "$ny 0 obj" . $del1;
         }
         $objekt[$ny] = $pos;
         $pos += syswrite UTFIL, $utrad;
      }
   }
    
   close INFIL;
   %{$processed{$infil}} = %old;
   1;
} 

##############################
# Ett namnobjekt extraheras
##############################

sub extractName
{  my ($infil, $sidnr, $namn) = @_;
   
   my ($res, $del1, $resType, $key, $corr);
   my $del2 = '';
   undef $nr;
   @skapa = ();
   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }
  
   my $fSource = $infil . '_' . $sidnr;

   my @stati = stat($infil);

   if ($form{$fSource}[fID] != $stati[9])
   {    errLog("$stati[9] ne $form{$fSource}[fID] aborts");
   }
   if ($checkId) 
   {  if ($checkId ne $stati[9])
      {  my $mess =  "$checkId \<\> $stati[9] \n"
                  . "The Pdf-file $fSource has not the correct modification time. \n"
                  .  "The program is aborted";
         errLog($mess);
      }
      undef $checkId;
    }
    if ($ldir)
    {  $log .= "Cid~$stati[9]\n";
    }

   open (INFIL, "<$infil") || errLog("The file $infil couldn't be opened, aborting $!");
   binmode INFIL;

   ###########################################################
   # Data kopieras till två enklare strukturer för att slippa  
   # alltför komplicerade referenser
   ###########################################################

   my %oHash = %{$form{$fSource}[0]};                 # Objekt hash
  
   my @fData;

   push @fData, (0, @{$form{$fSource}}[1..9]);      # Data om formuläret   
   
   #################################
   # Resurserna läses
   #################################

   sysseek INFIL, $fData[fRESOFFSET], 0;
   sysread INFIL, $formRes, $fData[fRESLENGTH];
   
   if ($formRes !~ m'<<.*>>'os)                   # If not a directory, get it
   {   if ($formRes =~ m'\b(\d+) \d+ R'o)
       {  $key   = $1;
          my @oD = @{$oHash{$key}};
          $res = sysseek INFIL, $oD[oPOS], 0;
          $res = sysread INFIL, $formRes, $oD[oSIZE];
       }
       else
       {  return undef;
       }
   }
   undef $key;
   while ($formRes =~ m'\/(\w+)\s*\<\<([^>]+)\>\>'osg)
   {   $resType = $1;
       my $str  = $2;
       if ($str =~ m|$namn (\d+) \d+ R|s)
       {   $key = $1;
           last;
       }
   }
   if (! defined $key)                      # Try to expand the references
   {   my $str;
       while ($formRes =~ m'(\/\w+)\s+(\d+) \d+ R'ogs)
       { $str .= $1 . ' ';
         my $string;
         my @obD = @{$oHash{$2}};
         sysseek INFIL, $obD[oPOS], 0;
         sysread INFIL, $string, $obD[oSIZE];
         $str .= $string . ' ';
       }
       $formRes = $str;
       while ($formRes =~ m'\/(\w+)\s*\<\<([^>]+)\>\>'osg)
       {   $resType = $1;
           my $str  = $2;
           if ($str =~ m|$namn (\d+) \d+ R|s)
           {   $key = $1;
               last;
           }
       }
       return undef unless $key;
   }
    
   ########################################
   #  Read the top object of the hierarchy
   ########################################

   my @oD = @{$oHash{$key}};

   if (defined $oD[oSTREAMP])
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSTREAMP];
        
      sysseek INFIL, ($oD[oPOS]  + $oD[oSTREAMP]), 0;
      sysread INFIL, $del2, ($oD[oSIZE] - $oD[oSTREAMP]);
   }
   else
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSIZE];
   }
      
   $nr = quickxform($key);

   if ($resType eq 'Font')
   {  my ($Font, $extNamn);
      if ($del1 =~ m'/BaseFont\s*/([^\s\/]+)'os)
      {  $extNamn = $1;
         if (! exists $font{$extNamn})
         {  $fontNr++;
            $Font = 'Ft' . $fontNr;
            $font{$extNamn}[foINTNAMN]       = $Font;
            $font{$extNamn}[foORIGINALNR]    = $nr;
            $fontSource{$Font}[foSOURCE]     = $fSource;
            $fontSource{$Font}[foORIGINALNR] = $nr;            
         }
         $font{$extNamn}[foREFOBJ]   = $nr;
         $Font = $font{$extNamn}[foINTNAMN];
         $namn = $Font;
         $objRef{$Font}  = $nr;
      }
      else
      {  errLog("Inconsitency in $fSource, font $namn can't be found, aborting");
      }
   }
   elsif ($resType eq 'ColorSpace')
   {  $colorSpace++;
      $namn = 'Cs' . $colorSpace;
      $objRef{$namn} = $nr;
   }
   elsif ($resType eq 'Pattern')
   {  $pattern++;
      $namn = 'Pt' . $pattern;
      $objRef{$namn} = $nr;
   }
   elsif ($resType eq 'Shading')
   {  $shading++;
      $namn = 'Sh' . $shading;
      $objRef{$namn} = $nr;
   }
   elsif ($resType eq 'ExtGState')
   {  $gSNr++;
      $namn = 'Gs' . $gSNr;
      $objRef{$namn} = $nr;
   }
   elsif ($resType eq 'XObject')
   {  if ($oD[oTYPE] == 'Image')
      {  $namn = 'Im' . $oD[oIMAGENR];
      }
      else
      {  $formNr++;
         $namn = 'Fo' . $formNr;
      }
      
      $objRef{$namn} = $nr;
   }

   $del1 =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;

   $utrad = "$nr 0 obj" . $del1 . $del2;
   $objekt[$nr] = $pos;
   $pos += syswrite UTFIL, $utrad;

   ##################################
   #  Skriv ut underordnade objekt
   ##################################
 
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  my $gammal = $$key[0];
         my $ny     = $$key[1];
         
         my @oD = @{$oHash{$gammal}};

         $res = sysseek INFIL, $oD[oPOS], 0;
         if (defined $oD[oSTREAMP])
         {  $corr = sysread INFIL, $del1, $oD[oSTREAMP];
            if (defined  $oD[oKIDS]) 
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $res = sysread INFIL, $del2, ($oD[oSIZE] - $corr); 
            $utrad = "$ny 0 obj\n<<" . $del1 . $del2;
         }
         else
         {  $res = sysread INFIL, $del1, $oD[oSIZE];
            if (defined  $oD[oKIDS])
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $utrad = "$ny 0 obj" . $del1;
         }
         $objekt[$ny] = $pos;
         $pos += syswrite UTFIL, $utrad;
      }
   }
   close INFIL;
   %{$processed{$infil}} = %old;
   return $namn;   
   
}
 

########################
# Ett objekt extraheras
########################

sub extractObject
{  no warnings;
   my ($infil, $sidnr, $key, $typ) = @_;
   
   my ($res, $del1, $corr, $namn);
   my $del2 = '';
   undef $nr;
   @skapa = ();

   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }

   my $fSource = $infil . '_' . $sidnr;
   my @stati = stat($infil);

   if ($form{$fSource}[fID] != $stati[9])
   {    errLog("$stati[9] ne $form{$fSource}[fID] aborts");
   }
   if ($checkId) 
   {  if ($checkId ne $stati[9])
      {  my $mess =  "$checkId \<\> $stati[9] \n"
                  . "The Pdf-file $fSource has not the correct modification time. \n"
                  .  "The program is aborted";
         errLog($mess);
      }
      undef $checkId;
    }
    if ($ldir)
    {  $log .= "Cid~$stati[9]\n";
       my $indata = prep($infil);
       $log .= "Form~$indata~$sidnr~~load~1\n";
    }

   open (INFIL, "<$infil") || errLog("The file $infil couldn't be opened, aborting $!");
   binmode INFIL;

   ###########################################################
   # Data kopieras till två enklare strukturer för att slippa  
   # alltför komplicerade referenser
   ###########################################################

   my %oHash = %{$form{$fSource}[0]};                 # Objekt hash
  
   my @fData;

   push @fData, (0, @{$form{$fSource}}[1..9]);      # Data om formuläret   
      
      
   ########################################
   #  Read the top object of the hierarchy
   ########################################

   my @oD = @{$oHash{$key}};

   if (defined $oD[oSTREAMP])
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSTREAMP];
        
      sysseek INFIL, ($oD[oPOS]  + $oD[oSTREAMP]), 0;
      sysread INFIL, $del2, ($oD[oSIZE] - $oD[oSTREAMP]);
   }
   else
   {  sysseek INFIL, $oD[oPOS], 0;
      sysread INFIL, $del1, $oD[oSIZE];
   }
     
   if (exists $old{$key})
   {  $nr = $old{$key}; }
   else
   {  $old{$key} = ++$objNr;
      $nr = $objNr;
   }     
 
   if ($typ eq 'Font')
   {  my ($Font, $extNamn);
      if ($del1 =~ m'/BaseFont\s*/([^\s\/]+)'os)
      {  $extNamn = $1;
         $fontNr++;
         $Font = 'Ft' . $fontNr;
         $font{$extNamn}[foINTNAMN]    = $Font;
         $font{$extNamn}[foORIGINALNR] = $key;
         if ( ! defined $fontSource{$extNamn}[foSOURCE])
         {  $fontSource{$extNamn}[foSOURCE]     = $fSource;
            $fontSource{$extNamn}[foORIGINALNR] = $key;            
         }
         $font{$extNamn}[foREFOBJ]   = $nr;
         $Font = $font{$extNamn}[foINTNAMN];
         $namn = $Font;
         $objRef{$Font}  = $nr;
      }
      else
      {  errLog("Error in $fSource, $key is not a font, aborting");
      }
   }
   elsif ($typ eq 'ColorSpace')
   {  $colorSpace++;
      $namn = 'Cs' . $colorSpace;
      $objRef{$namn} = $nr;
   }
   elsif ($typ eq 'Pattern')
   {  $pattern++;
      $namn = 'Pt' . $pattern;
      $objRef{$namn} = $nr;
   }
   elsif ($typ eq 'Shading')
   {  $shading++;
      $namn = 'Sh' . $shading;
      $objRef{$namn} = $nr;
   }
   elsif ($typ eq 'ExtGState')
   {  $gSNr++;
      $namn = 'Gs' . $gSNr;
      $objRef{$namn} = $nr;
   }
   elsif ($typ eq 'XObject')
   {  if ($oD[oTYPE] == 'Image')
      {  $namn = 'Im' . $oD[oIMAGENR];
      }
      else
      {  $formNr++;
         $namn = 'Fo' . $formNr;
      }
      
      $objRef{$namn} = $nr;
   }

   $del1 =~ s/\b(\d+) \d+ R/xform() . ' 0 R'/oeg;

   $utrad = "$nr 0 obj" . $del1 . $del2;
   $objekt[$nr] = $pos;
   $pos += syswrite UTFIL, $utrad;

   ##################################
   #  Skriv ut underordnade objekt
   ##################################
 
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  my $gammal = $$key[0];
         my $ny     = $$key[1];
         
         my @oD = @{$oHash{$gammal}};

         $res = sysseek INFIL, $oD[oPOS], 0;
         if (defined $oD[oSTREAMP])
         {  $corr = sysread INFIL, $del1, $oD[oSTREAMP];
            if (defined  $oD[oKIDS]) 
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $res = sysread INFIL, $del2, ($oD[oSIZE] - $corr); 
            $utrad = "$ny 0 obj\n<<" . $del1 . $del2;
         }
         else
         {  $res = sysread INFIL, $del1, $oD[oSIZE];
            if (defined  $oD[oKIDS])
            {   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            }
            $utrad = "$ny 0 obj" . $del1;
         }
         $objekt[$ny] = $pos;
         $pos += syswrite UTFIL, $utrad;
      }
   }
   close INFIL;
   %{$processed{$infil}} = %old;
   return $namn;      
}
 

##########################################
# En fil analyseras och sidorna kopieras
##########################################

sub analysera
{  my ($i, $res, @underObjekt, @sidObj, 
       $strPos, $sidor, $filId, $Root);

   my $sidAcc = 0;
   @skapa     = ();
  
   if (exists $processed{$infil})
   {  %old = %{$processed{$infil}};
   }
   else
   {  %old = ();
   }
             
   undef $obj;
   undef $AcroForm;
   undef $Annots;
   undef $Names;
   undef $AARoot; 
   undef $AAPage;
   undef $taInterAkt;
   undef %script;
   
   my $checkIdOld = $checkId;
   ($infil, $checkId) = findGet($infil, $checkIdOld);
   if (($ldir) && ($checkId) && ($checkId ne $checkIdOld))
   {  $log .= "Cid~$checkId\n";
   }
   undef $checkId;
   my @stati = stat($infil);
   open (INFIL, "<$infil") || errLog("Couldn't open $infil,aborting.  $!");
   binmode INFIL;
  
   if ($lastFile ne $infil)
   {  %oldObject = ();
      @size      = ();
      $root      = offSetSizes($stati[7]);
      $lastFile  = $infil;
   }   
   #############
   # Hitta root
   #############           

   my $offSet = $oldObject{$root};
   my $bytes   = $size[$root];
   my $objektet;
   $res = sysseek INFIL, $offSet, 0;
   sysread INFIL, $objektet, $bytes;
   if (! $interActive)
   {  if ($objektet =~ m'/AcroForm(\s+\d+ \d+ R)'so)
      {  $AcroForm = $1;
      }      
      if ($objektet =~ m'/Names\s+(\d+) \d+ R'so)
      {  $Names = $1;
      }
      if ((scalar %fields) || (scalar @jsfiler) || (scalar @inits))
      {   $Names  = behandlaNames($Names);
      }
      elsif ($Names)
      {  $Names = quickxform($Names);
      }

      #################################################
      #  Finns ett dictionary för Additional Actions ?
      #################################################
      if ($objektet =~ m'/AA(\s+\d+ \d+ R)'os)   # Hänvisning
      {  $AARoot = $1; }
      elsif ($objektet =~ m'/AA\s*\<\<\s*[^\>]+[^\>]+'so) # AA är ett dictionary
      {  my $k;
         my ($dummy, $obj) = split /\/AA/, $objektet;
         $obj =~ s/\<\</\#\<\</gs;
         $obj =~ s/\>\>/\>\>\#/gs;
         my @ord = split /\#/, $obj;
         for ($i = 0; $i <= $#ord; $i++)
         {   $AARoot .= $ord[$i];
             if ($ord[$i] =~ m'\S+'os)
             {  if ($ord[$i] =~ m'<<'os)
                {  $k++; }
                if ($ord[$i] =~ m'>>'os)
                {  $k--; }
                if ($k == 0)
                {  last; }
             } 
          }
       }
       $taInterAkt = 1;   # Flagga att ta med interaktiva funktioner
   }
 
   
   #
   # Hitta pages
   #
 
   if ($objektet =~ m'/Pages\s+(\d+) \d+ R'os)
   {  $offSet = $oldObject{$1};
      $bytes   = $size[$1];
      $res  = sysseek INFIL, $offSet, 0;
      sysread INFIL, $objektet, $bytes;
      if ($objektet =~ m'/Count\s+(\d+)'os)
      {  $sidor = $1; }   
   }
   else
   { errLog("Didn't find pages "); }

   my @levels;
   my $li = -1;

   if ($objektet =~ m'/Kids\s*\[([^\]]+)'os)
   {  $vektor = $1;  
      while ($vektor =~ m'(\d+) \d+ R'go)
      {   push @sidObj, $1;       
      }
      $li++;
      $levels[$li] = \@sidObj;
   }

   while (($li > -1) && ($sidAcc < $sidor))
   {  if (scalar @{$levels[$li]})
      {   my $j = shift @{$levels[$li]};
          sysseek INFIL, $oldObject{$j}, 0;
          sysread INFIL, $objektet, $size[$j];
          
          if ($objektet =~ m'/Kids\s*\[([^\]]+)'os)
          {  $vektor = $1; 
             my @sObj; 
             while ($vektor =~ m'(\d+) \d+ R'go)
             {   push @sObj, $1;       
             }
             $li++;
             $levels[$li] = \@sObj;
          }
          else
          {  $sidAcc++;
             sidAnalys($j, $objektet);
          }
      }
      else
      {  $li--;
      }
   }
   
   if (defined $AcroForm)
   {  $AcroForm =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
   }
   if (defined $AARoot)
   {  $AARoot =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
   }
   
   while (scalar @skapa)
   {  my @process = @skapa;
      @skapa = ();
      for my $key (@process)
      {  my $gammal = $$key[0];
         my $ny     = $$key[1];
         sysseek INFIL, $oldObject{$gammal}, 0;
         sysread INFIL, $objektet, $size[$gammal];
         

         if ($objektet =~ m'^(\d+ \d+ obj\s*<<)(.+)(>>\s*stream)'os)
         {  $del1 = $2;
            $strPos = length($2) + length($3) + length($1);
            $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            $objekt[$ny] = $pos;
            $utrad = "$ny 0 obj\n<<" . "$del1" . '>>stream';
            $del2   = substr($objektet, $strPos);
            $utrad .= $del2; 

            $pos += syswrite UTFIL, $utrad;
         }
         
         elsif ($objektet =~ m'^(\d+ \d+ obj)'os)
         {  my $preLength = length($1);
            $objektet = substr($objektet, $preLength);
            $objektet =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
            $objekt[$ny] = $pos;
            $utrad = "$ny 0 obj\n$objektet";
            $pos += syswrite UTFIL, $utrad;
         }
      }
  }
  close INFIL;
  %{$processed{$infil}} = %old;
  1;
}

sub sidAnalys
{  my ($oNr, $obj) = @_;
   my ($ny, $strPos, $spar, $closeProc);

   if (! $parents[0])
   { $objNr++;
     $parents[0] = $objNr;
   }
   $parent = $parents[0];
   $objNr++;
   $ny = $objNr; 

   $old{$oNr} = $ny;
     
   if ($obj =~ m'/Parent\s+(\d+) \d+ R\b'os)
   {  $old{$1} = $parent;
   }
   
   undef $del2;

   if ($obj =~ m'^(\d+ \d+ obj\s*<<)(.+)(>>\s*stream)'os)
   {  $del1 = $2;
      $strPos = length($2) + length($3) + length($1);
      $del2   = substr($obj, $strPos);
   }
   elsif ($obj =~ m'^\d+ \d+ obj\s*<<(.+)>>\s*endobj'os)
   {  $del1 = $1;
   }
   if (! $taInterAkt)
   {  $del1 =~ s?\s*/Annots\s+\d+ \d+ R??os;
      $del1 =~ s?\s*/AA\s*<<[^>]*>>??os;
   }
   
   $del1 =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;

   $utrad = "$ny 0 obj\n<<$del1\n" . '>>';
   if (defined $del2)
   {   $utrad .= "stream\n$del2";
   }
   else
   {  $utrad .= "\nendobj\n";
   }

   $objekt[$ny] = $pos;
   $pos += syswrite UTFIL, $utrad;
     
   push @{$kids[0]}, $ny;
   $counts[0]++;
   if ($counts[0] > 9)
   {  ordnaNoder(8); 
   }
}  


sub translate
{ if (exists $old{$1})
  { $old{$1}; }
  else
  {  $old{$1} = ++$objNr;
  }     
}  

sub behandlaNames
{  my ($namnObj, $iForm) = @_;
   
   my ($low, $high, $antNod0, $entry, $nyttNr, $ny, 
       $fObjnr, $offSet, $bytes, $res, $key, $func, $corr);
   my (@nod0, @nodUpp, @kid, @soek, %nytt);
   
   my $objektet  = '';
   my $vektor    = '';   
   my $antal     = 0;
   my $antNodUpp = 0;
   if ($namnObj)
   {  if ($iForm)                                # Läsning via interntabell
      {   my %oHash = %{$intAct{$iForm}[0]};     # Objekt hash
                    
          my @oD = @{$oHash{$namnObj}};

          $res = sysseek INFIL, $oD[oPOS], 0;
          $res = sysread INFIL, $objektet, $oD[oSIZE];
          if ($objektet =~ m'<<(.+)>>'ogs)
          { $objektet = $1; }
          if ($objektet =~ s'/JavaScript\s+(\d+) \d+ R''os)
          {  my $byt = $1; 
             push @kid, $1;
             while (scalar @kid)
             {  @soek = @kid;
                @kid = ();
                for my $sObj (@soek)
                {  @oD = @{$oHash{$sObj}};
                   $res = sysseek INFIL, $oD[oPOS], 0;
                   $res = sysread INFIL, $obj, $oD[oSIZE];
                   if ($obj =~ m'/Kids\s*\[([^]]+)'ogs)
                   {  $vektor = $1;
                   }
                   while ($vektor =~ m'\b(\d+) \d+ R\b'ogs)
                   {  push @kid, $1;
                   }
                   $vektor = '';
                   if ($obj =~ m'/Names\s*\[([^]]+)'ogs)
                   {   $vektor = $1;
                   }
                   while ($vektor =~ m'\(([^\)]+)\)\s*(\d+) \d R'gos)
                   {   $script{$1} = $2;                
                   }
                }
             }
          }
      }
      else                                #  Läsning av ett "doc"
      {  $offSet  = $oldObject{$namnObj};
         $bytes   = $size[$namnObj];
         $res     = sysseek INFIL, $offSet, 0;
         sysread INFIL, $objektet, $bytes;
   
         if ($objektet =~ m'<<(.+)>>'ogs)
         {  $objektet = $1; }
         if ($objektet =~ s'/JavaScript\s+(\d+) \d+ R''os)
         {  my $byt = $1; 
            push @kid, $1;
            while (scalar @kid)
            {  @soek = @kid;
               @kid = ();
               for my $sObj (@soek)
               {  $offSet  = $oldObject{$sObj};
                  $bytes   = $size[$sObj];
                  $res     = sysseek INFIL, $offSet, 0;
                  sysread INFIL, $obj, $bytes;
                  if ($obj =~ m'/Kids\s*\[([^]]+)'ogs)
                  {  $vektor = $1;
                  }
                  while ($vektor =~ m'\b(\d+) \d+ R\b'ogs)
                  {  push @kid, $1;
                  }
                  undef $vektor;
                  if ($obj =~ m'/Names\s*\[([^]]+)'ogs)
                  {  $vektor = $1;
                  }
                  while ($vektor =~ m'\(([^\)]+)\)\s*(\d+) \d R'gos)
                  {   $script{$1} = $2;                
                  }
               }        
             }
          }
      } 
   }
   for my $filnamn (@jsfiler)
   {   inkludera($filnamn);
   }
   my @nya = (keys %nyaFunk);
   while (scalar @nya)
   {   my @behandla = @nya;
       @nya = ();
       for $key (@behandla)
       {   if (exists $initScript{$key})
           {  if (exists $nyaFunk{$key})
              {   $initScript{$key} = $nyaFunk{$key};
              }
              if (exists $script{$key})   # företräde för nya funktioner !
              {   delete $script{$key};    # gammalt script m samma namn plockas bort
              } 
              my @fall = ($initScript{$key} =~ m'([\w\d\_\$]+)\s*\([\w\s\,\d\.]*\)'ogs);
              for (@fall)
              {   if (($_ ne $key) && (exists $nyaFunk{$_}))
                  {  $initScript{$_} = $nyaFunk{$_}; 
                     push @nya, $_; 
                  }
              }
           }
       }
   }
   while  (($key, $func) = each %nyaFunk)
   {  $fObjnr = skrivJS($func);
      $script{$key} = $fObjnr;
      $nytt{$key}   = $fObjnr;
   }
     
   if (scalar %fields)
   {  $fObjnr = defLadda();
      push @inits, 'Ladda();';
      $script{'Ladda'} = $fObjnr;
      $nytt{'Ladda'} = $fObjnr;
   }

   if (scalar @inits)
   {  $fObjnr = defInit();
      $script{'Init'} = $fObjnr;
      $nytt{'Init'} = $fObjnr;
   }
   undef @jsfiler;
 
   for my $key (sort (keys %script))
   {  if (! defined $low)
      {  $objNr++;
         $ny = $objNr;     
         $objekt[$ny] = $pos;
         $obj = "$ny 0 obj\n";
         $low  = $key;
         $obj .= '<< /Names [';
      }
      $high = $key;
      $obj .= '(' . "$key" . ')';
      if (! exists $nytt{$key})
      {  $nyttNr = quickxform($script{$key});
      }
      else
      {  $nyttNr = $script{$key};
      }
      $obj .= "$nyttNr 0 R\n";      
      $antal++;
      if ($antal > 9)
      {   $obj .= ' ]/Limits [(' . "$low" . ')(' . "$high" . ')] >>' . "\nendobj\n";
          $pos += syswrite UTFIL, $obj;
          push @nod0, \[$ny, $low, $high];
          $antNod0++; 
          undef $low;
          $antal = 0; 
      }
   }
   if ($antal)
   {   $obj .= ']/Limits [(' . $low . ')(' . $high . ')]>>' . "\nendobj\n";
       $pos += syswrite UTFIL, $obj;
       push @nod0, \[$ny, $low, $high];
       $antNod0++;
   }
   $antal = 0;

   while (scalar @nod0)
   {   for $entry (@nod0)
       {   if ($antal == 0)
           {   $objNr++;     
               $objekt[$objNr] = $pos;
               $obj = "$objNr 0 obj\n";
               $low  = $$entry->[1];
               $obj .= '<</Kids [';
           }
           $high = $$entry->[2];
           $obj .= " $$entry->[0] 0 R";
           $antal++;
           if ($antal > 9)
           {   $obj .= ']/Limits [(' . $low . ')(' . $high . ')]>>' . "\nendobj\n";
               $pos += syswrite UTFIL, $obj;
               push @nodUpp, \[$objNr, $low, $high];
               $antNodUpp++; 
               undef $low;
               $antal = 0; 
           } 
       }
       if ($antal > 0)
       {   if ($antNodUpp == 0)     # inget i noderna över
           {   $obj .= ']>>' . "\nendobj\n";
               $pos += syswrite UTFIL, $obj;
           }
           else
           {   $obj .= ']/Limits [(' . "$low" . ')(' . "$high" . ')]>>' . "\nendobj\n";
               $pos += syswrite UTFIL, $obj;
               push @nodUpp, \[$objNr, $low, $high];
               $antNodUpp++; 
               undef $low;
               $antal = 0; 
           }
       }
       @nod0    = @nodUpp;
       $antNod0 = $antNodUpp;
       undef @nodUpp;
       $antNodUpp = 0;
   }
      
  
   $ny = $objNr;
   $objektet =~ s|\s*/JavaScript\s*\d+ \d+ R||os;
   $objektet =~ s/\b(\d+) \d+ R\b/xform() . ' 0 R'/oegs;
   if (scalar %script)
   {  $objektet .= "\n/JavaScript $ny 0 R\n";
   }
   $objNr++;
   $ny = $objNr;
   $objekt[$ny] = $pos;
   $objektet = "$ny 0 obj\n<<" . $objektet . ">>\nendobj\n";
   $pos += syswrite UTFIL, $objektet;
   return $ny;
}


sub quickxform
{  my $inNr = shift;
   if (exists $old{$inNr})
   {  $old{$inNr}; }
   else
   {  push @skapa, [$inNr, ++$objNr];
      $old{$inNr} = $objNr;                   
   } 
} 


sub skrivKedja
{  my $spar;
   my $func;
   
   $objNr++;
   $objekt[$objNr] = $pos;
     
   my $obj = "$objNr 0 obj\n<<\n/S /JavaScript\n/JS " . '('; 
   for $func (values %initScript)
   {   $func =~ s'\('\\('gso;
       $func =~ s'\)'\\)'gso;
       $obj .= $func . "\n";
   }
   $obj .='function Init\(\)\r{\r';
   $obj .= 'if \(typeof this.info.ModDate == "undefined"\)\r{ return true; }\r'; 
   my $act;
   for $act  (@inits)
   {  $obj .= "\n" . $act;
   }
   $obj .= '}\r Init\(\); ';

   $obj .= ')';
   $spar = $objNr;
   $obj .= "\n>>\nendobj\n";
   $pos += syswrite UTFIL, $obj;
   undef @inits;
   undef %initScript;
   return $spar;
}



sub skrivJS
{  my $kod = shift;
   $objNr++;
   $objekt[$objNr] = $pos;
   $kod =~ s'\('\\('gso;
   $kod =~ s'\)'\\)'gso;
   $obj = "$objNr 0 obj\n<<\n/S /JavaScript\n/JS " . '(' . $kod . ')';
   $obj .= "\n>>\nendobj\n";
   $pos += syswrite UTFIL, $obj;           
   return $objNr;
}

sub inkludera
{   my $jsfil = shift;
    my $fil;
    if ($jsfil !~ m'\{'os)
    {   open (JSFIL, "<$jsfil") || return;
        while (<JSFIL>)
        { $fil .= $_;}

        close JSFIL;
    }
    else
    {  $fil = $jsfil;
    }
    $fil =~ s|function\s+([\w\_\d\$]+)\s*\(|"zXyZcUt function $1 ("|sge;
    my @funcs = split/zXyZcUt /, $fil;
    for my $kod (@funcs)
    {   if ($kod =~ m'^function ([\w\_\d\$]+)'os)
        {   $nyaFunk{$1} = $kod;
        }
    }   
}


sub defLadda
{  $objNr++;
   my $ny = $objNr;
   $objekt[$ny] = $pos;
   $obj = "$ny 0 obj\n<<\n/S /JavaScript\n/JS " . '(function Ladda\(\)\r';
   my $varde = 'function Ladda()\r{\r';
   $obj .= '{\r';
   my $key;
   for $key  (keys %fields)
   {  $varde .= 'this.getField("'; 
      $varde .= $key;
      $varde .= '")'; 
      $varde .= '.value = "'; 
      $varde .= $fields{$key}; 
      $varde .= '";\r';
      $obj .= 'this.getField\("'; 
      $obj .= $key;
      $obj .= '"\)'; 
      $obj .= '.value = "'; 
      $obj .= $fields{$key}; 
      $obj .= '";\r';
   }
   $varde .= '}\r ';
   $obj .= '}\r )';
   $obj .= "\n>>\nendobj\n";
   $pos += syswrite UTFIL, $obj;
   $initScript{'Ladda'} = $varde;           
   return $ny;
}

sub defInit
{  $objNr++;
   my $ny = $objNr;
   $objekt[$ny] = $pos;
   $obj = "$ny 0 obj\n<<\n/S /JavaScript\n/JS " . '(function Init\(\)\r{\r';
   $obj .= 'if \(typeof this.info.ModDate == "undefined"\)\r{ return true; }\r'; 
   my $act;
   for $act  (@inits)
   {  $act =~ s'\('\\('gso;
      $act =~ s'\)'\\)'gso;
      $obj .= "\n" . $act;
   }
   $obj .= '}\r)';
   $obj .= "\n>>\nendobj\n";
   $pos += syswrite UTFIL, $obj;           
   return $ny;
}



sub errLog
{   no strict 'refs';
    my $mess = shift;
    my $endMess  = " $mess \n More information might be found in"; 
    if ($runfil)
    {   $log .= "Log~Err: $mess\n";
        $endMess .= "\n   $runfil";
        if (! $pos)
        {  $log .= "Log~Err: No pdf-file has been initiated\n";
        }
        elsif ($pos > 15000000)
        {  $log .= "Log~Err: Current pdf-file is very big: $pos bytes, will not try to finnish it\n"; 
        }
        else
        {  $log .= "Log~Err: Will try to finnish current pdf-file\n";
           $endMess .= "\n   $utfil";
        }
    }
    my $errLog = 'error.log';
    my $now = localtime();
    my $lpos = $pos || 'undef';
    my $lobjNr = $objNr || 'undef';
    my $lutfil = $utfil || 'undef';
    my $linfil = $infil || 'undef';
    my $lrunfil = $runfil || 'undef'; 
    open (ERRLOG, ">$errLog") || croak "$mess can't open an error logg, $!";
    print ERRLOG "\n$mess\n\n";
    print ERRLOG Carp::longmess("The error occured when executing:\n");
    print ERRLOG "\nSituation when the error occured\n\n";
    print ERRLOG "   Bytes written to the current pdf-file,    pos    = $lpos\n";
    print ERRLOG "   Object processed, not necessarily written objNr  = $lobjNr\n";
    print ERRLOG "   Current pdf-file,                         utfil  = $lutfil\n";
    print ERRLOG "   Last input file,                          infil  = $linfil\n";
    print ERRLOG "   File logging the run,                     runfil = $lrunfil\n";
    print ERRLOG "   Local time                                       = $now\n"; 
    print ERRLOG "\n\n";    
    close ERRLOG;
    $endMess .= "\n   $errLog";
    if (($pos) && ($pos < 15000000))
    {  prEnd();
    }
    print STDERR Carp::shortmess("An error occured \n");
    croak "$endMess\n";      
}
