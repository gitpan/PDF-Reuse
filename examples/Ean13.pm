package Ean13;
use PDF::Reuse;
use GD::Barcode::EAN13;
use strict;

sub new
{  my $class = shift;
   my $model = shift;
   my $self  = {};
   $self->{'x'}      = 0;
   $self->{'y'}      = 0;
   $self->{'rotate'} = 0;
   
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
   my $value = $self->{'value'};
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
   
   if (exists $self->{'background'})
   {   $str .= "$self->{'background'} rg\n";
       $str .= "0 0 105 40 re\n";  
       $str .= 'f*' . "\n";
       $str .= "0 0 0 rg\n";
   }
   
   PDF::Reuse::prAdd($str);

   my $oGdBar = GD::Barcode::EAN13->new($value);
   die $GD::Barcode::EAN13::errStr unless($oGdBar);
   my $sPtn = $oGdBar->barcode();

   my @sizes = prFontSize(12);

   prBar(10, 9, $sPtn);
   
   my $siffra = substr($value, 0, 1);
   my $del1   = substr($value, 1, 6);
   my $del2   = substr($value, 7, 6);

   my @vec = prFont('C');

   prFontSize(10);
   
   prText(1, 2, $siffra);
   prText(14, 2, $del1);
   prText(56, 2, $del2);
   
   $str = "Q\n";
   PDF::Reuse::prAdd($str);

   prFont($vec[3]);
   prFontSize($sizes[1]);
   1;
}
1;