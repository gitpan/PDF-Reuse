package drop;
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
   $self->{'maxX'}   = 27.3;
   $self->{'maxY'}   = 38.7;
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
   {   $str .= "0.670588 0.870588 1 rg\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.25 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "8.7 38.7 m\n"; }
   if (exists $self->{'curv1'})
   {   $str .= "$self->{'curv1'} c\n"; }
   else
   {   $str .= "23.4 26.0 27.3 19.1 24.5 10.9 c\n"; }
   if (exists $self->{'curv2'})
   {   $str .= "$self->{'curv2'} c\n"; }
   else
   {   $str .= "22.1 4.1 10.3 0.0 5.9 3.4 c\n"; }
   if (exists $self->{'curv3'})
   {   $str .= "$self->{'curv3'} c\n"; }
   else
   {   $str .= "0.0 7.9 1.0 16.7 10.0 38.4 c\n"; }
   $str .= 'B*' . "\n";
   if (exists $self->{'fillRGB3'})
   {   $str .= "$self->{'fillRGB3'} rg\n"; }
   else
   {   $str .= "0.521569 0.929412 1 rg\n"; }
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "20.1 17.3 m\n"; }
   if (exists $self->{'curv4'})
   {   $str .= "$self->{'curv4'} c\n"; }
   else
   {   $str .= "20.1 20.1 18.7 22.4 17.0 22.4 c\n"; }
   if (exists $self->{'curv5'})
   {   $str .= "$self->{'curv5'} c\n"; }
   else
   {   $str .= "15.3 22.4 13.8 20.1 13.8 17.3 c\n"; }
   if (exists $self->{'curv6'})
   {   $str .= "$self->{'curv6'} c\n"; }
   else
   {   $str .= "13.8 14.5 15.3 12.2 17.0 12.2 c\n"; }
   if (exists $self->{'curv7'})
   {   $str .= "$self->{'curv7'} c\n"; }
   else
   {   $str .= "18.7 12.2 20.1 14.5 20.1 17.3 c\n"; }
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
