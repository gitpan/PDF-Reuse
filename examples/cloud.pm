package cloud;
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
   $self->{'maxX'}   = 101.5;
   $self->{'maxY'}   = 38.3;
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
   {   $str .= "0.878431 0.878431 0.878431 rg\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "18.8 28.7 m\n"; }
   if (exists $self->{'curv1'})
   {   $str .= "$self->{'curv1'} c\n"; }
   else
   {   $str .= "17.4 29.0 14.3 30.8 12.5 30.6 c\n"; }
   if (exists $self->{'curv2'})
   {   $str .= "$self->{'curv2'} c\n"; }
   else
   {   $str .= "10.3 30.4 6.5 28.4 5.1 26.7 c\n"; }
   if (exists $self->{'curv3'})
   {   $str .= "$self->{'curv3'} c\n"; }
   else
   {   $str .= "2.6 23.7 0.0 17.1 0.8 13.0 c\n"; }
   if (exists $self->{'curv4'})
   {   $str .= "$self->{'curv4'} c\n"; }
   else
   {   $str .= "1.5 9.4 5.8 4.8 8.6 3.2 c\n"; }
   if (exists $self->{'curv5'})
   {   $str .= "$self->{'curv5'} c\n"; }
   else
   {   $str .= "13.1 0.6 23.3 0.0 27.8 0.0 c\n"; }
   if (exists $self->{'curv6'})
   {   $str .= "$self->{'curv6'} c\n"; }
   else
   {   $str .= "31.1 0.0 38.2 2.5 41.6 2.4 c\n"; }
   if (exists $self->{'curv7'})
   {   $str .= "$self->{'curv7'} c\n"; }
   else
   {   $str .= "43.5 2.3 47.5 0.4 49.4 0.4 c\n"; }
   if (exists $self->{'curv8'})
   {   $str .= "$self->{'curv8'} c\n"; }
   else
   {   $str .= "51.7 0.4 56.3 2.2 58.4 2.4 c\n"; }
   if (exists $self->{'curv9'})
   {   $str .= "$self->{'curv9'} c\n"; }
   else
   {   $str .= "62.2 2.6 70.7 0.7 74.5 1.2 c\n"; }
   if (exists $self->{'curv10'})
   {   $str .= "$self->{'curv10'} c\n"; }
   else
   {   $str .= "76.4 1.5 80.1 3.6 82.0 3.9 c\n"; }
   if (exists $self->{'curv11'})
   {   $str .= "$self->{'curv11'} c\n"; }
   else
   {   $str .= "84.2 4.3 89.2 3.4 91.4 3.5 c\n"; }
   if (exists $self->{'curv12'})
   {   $str .= "$self->{'curv12'} c\n"; }
   else
   {   $str .= "92.6 3.6 95.3 3.5 96.5 4.3 c\n"; }
   if (exists $self->{'curv13'})
   {   $str .= "$self->{'curv13'} c\n"; }
   else
   {   $str .= "98.8 5.9 100.9 10.4 101.2 13.0 c\n"; }
   if (exists $self->{'curv14'})
   {   $str .= "$self->{'curv14'} c\n"; }
   else
   {   $str .= "101.5 15.4 99.7 20.0 98.8 22.0 c\n"; }
   if (exists $self->{'curv15'})
   {   $str .= "$self->{'curv15'} c\n"; }
   else
   {   $str .= "98.2 23.5 97.0 27.1 95.3 28.3 c\n"; }
   if (exists $self->{'curv16'})
   {   $str .= "$self->{'curv16'} c\n"; }
   else
   {   $str .= "93.0 29.9 87.9 30.0 85.5 29.8 c\n"; }
   if (exists $self->{'curv17'})
   {   $str .= "$self->{'curv17'} c\n"; }
   else
   {   $str .= "83.1 29.6 79.3 25.6 76.1 26.7 c\n"; }
   if (exists $self->{'curv18'})
   {   $str .= "$self->{'curv18'} c\n"; }
   else
   {   $str .= "75.2 27.0 74.9 28.5 74.5 29.0 c\n"; }
   if (exists $self->{'curv19'})
   {   $str .= "$self->{'curv19'} c\n"; }
   else
   {   $str .= "72.9 31.0 69.8 35.7 66.7 36.5 c\n"; }
   if (exists $self->{'curv20'})
   {   $str .= "$self->{'curv20'} c\n"; }
   else
   {   $str .= "63.4 37.4 58.1 35.3 55.7 33.8 c\n"; }
   if (exists $self->{'curv21'})
   {   $str .= "$self->{'curv21'} c\n"; }
   else
   {   $str .= "54.7 33.1 53.5 31.1 52.9 30.2 c\n"; }
   if (exists $self->{'curv22'})
   {   $str .= "$self->{'curv22'} c\n"; }
   else
   {   $str .= "52.3 29.1 52.2 25.2 51.0 25.1 c\n"; }
   if (exists $self->{'curv23'})
   {   $str .= "$self->{'curv23'} c\n"; }
   else
   {   $str .= "48.8 25.1 48.6 32.6 46.7 34.5 c\n"; }
   if (exists $self->{'curv24'})
   {   $str .= "$self->{'curv24'} c\n"; }
   else
   {   $str .= "45.5 35.6 42.5 36.5 41.2 36.9 c\n"; }
   if (exists $self->{'curv25'})
   {   $str .= "$self->{'curv25'} c\n"; }
   else
   {   $str .= "39.7 37.3 36.2 38.3 34.5 38.1 c\n"; }
   if (exists $self->{'curv26'})
   {   $str .= "$self->{'curv26'} c\n"; }
   else
   {   $str .= "33.0 37.8 30.1 36.3 29.0 35.3 c\n"; }
   if (exists $self->{'curv27'})
   {   $str .= "$self->{'curv27'} c\n"; }
   else
   {   $str .= "28.1 34.5 26.8 32.1 26.3 31.0 c\n"; }
   if (exists $self->{'curv28'})
   {   $str .= "$self->{'curv28'} c\n"; }
   else
   {   $str .= "25.9 30.2 26.3 28.2 25.1 27.5 c\n"; }
   if (exists $self->{'curv29'})
   {   $str .= "$self->{'curv29'} c\n"; }
   else
   {   $str .= "23.1 26.3 20.2 28.3 18.8 28.7 c\n"; }
   $str .= 'b*' . "\n";
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
