package wind;
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
   $self->{'maxX'}   = 25.3;
   $self->{'maxY'}   = 56.2;
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
   {   $str .= "0.639216 0.941176 0.941176 rg\n"; }
   if (exists $self->{'strokeRGB1'})
   {   $str .= "$self->{'strokeRGB1'} RG\n"; }
   else
   {   $str .= "0.0901961 0.611765 0.929412 RG\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "5.2 56.2 m\n"; }
   if (exists $self->{'curv1'})
   {   $str .= "$self->{'curv1'} c\n"; }
   else
   {   $str .= "6.3 16.6 10.3 0.0 12.5 0.0 c\n"; }
   if (exists $self->{'curv2'})
   {   $str .= "$self->{'curv2'} c\n"; }
   else
   {   $str .= "14.7 0.0 16.0 15.9 16.7 56.2 c\n"; }
   $str .= 'B*' . "\n";
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "9.4 13.0 m\n"; }
   if (exists $self->{'curv3'})
   {   $str .= "$self->{'curv3'} c\n"; }
   else
   {   $str .= "3.7 16.2 1.7 17.0 1.1 16.2 c\n"; }
   if (exists $self->{'curv4'})
   {   $str .= "$self->{'curv4'} c\n"; }
   else
   {   $str .= "0.0 14.7 2.3 9.6 11.2 1.1 c\n"; }
   $str .= 'B*' . "\n";
   if (exists $self->{'moveTo3'})
   {   $str .= "$self->{'moveTo3'} m\n"; }
   else
   {   $str .= "14.9 13.0 m\n"; }
   if (exists $self->{'curv5'})
   {   $str .= "$self->{'curv5'} c\n"; }
   else
   {   $str .= "18.1 15.8 25.3 18.0 22.5 14.4 c\n"; }
   if (exists $self->{'curv6'})
   {   $str .= "$self->{'curv6'} c\n"; }
   else
   {   $str .= "21.5 13.2 20.6 9.2 13.5 1.4 c\n"; }
   $str .= 'B*' . "\n";
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
