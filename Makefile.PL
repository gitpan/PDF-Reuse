use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	       	=> 'PDF::Reuse',
    'VERSION_FROM'	=> 'Reuse.pm', 
    'PREREQ_PM'		=> { Digest::MD5    => 0,
                          Compress::Zlib => 0,
                          Carp           => 0,
                          Exporter       => 0,
                          SelfLoader     => 0},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Reuse.pm', 
       AUTHOR     => 'Lars Lundberg elkelund@worldonline.se') : ()),
);
