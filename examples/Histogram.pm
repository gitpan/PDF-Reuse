package Histogram;
use PDF::Reuse;
use autouse 'Math::Trig' => qw(tan);
use strict;

sub new
{  my $name  = shift;
   my $class = ref($name) || $name;
   my $this  = {};
   bless $this, $name;
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
   $self->{'values'} = \@value;
   return $self;
}
   
sub names
{  my $self = shift;
   my @name = @_;
   $self->{'names'} = \@name;
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
   my ($max, $min, $num, $str, $xSize, $ySize, $font);
   for (@{$self->{'values'}})
   {  if (! defined $min)
      {  $min = $_; 
      }
      if ($_ > $max)
      {  $max = $_;
      }
      if ($_ < $min)
      {  $min = $_;
      }
      $num++;
   }

   my $langd = length($max);
   my $punkt = index($max, '.');
   if ($punkt > 0)
   {  $langd -= $punkt;
   }
   
   my $xCor  = ($langd * 12) || 25;         # margin to the left
   my $yCor  = 10;                          # margin from the bottom
   my $xAxis = ($self->{'upperX'} - $self->{'lowerX'}) * 4 / 5;
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
   if (exists $self->{'rg1'})
   {   $str .= "$self->{'rg1'} rg\n"; }
   else
   {   $str .= "1 1 1 rg\n"; }
   if (exists $self->{'w1'})
   {   $str .= "$self->{'w1'} w\n"; }
   else
   {   $str .= "1 w\n"; }
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
   $str .= 'b*' . "\n";
  
   
   my $width  = ($xAxis / $num) * 0.9;
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
   my $xCor2 = $xCor - 5;
   # srand(7); 
     
   while ($skala <= $max)
   {   my $yPos = $prop * $skala + $yCor;
       $str .= "1 w\n";
       $str .= "0 0 0 rg\n";
       $str .= "BT\n";
       $str .= "/$font 12 Tf\n";
       $str .= "1 $yPos Td\n";
       $str .= "($skala)Tj\n";
       $str .= "ET\n";
       $str .= "$xCor2 $yPos m\n";
       $str .= "$xCor $yPos l\n";
       $str .= "b*\n";
       $skala += $langd;
   }
   my $col3 = 0.85;
   my $col2 = 0.75;
   my $col1 = 0.75;
   for (my $i = 0; $i < $num; $i++)
   {   $col1 = $col3; 
       $col3 = $col2;
       $col2 = rand( ($i + 1) / ( 1 + $i + $i));
       if ($col1 < 0.2)
       { $col1 = 1 - $col1;
       }
       if ($col2 < 0.2)
       { $col2 =  1 - $col2;
       }
       if ($col3 < 0.2)
       { $col3 =  1 - $col3;
       }       
       my $height = $self->{'values'}->[$i] * $prop;
       $str .= "$col1 $col2 $col3 rg\n";
       $str .= "$xCor $yCor $width $height re\n";
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
       $xCor += $width;
       $yStart -= $iStep; 
   }
   $str .= "Q\n";
   PDF::Reuse::prAdd($str);
    

}
1; 