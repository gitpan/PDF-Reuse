package sun;
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
   $self->{'maxX'}   = 58.9;
   $self->{'maxY'}   = 56.6;
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
   if (exists $self->{'fillRGB2'})
   {   $str .= "$self->{'fillRGB2'} rg\n"; }
   else
   {   $str .= "0.937255 1 0.254902 rg\n"; }
   if (exists $self->{'strokeRGB1'})
   {   $str .= "$self->{'strokeRGB1'} RG\n"; }
   else
   {   $str .= "0.960784 0.615686 0.0666667 RG\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "50.0 28.3 m\n"; }
   if (exists $self->{'curv1'})
   {   $str .= "$self->{'curv1'} c\n"; }
   else
   {   $str .= "50.0 39.6 40.6 48.7 29.2 48.7 c\n"; }
   if (exists $self->{'curv2'})
   {   $str .= "$self->{'curv2'} c\n"; }
   else
   {   $str .= "17.7 48.7 8.3 39.6 8.3 28.3 c\n"; }
   if (exists $self->{'curv3'})
   {   $str .= "$self->{'curv3'} c\n"; }
   else
   {   $str .= "8.3 17.0 17.7 7.9 29.2 7.9 c\n"; }
   if (exists $self->{'curv4'})
   {   $str .= "$self->{'curv4'} c\n"; }
   else
   {   $str .= "40.6 7.9 50.0 17.0 50.0 28.3 c\n"; }
   $str .= 'b*' . "\n";
   if (exists $self->{'fillRGB2'})
   {   $str .= "$self->{'fillRGB2'} rg\n"; }
   else
   {   $str .= "1 1 1 rg\n"; }
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "28.6 56.6 m\n"; }
   if (exists $self->{'line1'})
   {   $str .= "$self->{'line1'} l\n"; }
   else
   {   $str .= "28.5 50.3 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo3'})
   {   $str .= "$self->{'moveTo3'} m\n"; }
   else
   {   $str .= "51.4 28.6 m\n"; }
   if (exists $self->{'line2'})
   {   $str .= "$self->{'line2'} l\n"; }
   else
   {   $str .= "58.9 28.6 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo4'})
   {   $str .= "$self->{'moveTo4'} m\n"; }
   else
   {   $str .= "0.0 28.9 m\n"; }
   if (exists $self->{'line3'})
   {   $str .= "$self->{'line3'} l\n"; }
   else
   {   $str .= "7.2 28.9 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo5'})
   {   $str .= "$self->{'moveTo5'} m\n"; }
   else
   {   $str .= "13.6 43.3 m\n"; }
   if (exists $self->{'line4'})
   {   $str .= "$self->{'line4'} l\n"; }
   else
   {   $str .= "8.6 47.5 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo6'})
   {   $str .= "$self->{'moveTo6'} m\n"; }
   else
   {   $str .= "45.3 12.8 m\n"; }
   if (exists $self->{'line5'})
   {   $str .= "$self->{'line5'} l\n"; }
   else
   {   $str .= "50.0 8.9 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo7'})
   {   $str .= "$self->{'moveTo7'} m\n"; }
   else
   {   $str .= "30.0 6.7 m\n"; }
   if (exists $self->{'line6'})
   {   $str .= "$self->{'line6'} l\n"; }
   else
   {   $str .= "30.0 0.0 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo8'})
   {   $str .= "$self->{'moveTo8'} m\n"; }
   else
   {   $str .= "13.9 12.4 m\n"; }
   if (exists $self->{'line7'})
   {   $str .= "$self->{'line7'} l\n"; }
   else
   {   $str .= "9.2 7.4 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo9'})
   {   $str .= "$self->{'moveTo9'} m\n"; }
   else
   {   $str .= "45.8 43.3 m\n"; }
   if (exists $self->{'line8'})
   {   $str .= "$self->{'line8'} l\n"; }
   else
   {   $str .= "50.2 47.1 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo10'})
   {   $str .= "$self->{'moveTo10'} m\n"; }
   else
   {   $str .= "49.7 35.8 m\n"; }
   if (exists $self->{'line9'})
   {   $str .= "$self->{'line9'} l\n"; }
   else
   {   $str .= "55.5 37.4 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo11'})
   {   $str .= "$self->{'moveTo11'} m\n"; }
   else
   {   $str .= "38.0 48.6 m\n"; }
   if (exists $self->{'line10'})
   {   $str .= "$self->{'line10'} l\n"; }
   else
   {   $str .= "40.5 53.3 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo12'})
   {   $str .= "$self->{'moveTo12'} m\n"; }
   else
   {   $str .= "20.5 48.0 m\n"; }
   if (exists $self->{'line11'})
   {   $str .= "$self->{'line11'} l\n"; }
   else
   {   $str .= "17.5 53.6 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo13'})
   {   $str .= "$self->{'moveTo13'} m\n"; }
   else
   {   $str .= "8.6 36.9 m\n"; }
   if (exists $self->{'line12'})
   {   $str .= "$self->{'line12'} l\n"; }
   else
   {   $str .= "2.9 39.1 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo14'})
   {   $str .= "$self->{'moveTo14'} m\n"; }
   else
   {   $str .= "8.3 20.3 m\n"; }
   if (exists $self->{'line13'})
   {   $str .= "$self->{'line13'} l\n"; }
   else
   {   $str .= "2.5 17.8 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo15'})
   {   $str .= "$self->{'moveTo15'} m\n"; }
   else
   {   $str .= "21.1 8.3 m\n"; }
   if (exists $self->{'line14'})
   {   $str .= "$self->{'line14'} l\n"; }
   else
   {   $str .= "18.7 3.6 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo16'})
   {   $str .= "$self->{'moveTo16'} m\n"; }
   else
   {   $str .= "38.3 8.3 m\n"; }
   if (exists $self->{'line15'})
   {   $str .= "$self->{'line15'} l\n"; }
   else
   {   $str .= "41.0 3.9 l\n"; }
   $str .= 'S' . "\n";
   if (exists $self->{'moveTo17'})
   {   $str .= "$self->{'moveTo17'} m\n"; }
   else
   {   $str .= "49.7 20.3 m\n"; }
   if (exists $self->{'line16'})
   {   $str .= "$self->{'line16'} l\n"; }
   else
   {   $str .= "55.2 18.1 l\n"; }
   $str .= 'S' . "\n";
   $str .= "Q\n";
   PDF::Reuse::prAdd($str);
}

sub resources
{  my $self = shift;
   my $answer;
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
