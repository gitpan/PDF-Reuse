package snow;
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
   $self->{'maxX'}   = 44.9;
   $self->{'maxY'}   = 45.8;
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
   if (exists $self->{'lineWidth1'})
   {   $str .= "$self->{'lineWidth1'} w\n"; }
   else
   {   $str .= "0.5 w\n"; }
   if (exists $self->{'moveTo1'})
   {   $str .= "$self->{'moveTo1'} m\n"; }
   else
   {   $str .= "24.1 45.8 m\n"; }
   if (exists $self->{'line1'})
   {   $str .= "$self->{'line1'} l\n"; }
   else
   {   $str .= "18.7 0.2 l\n"; }
   $str .= 'n' . "\n";
   if (exists $self->{'lineWidth2'})
   {   $str .= "$self->{'lineWidth2'} w\n"; }
   else
   {   $str .= "0.25 w\n"; }
   if (exists $self->{'moveTo2'})
   {   $str .= "$self->{'moveTo2'} m\n"; }
   else
   {   $str .= "2.5 37.4 m\n"; }
   if (exists $self->{'line2'})
   {   $str .= "$self->{'line2'} l\n"; }
   else
   {   $str .= "41.2 9.6 l\n"; }
   $str .= 'n' . "\n";
   if (exists $self->{'moveTo3'})
   {   $str .= "$self->{'moveTo3'} m\n"; }
   else
   {   $str .= "44.4 32.4 m\n"; }
   if (exists $self->{'line3'})
   {   $str .= "$self->{'line3'} l\n"; }
   else
   {   $str .= "0.0 14.9 l\n"; }
   $str .= 'n' . "\n";
   if (exists $self->{'fillRGB2'})
   {   $str .= "$self->{'fillRGB2'} rg\n"; }
   else
   {   $str .= "0.921569 0.968627 1 rg\n"; }
   if (exists $self->{'moveTo4'})
   {   $str .= "$self->{'moveTo4'} m\n"; }
   else
   {   $str .= "3.7 35.9 m\n"; }
   if (exists $self->{'line4'})
   {   $str .= "$self->{'line4'} l\n"; }
   else
   {   $str .= "22.8 25.8 l\n"; }
   if (exists $self->{'line5'})
   {   $str .= "$self->{'line5'} l\n"; }
   else
   {   $str .= "44.9 31.2 l\n"; }
   if (exists $self->{'line6'})
   {   $str .= "$self->{'line6'} l\n"; }
   else
   {   $str .= "25.0 21.1 l\n"; }
   if (exists $self->{'line7'})
   {   $str .= "$self->{'line7'} l\n"; }
   else
   {   $str .= "19.6 0.0 l\n"; }
   if (exists $self->{'line8'})
   {   $str .= "$self->{'line8'} l\n"; }
   else
   {   $str .= "19.2 22.0 l\n"; }
   if (exists $self->{'line9'})
   {   $str .= "$self->{'line9'} l\n"; }
   else
   {   $str .= "3.7 35.9 l\n"; }
   $str .= 'b*' . "\n";
   if (exists $self->{'fillRGB2'})
   {   $str .= "$self->{'fillRGB2'} rg\n"; }
   else
   {   $str .= "1 1 1 rg\n"; }
   if (exists $self->{'moveTo5'})
   {   $str .= "$self->{'moveTo5'} m\n"; }
   else
   {   $str .= "24.7 44.4 m\n"; }
   if (exists $self->{'line10'})
   {   $str .= "$self->{'line10'} l\n"; }
   else
   {   $str .= "19.6 25.2 l\n"; }
   if (exists $self->{'line11'})
   {   $str .= "$self->{'line11'} l\n"; }
   else
   {   $str .= "0.0 14.1 l\n"; }
   if (exists $self->{'line12'})
   {   $str .= "$self->{'line12'} l\n"; }
   else
   {   $str .= "22.4 20.5 l\n"; }
   if (exists $self->{'line13'})
   {   $str .= "$self->{'line13'} l\n"; }
   else
   {   $str .= "41.6 8.5 l\n"; }
   if (exists $self->{'line14'})
   {   $str .= "$self->{'line14'} l\n"; }
   else
   {   $str .= "25.0 24.5 l\n"; }
   if (exists $self->{'line15'})
   {   $str .= "$self->{'line15'} l\n"; }
   else
   {   $str .= "24.7 44.4 l\n"; }
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
