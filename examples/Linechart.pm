package Linechart;
use PDF::Reuse;
use autouse 'Math::Trig' => qw(tan);
use strict;

sub new
{  my $name  = shift;
   my $class = ref($name) || $name;
   my $this  = {};
   bless $this, $name;
   $this->{'values'} = [ ];
   return $this;
}

sub outlines
{  my $self = shift;
   my %param = @_;
   for (keys %param)
   {   $self->{$_} = $param{$_}; 
   }
   my ($str, $xSize, $ySize);
   $self->{'xSize'} = 1 unless ($self->{'xSize'} != 0);
   $self->{'ySize'} = 1 unless ($self->{'ySize'} != 0);
   $self->{'size'}  = 1 unless ($self->{'size'}  != 0);
   $xSize = $self->{'xSize'} * $self->{'size'};
   $ySize = $self->{'ySize'} * $self->{'size'};
   $self->{'lowerX'} = 10 unless ($self->{'lowerX'} != 0);
   $self->{'lowerY'} = 10 unless ($self->{'lowerY'} != 0);   
   $self->{'upperX'} = 450 unless ($self->{'upperX'} != 0);
   $self->{'upperY'} = 450 unless ($self->{'upperY'} != 0);
   $self->{'steps'}  = 10  unless ($self->{'steps'} != 0);
   return $self;
}

sub values
{  my $self  = shift;
   my @value = @_;
   my $maxNum;
   for (@value)
   {  if ($_ > $self->{'max'})
      {  $self->{'max'} = $_;
      }
      if (($_ < $self->{'min'}) || (! exists $self->{'min'}))
      {  $self->{'min'} = $_;
      }
      $maxNum++;
   }
   if ($maxNum > $self->{'maxNum'})
   {  $self->{'maxNum'} = $maxNum;
   }
   $self->{'num'}++;
   push @{$self->{'values'}}, \@value;
   return $self;
}
   
sub names
{  my $self = shift;
   my @name = @_;
   $self->{'names'} = \@name;
   return $self;
}

sub xNames
{  my $self = shift;
   my @name = @_;
   $self->{'xNames'} = \@name;
   return $self;
}


sub draw
{  my $self = shift;
   my %param = @_;
   for (keys %param)
    {   $self->{$_} = $param{$_}; }
   if (! $self->{'lowerX'})
   {  $self->outlines();
   }
   my ($max, $min, $num, $maxNum, $str, $xSize, $ySize, $font);
   
   $max    = $self->{'max'};        # maximum value
   $min    = $self->{'min'};        # minimum value
   $num    = $self->{'num'};        # number of lines
   $maxNum = $self->{'maxNum'};     # max number of values

   my $langd = length($max);
   my $punkt = index($max, '.');
   if ($punkt > 0)
   {  $langd -= $punkt;
   }
   
   my $xCor  = ($langd * 12) || 25;         # margin to the left
   my $yCor  = 10;                          # margin from the bottom
   my $xAxis = ($self->{'upperX'} - $self->{'lowerX'}) * 9 / 10;
   my $yAxis = ($self->{'upperY'} - $self->{'lowerY'});
   $xAxis -= $xCor;
   $yAxis -= $yCor;
   $self->{'xSize'} = 1 unless ($self->{'xSize'} != 0);
   $self->{'ySize'} = 1 unless ($self->{'ySize'} != 0);
   $self->{'size'}  = 1 unless ($self->{'size'}  != 0);
   $xSize = $self->{'xSize'} * $self->{'size'};
   $ySize = $self->{'ySize'} * $self->{'size'};
   $self->{'x'} += $self->{'lowerX'};
   $self->{'y'} += $self->{'lowerY'};
   $str .= "q\n";
   $str .= "1 M\n";
   $str .= "2 w\n";
   $str .= "$xSize 0 0 $ySize $self->{'x'} $self->{'y'} cm\n";
   if ($self->{'rotate'} != 0)
   {   my $radian = $self->{'rotate'} / 57.3;    # approx. 
       my $Cos    = cos($radian);
       my $Sin    = sin($radian);
       my $negSin = $Sin * -1;
       $str .= "$Cos $Sin $negSin $Cos 0 0 cm\n";
   }
   if (($self->{'skewX'} != 0) || ($self->{'skewY'} != 0))
   {   my $tanX = tan($self->{'skewX'});
       my $tanY = tan($self->{'skewY'});
       my $negTanY = $tanY * -1;
       $str .= "1 $tanX $negTanY 1 0 0 cm\n";
   }
   
   if (exists $self->{'font'})
   {  $font = prFont($self->{'font'});
   }
   else
   {  $font = prFont('H');
   }

   $str .= "$xCor $yCor m\n";
   $str .= "$xCor $yAxis l\n";
   $str .= "$xCor $yCor m\n";
   $str .= "$xAxis $yCor l\n";
   $str .= 's' . "\n";
     
   my $width  = ($xAxis / $maxNum) * 0.9;
   my $prop   = ($yAxis / $max) * 0.9;
   my $xStart = $xAxis + 30 + $xCor;
   my $yStart = $yAxis - 10;
   my $tStart = $xStart + 20;
   my $iStep  = $yAxis / $num;
   if ($iStep > 20)
   {  $yStart -= 20;
      $iStep   = 20;
   }
   
   if ($langd > 1)
   {  $langd--;
      $langd = '0' x $langd;
      $langd = '1' . $langd;
   }
   my $skala = $langd;
   my $xCorSpar = $xCor;
   # srand(7);
 

   $str .= "[1 4] 0 d\n";  
   while ($skala <= $max)
   {   my $yPos = $prop * $skala + $yCor;
       $str .= "0.1 w\n";
       $str .= "0 0 0 RG\n";
       $str .= "BT\n";
       $str .= "/$font 12 Tf\n";
       $str .= "1 $yPos Td\n";
       $str .= "($skala)Tj\n";
       $str .= "ET\n";
       $str .= "$xCor $yPos m\n";
       $str .= "$xAxis $yPos l\n";
       $str .= "s\n";
       $skala += $langd;
   }
   $str .= "[] 0 d\n";
   $str .= "1 w\n";
   my $yCor2 = $yCor - 5;
   
   for (my $i = 1; $i < $maxNum; $i++)
   {  $xCor += $width;
      $str .= "$xCor $yCor m\n";
      $str .= "$xCor $yCor2 l\n";
      $str .= "s\n";
   }
   $xCor = $xCorSpar;
   if (scalar @{$self->{'xNames'}})
   {   
       my $radian = 5.3;     
       my $Cos    = cos($radian);
       my $Sin    = sin($radian);
       my $negSin = $Sin * -1;
       my $negCos = $Cos * -1;
       for (my $i = 0; $i < $maxNum; $i++)
       {  if (exists $self->{'xNames'}->[$i])
          {    $str .= "BT\n";
               $str .= "/$font 12 Tf\n";
               $str .= "$Cos $Sin $negSin $Cos $xCor $yCor2 Tm\n";
               $str .= '(' . $self->{'xNames'}->[$i] . ') Tj' . "\n";
               $str .= "ET\n"; 
          }
          $xCor += $width;
       }       
       
   }

   my $col3 = 0.85;
   my $col2 = 0.75;
   my $col1 = 0.75;
   for (my $i = 0; $i < $num; $i++)
   {   $col1 = $col3; 
       $col3 = $col2;
       $col2 = rand( ($i + 1) / ( 1 + $i + $i));
       
       $str .= "1.5 w\n";
       $str .= "$col1 $col2 $col3 RG\n";
       my $startPos;
       $xCor = $xCorSpar;
       for (my $j = 0; $j < $maxNum; $j++)
       {  if (exists $self->{'values'}->[$i]->[$j])      
          {   my $height = $self->{'values'}->[$i]->[$j] * $prop;
              $height += $yCor;
              if (! defined $startPos)
              {  $startPos = $xCor - 0.5;
                 $str .= "$startPos $height m\n";
              }
              $str .= "$xCor $height l\n";
          }
          $xCor += $width;
       }
       $str .= "S\n";
       $str .= "1 w\n";
       $str .= "$col1 $col2 $col3 rg\n";
       $str .= "0 0 0 RG\n";
       $str .= "$xStart $yStart 10 7 re\n";
       $str .= "b*\n";
       $str .= "0 0 0 rg\n";
       $str .= "BT\n";
       $str .= "/$font 12 Tf\n";
       $str .= "$tStart $yStart Td\n";       
       if ($self->{'names'}->[$i])
       {  $str .= '(' . $self->{'names'}->[$i] . ') Tj' . "\n";
       }
       else
       {  $str .= '(' . $i . ') Tj' . "\n";
       }
       $str .= "ET\n";       
       
       $yStart -= $iStep; 
   }
   $str .= "Q\n";
   PDF::Reuse::prAdd($str);
    

}
1; 