package lightn;
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
   $self->{'maxX'}   = 12.7;
   $self->{'maxY'}   = 50.4;
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
   {   $str .= "0.933333 1 0.160784 rg\n"; }
   if (exists $self->{'strokeRGB1'})
   {   $str .= "$self->{'strokeRGB1'} RG\n"; }
   else
   {   $str .= "0.992157 0.580392 0.286275 RG\n"; }
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.25 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "6.8 49.4 m\n"; }
   if (exists $self->{'line1'})
   {   $str .= "$self->{'line1'} l\n"; }
   else
   {   $str .= "8.0 47.4 l\n"; }
   if (exists $self->{'line2'})
   {   $str .= "$self->{'line2'} l\n"; }
   else
   {   $str .= "12.7 50.4 l\n"; }
   if (exists $self->{'line3'})
   {   $str .= "$self->{'line3'} l\n"; }
   else
   {   $str .= "1.6 21.6 l\n"; }
   if (exists $self->{'line4'})
   {   $str .= "$self->{'line4'} l\n"; }
   else
   {   $str .= "6.8 49.4 l\n"; }
   $str .= 'b*' . "\n";
   if (exists $self->{'fillRGB3'})
   {   $str .= "$self->{'fillRGB3'} rg\n"; }
   else
   {   $str .= "0.976471 0.85098 0.517647 rg\n"; }
   if (exists $self->{'strokeRGB2'})
   {   $str .= "$self->{'strokeRGB2'} RG\n"; }
   else
   {   $str .= "0.937255 0.384314 0.0745098 RG\n"; }
   if (exists $self->{'lineWidth2'})
   {   $str .= "$self->{'lineWidth2'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "0.0 23.0 m\n"; }
   if (exists $self->{'line5'})
   {   $str .= "$self->{'line5'} l\n"; }
   else
   {   $str .= "10.0 40.6 l\n"; }
   if (exists $self->{'line6'})
   {   $str .= "$self->{'line6'} l\n"; }
   else
   {   $str .= "3.3 0.0 l\n"; }
   if (exists $self->{'line7'})
   {   $str .= "$self->{'line7'} l\n"; }
   else
   {   $str .= "4.5 34.9 l\n"; }
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
