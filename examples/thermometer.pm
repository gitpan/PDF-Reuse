package thermometer;
require PDF::Reuse;
use strict;

sub new
{  my $class = shift;
   my $model = shift;
   my $self  = {};
   $self->{'x'}      = 0;
   $self->{'y'}      = 0;
   $self->{'rotate'} = 0;
   $self->{'skewX'}  = 0;
   $self->{'skewY'}  = 0;
   $self->{'minX'}   = 0;
   $self->{'minY'}   = 0;
   $self->{'maxX'}   = 22.4;
   $self->{'maxY'}   = 75.7;
   $self->{'font1'}->{'oldName'} = 'F1';
   $self->{'font1'}->{'file'}  = 'thermometer.pdf';
   $self->{'font1'}->{'page'}  = 1;
   if (defined $model)
   {   for (keys %$model)
       {   $self->{$_} = $model->{$_};
       }
   }
   bless $self, $class;
}

sub draw
{  my $self  = shift;
   my %param = @_;
   for (keys %param)
    {   $self->{$_} = $param{$_}; }
   my ($str, $xSize, $ySize);
   $self->resources();
   $self->{'xSize'} = 1 unless ($self->{'xSize'} != 0);
   $self->{'ySize'} = 1 unless ($self->{'ySize'} != 0);
   $self->{'size'}  = 1 unless ($self->{'size'}  != 0);
   $xSize = $self->{'xSize'} * $self->{'size'};
   $ySize = $self->{'ySize'} * $self->{'size'};
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
   if (exists $self->{'fillRGB1'})
   {   $str .= "$self->{'fillRGB1'} rg\n"; }
   else
   {   $str .= "1 1 1 rg\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "4.5 10.5 m\n"; }
   if (exists $self->{'line1'})
   {   $str .= "$self->{'line1'} l\n"; }
   else
   {   $str .= "4.5 75.7 l\n"; }
   if (exists $self->{'line2'})
   {   $str .= "$self->{'line2'} l\n"; }
   else
   {   $str .= "13.7 75.7 l\n"; }
   if (exists $self->{'line3'})
   {   $str .= "$self->{'line3'} l\n"; }
   else
   {   $str .= "13.7 10.5 l\n"; }
   if (exists $self->{'line4'})
   {   $str .= "$self->{'line4'} l\n"; }
   else
   {   $str .= "4.5 10.5 l\n"; }
   $str .= 'b*' . "\n";
   if (exists $self->{'fillRGB2'})
   {   $str .= "$self->{'fillRGB2'} rg\n"; }
   else
   {   $str .= "0 0 0 rg\n"; }
   $str .= 'BT' . "\n";
   $str .= "/$self->{'font1'}->{'newName'} 14 Tf\n";
   if (exists $self->{'tMatrix1'})
   {   $str .= "$self->{'tMatrix1'} Tm\n"; }
   else
   {   $str .= "1 0 0 1 22.4 13.6 Tm\n"; }
   $str .= '0 Tw' . "\n";
   if (exists $self->{'text1'})
   {   $str .= "($self->{'text1'}) Tj\n"; }
   else
   {   $str .= '(-40 C) Tj' . "\n"; }
   $str .= 'ET' . "\n";
   if (exists $self->{'fillRGB3'})
   {   $str .= "$self->{'fillRGB3'} rg\n"; }
   else
   {   $str .= "0.356863 0.309804 0.929412 rg\n"; }
   if (exists $self->{'lineWidth2'})
   {   $str .= "$self->{'lineWidth2'} w\n"; }
   else
   {   $str .= "1 w\n"; }
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "4.7 11.0 m\n"; }
   if (exists $self->{'line5'})
   {   $str .= "$self->{'line5'} l\n"; }
   else
   {   $str .= "4.7 14.8 l\n"; }
   if (exists $self->{'line6'})
   {   $str .= "$self->{'line6'} l\n"; }
   else
   {   $str .= "13.6 14.8 l\n"; }
   if (exists $self->{'line7'})
   {   $str .= "$self->{'line7'} l\n"; }
   else
   {   $str .= "13.6 11.0 l\n"; }
   if (exists $self->{'line8'})
   {   $str .= "$self->{'line8'} l\n"; }
   else
   {   $str .= "4.7 11.0 l\n"; }
   $str .= 'b*' . "\n";
   if (exists $self->{'lineWidth3'})
   {   $str .= "$self->{'lineWidth3'} w\n"; }
   else
   {   $str .= "0.25 w\n"; }
   if (exists $self->{'moveTo3'})
   {   $str .= "$self->{'moveTo3'} m\n"; }
   else
   {   $str .= "18.3 7.0 m\n"; }
   if (exists $self->{'curv1'})
   {   $str .= "$self->{'curv1'} c\n"; }
   else
   {   $str .= "18.3 10.8 14.2 13.9 9.1 13.9 c\n"; }
   if (exists $self->{'curv2'})
   {   $str .= "$self->{'curv2'} c\n"; }
   else
   {   $str .= "4.1 13.9 0.0 10.8 0.0 7.0 c\n"; }
   if (exists $self->{'curv3'})
   {   $str .= "$self->{'curv3'} c\n"; }
   else
   {   $str .= "0.0 3.1 4.1 0.0 9.1 0.0 c\n"; }
   if (exists $self->{'curv4'})
   {   $str .= "$self->{'curv4'} c\n"; }
   else
   {   $str .= "14.2 0.0 18.3 3.1 18.3 7.0 c\n"; }
   $str .= 'b*' . "\n";
   $str .= "Q\n";
   PDF::Reuse::prAdd($str);
}

sub resources
{  my $self = shift;
   my $answer;
   if (exists $self->{'font'})
   {   $self->{'font1'}->{'newName'} = PDF::Reuse::prFont($self->{'font'});
   }
   else
   {   $answer = PDF::Reuse::prExtract($self->{'font1'}->{'oldName'},$self->{'font1'}->{'file'},$self->{'font1'}->{'page'});
       if ($answer)
       {   $self->{'font1'}->{'newName'} = $answer;
       }
       else
       {   $self->{'font'} = 'H';
           $self->{'font1'}->{'newName'} = PDF::Reuse::prFont('H');
       }
    }
}

sub originalDim
{   my $self = shift;
    return ($self->{'minX'}, $self->{'minY'}, $self->{'maxX'}, $self->{'maxY'});
}

sub tan
{   my $tal = shift;
    return (sin($tal) / cos($tal));
}

sub resourcesFrom
{  my $self  = shift;
   my $donor = shift;
   for (keys %$donor)
   {   if ((exists $self->{$_})
       && (ref($donor->{$_}) eq 'HASH')
       && (defined $donor->{$_}->{'newName'})
       && (defined $donor->{$_}->{'file'})
       && (defined $donor->{$_}->{'page'}))
       {   $self->{$_} = $donor->{$_};
       }
   }
}
1;
