#! /usr/bin/perl5 -w

use strict;
use Tk;
use Tk::TextUndo;
use Tk::Table;
use Tk::NoteBook;
use open ':std', ':encoding(UTF-8)';

BEGIN{
  if($^O eq 'MSWin32'){
      require Win32::Console;
      #Win32::Console::Free();
  }
}

my $fdialogbug = 0;

if($] >= 5.008004) {
  $fdialogbug = 1;
}

my %lang_data_cache;
my $lang_code_file_path = 'Manager_language.txt';
open(my $fh_lang_code, '<', $lang_code_file_path) or die "Cannot open language code file: $!";
my $lang_code = <$fh_lang_code>;
chomp($lang_code);
close($fh_lang_code);
my $lang_file = "Languages\\$lang_code\\StrategyManager.txt";
my $back_lang_file = "Languages\\English\\StrategyManager.txt";
my %languages;

sub load_language {
    my ($lang_file) = @_;
    return $lang_data_cache{$lang_file} if exists $lang_data_cache{$lang_file};
    open my $fh, '<:encoding(UTF-8)', $lang_file or die "Cannot open language file '$lang_file': $!";
    my %keylang;
    while (<$fh>) {
        chomp;
        next if /^\s*(?:#.*)?$/;
        my ($key, $value) = split '=', $_, 2;
        unless (defined $key && defined $value) {
            warn "Invalid line format in language file at line $.: $_";
            next;
        }
        # $key =~ s/^\s+|\s+$//g;
        # $value =~ s/^\s+|\s+$//g;
        $keylang{$key} = $value;
    }
    close $fh;
    $lang_data_cache{$lang_file} = \%keylang;
    return \%keylang;
}

sub get_translation {
    my ($key, @args) = @_;
    my $lang_ref = load_language($lang_file);
    if (exists $lang_ref->{$key} && $lang_ref->{$key} !~ /^\s*$/) {
        return sprintf($lang_ref->{$key}, @args);
    }
    $lang_ref = load_language($back_lang_file);
    if (exists $lang_ref->{$key} && $lang_ref->{$key} !~ /^\s*$/) {
        return sprintf($lang_ref->{$key}, @args);
    }
    return "$key(" . join(", ", @args) . ")";
}

my $main = MainWindow->new(-title => get_translation('title_strategy_manager'));
my ($screen_width, $screen_height) = ($main->screenwidth, $main->screenheight);
$main->maxsize(400, 1200);
my $lframe = $main->Frame->pack(-side => 'left');
my $race;
my $ver;
my $strat;
my $profile;
my $rframe = $main->Frame->pack(-side => 'right');
my $notebook = $rframe->NoteBook()->pack(-side => 'left');
$notebook->configure(-font => ['Helvetica', 10]);
my $stratframe = $notebook->add("strat", -label => get_translation('label_strategies'));
my $profileframe = $notebook->add("profile", -label => get_translation('label_profiles'));
my $stratlb = $stratframe->Listbox(-height => 0)->pack;
$stratlb = $stratframe->Scrolled('Listbox',
    -scrollbars => 'se',
    -height => 0,
)->pack(-fill => 'both', -expand => 1);
tie $strat, "Tk::Listbox", $stratlb;
my $profilelb = $profileframe->Listbox(-height => 0)->pack;
$profilelb = $profileframe->Scrolled('Listbox',
    -scrollbars => 'se',
    -height => 0,
)->pack(-fill => 'both', -expand => 1);
tie $profile, "Tk::Listbox", $profilelb;

my $bframe = $rframe->Frame->pack(-side => 'right');
$bframe->Label(
                -text => get_translation('placeholder_operate'),
                -width => 16,
                -height => 1,
)->pack;
$bframe->Button(
                -text => get_translation('button_new'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     InsertStratSub("$ver\\$race\\New.ais", $ver, $race);
                     UpdateStratList($stratlb, $ver, $race)
                   }
                   else {
                     InsertProfileSub("$ver\\New.aip", $ver);
                     UpdateProfileList($profilelb, $ver)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_extract'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     ExtractStrat($main, $ver, $race, $strat)
                   }
                   else {
                     ExtractProfile($main, $ver, $profile)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_insert'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     InsertStrat($main, $ver, $race);
                     UpdateStratList($stratlb, $ver, $race)
                   }
                   else {
                     InsertProfile($main, $ver);
                     UpdateProfileList($profilelb, $ver)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_copy'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     CopyStrat($ver, $race, $strat);
                     UpdateStratList($stratlb, $ver, $race)
                   }
                   else {
                     CopyProfile($ver, $profile);
                     UpdateProfileList($profilelb, $ver)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_remove'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     RemoveStrat($main, $ver, $race, $strat);
                     UpdateStratList($stratlb, $ver, $race)
                   }
                   else {
                     RemoveProfile($main, $ver, $profile);
                     UpdateProfileList($profilelb, $ver)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_edit'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     EditStrat($main, $ver, $race, $strat)
                   }
                   else {
                     EditProfile($main, $ver, $profile)
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_lock'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     SetRaceOption($ver, $race, 'debug_strategy', "STRAT_$strat->[0]")
                   }
                   else {
                     SetVerOption($ver, 'debug_profile', GetArrayIndex($profile, $profilelb->get(0, 'end')))
                   }
                },
                -width => 16)->pack;
$bframe->Button(
                -text => get_translation('button_unlock'),
                -command => sub {
                   if ($notebook->raised eq 'strat') {
                     SetRaceOption($ver, $race, 'debug_strategy', -1)
                   }
                   else {
                     SetVerOption($ver, 'debug_profile', -1)
                   }
                },
                -width => 16)->pack;

open(VERFILE, "Versions.txt") or die get_translation('err_file_not_found', "<Versions.txt>");
my @vers = <VERFILE>;
close(VERFILE);
chomp foreach (@vers);
my $raceopt;
my $veropt;
my $langopt;
$lframe->Label(
                -text => get_translation('placeholder_ver'),
                -width => 24,
                -height => 1,
)->pack;
$veropt = $lframe->Optionmenu(
                -command => sub {  $raceopt -> destroy if($raceopt); 
                $raceopt = $lframe->Optionmenu(
                            -command => sub { UpdateStratList($stratlb, $ver, $race) },
                            -variable => \$race,
                            -width => 20)->pack(-after => $veropt);
                $raceopt -> addOptions(GetRaces($ver));
                UpdateStratList($stratlb, $ver, $race);
                UpdateProfileList($profilelb, $ver) },
                -variable => \$ver,
                -width => 20)->pack;
$veropt->addOptions(@vers);
$lframe->Label(
                -height => 1,  # Placeholder
)->pack;
$lframe->Label(
                -text => get_translation('placeholder_set'),
                -width => 24,
                -height => 1,
)->pack;
$lframe->Button(
                -text => get_translation('button_edit_global'),
                -command => sub { EditSettings($main, "$ver\\GlobalSettings.txt") },
                -width => 24)->pack;
$lframe->Label(
                -height => 1,  # Placeholder
)->pack;
$lframe->Label(
                -text => get_translation('placeholder_raceset'),
                -width => 24,
                -height => 1,
)->pack;
$lframe->Button(
                -text => get_translation('button_edit_racial_builds'),
                -command => sub { EditRacialBuilds($main, $ver, $race) },
                -width => 24)->pack;
$lframe->Button(
                -text => get_translation('button_edit_racial_settings'),
                -command => sub { EditSettings($main, "$ver\\$race\\Settings.txt") },
                -width => 24)->pack;
$lframe->Label(
                -height => 1,  # Placeholder
)->pack;
$lframe->Label(
                -text => get_translation('placeholder_compile'),
                -width => 24,
                -height => 1,
)->pack;
$lframe->Button(
                -text => get_translation('button_compile'),
                -command => sub { system "Make$ver.bat" },
                -width => 24)->pack;
$lframe->Button(
                -text => get_translation('button_compile_opt'),
                -command => sub { system "MakeOpt$ver.bat" },
                -width => 24)->pack;
$lframe->Button(
                -text => get_translation('button_compile_vsai'),
                -command => sub { system "MakeVAI$ver.bat" },
                -width => 24)->pack;
$lframe->Label(
                -height => 1,  # Placeholder
)->pack;
$lframe->Label(
                -text => get_translation('placeholder_setlang'),
                -width => 24,
                -height => 1,
)->pack;
$langopt = $lframe->Optionmenu(
                -command => sub {
                  my ($choice) = @_;
                  open(SETLANG, ">Manager_language.txt") or die get_translation('err_file_not_writing', "<Manager_language.txt>");
                  print SETLANG $choice;
                  close(SETLANG);
                  exec($^X, $0, @ARGV);
                },
                -variable => \$lang_code,
                -width => 20
)->pack;
$langopt -> addOptions(GetLanguages());
# $lframe->Label(
#                 -height => 4,  # Placeholder
# )->pack;
# $lframe->Button(
#                 -text => get_translation('button_quit'),  # no need
#                 -command => [$main => 'destroy'],
#                 -width => 24
# )->pack;
MainLoop;

sub GetLanguages {
  open(LANG, "Languages.txt") or die get_translation('err_file_not_found', "<Languages.txt>");
  my @languages = <LANG>;
  close(LANG);
  shift @languages;
  chomp foreach (@languages);
  foreach (@languages) {
    /^([^\t]*)\t/;
    $_ = $1;
  };
  return @languages;
};

sub GetRaces {
  my $ver = shift;
  open(RACEFILE, "$ver\\Races.txt") or die get_translation('err_file_not_found', "<$ver\\Races.txt>");
  my @races = <RACEFILE>;
  close(RACEFILE);
  chomp foreach (@races);
  foreach (@races) {
    /^([^\t]*)\t/;
    $_ = $1;
  };
  return @races;
}

sub GetArrayIndex {
  my ($x, @a) = @_;
  my $i = 0;
  return -1 unless (@$x[0]);
  foreach (@a) {
    return $i if (@$x[0] eq $_);
    $i++;
  }
  return -1;
}

sub SetRaceOption {
  my ($ver, $race, $opt, $val) = @_;
  open(SETFILE, "$ver\\$race\\Settings.txt") or die get_translation('err_file_not_found', "<$ver\\$race\\Settings.txt>");
  my @setfile = ();
  my $optionexists = 0;
  while(<SETFILE>) {
    if (/^$opt\t[^\t]*\t(.*)/) {
      push @setfile, "$opt\t$val\t$1\n";
      $optionexists = 1;
    }
    else {
      push @setfile, $_;
    }
  }
  push @setfile, "$opt\t$val\t\n" if ($optionexists == 0);
  close(SETFILE);
  open(SETFILE, ">$ver\\$race\\Settings.txt") or die get_translation('err_file_not_found', "<$ver\\$race\\Settings.txt>");
  print SETFILE @setfile;
  close(SETFILE);
}

sub SetVerOption {
  my ($ver, $opt, $val) = @_;
  open(SETFILE, "$ver\\GlobalSettings.txt") or die get_translation('err_file_not_found', "<$ver\\GlobalSettings.txt>");
  my @setfile = ();
  my $optionexists = 0;
  while(<SETFILE>) {
    if (/^$opt\t[^\t]*\t(.*)/) {
      push @setfile, "$opt\t$val\t$1\n";
      $optionexists = 1;
    }
    else {
      push @setfile, $_;
    }
  }
  push @setfile, "$opt\t$val\t\n" if ($optionexists == 0);
  close(SETFILE);
  open(SETFILE, ">$ver\\GlobalSettings.txt") or die get_translation('err_file_not_found', "<$ver\\GlobalSettings.txt>");
  print SETFILE @setfile;
  close(SETFILE);
}

sub GetStratList {
  my $ver = shift;
  my $race = shift;
  return () unless ($ver and $race);
  open(STRATFILE, "$ver\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$ver\\$race\\Strategy.txt>");
  my @stratlist = ();
  <STRATFILE>;
  while (<STRATFILE>) {
    if (/^([^\t]*)\t/) {
      push @stratlist, $1;
    }
  };
  close(STRATFILE);
  return @stratlist;
};

sub UpdateStratList {
  my $stratlb = shift;
  my $ver = shift;
  my $race = shift;
  $stratlb->delete(0, $stratlb->index('end')-1);
  $stratlb->insert('end', GetStratList($ver, $race));
}

sub GetProfileList {
  my $ver = shift;
  return () unless ($ver);
  open(PROFILEFILE, "$ver\\Profiles.txt") or die get_translation('err_file_not_found', "<$ver\\Profiles.txt>");
  my @profilelist = ();
  <PROFILEFILE>;
  while (<PROFILEFILE>) {
    if (/^([^\t]*)\t/) {
      push @profilelist, $1;
    }
  };
  close(PROFILEFILE);
  return @profilelist;
};

sub UpdateProfileList {
  my ($profilelb, $ver) = @_;
  $profilelb->delete(0, $profilelb->index('end')-1);
  $profilelb->insert('end', GetProfileList($ver));
}

sub RemoveStrat {
  my ($main, $version, $race, $strat) = @_;
  return unless @$strat[0];
  my $response = $main->messageBox(-message => get_translation('message_remove_strategy'), -title => get_translation('title_really'), -type => 'YesNo', -default => 'no');
  return if ($response eq 'no' or $response eq 'No');
  my $stratname = @$strat[0];
  open(STRATFILE, "$version\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$version\\$race\\Strategy.txt>");
  my @stratfile = ();
  while (<STRATFILE>) {
    unless (/^$stratname\t/) {
      push(@stratfile, $_);
    }
  }
  close(STRATFILE);
  open(STRATFILE, ">$version\\$race\\Strategy.txt") or die get_translation('err_file_not_writing', "<$version\\$race\\Strategy.txt>");
  print STRATFILE @stratfile;
  close(STRATFILE);
  @stratfile = ();
  open(AIFILE, "$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$version\\$race\\BuildSequence.ai>");
  my @aifile = ();
  while (<AIFILE>) {
    if (/\bfunction\s*init_strategy_$stratname\b/) {
      while ((<AIFILE> or die get_translation('err_strategy_not_complete')) !~ /endfunction/) {}
      while ((<AIFILE> or die get_translation('err_strategy_not_complete')) !~ /endfunction/) {}
    }
    else {
      push(@aifile, $_);
    }
  }
  close(AIFILE);
  open(AIFILE, ">$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_writing', "<$version\\$race\\BuildSequence.ai>");
  print AIFILE @aifile;
  close(AIFILE);
}

sub RemoveProfile {
  my ($main, $version, $profile) = @_;
  return unless @$profile[0];
  my $response = $main->messageBox(-message => get_translation('message_remove_profile'), -title => get_translation('title_really'), -type => 'YesNo', -default => 'no');
  return if ($response eq 'no' or $response eq 'No');
  my $profilename = @$profile[0];
  open(PROFILEFILE, "$version\\Profiles.txt") or die get_translation('err_file_not_found', "<$version\\Profiles.txt>");
  my @profilefile = ();
  while (<PROFILEFILE>) {
    unless (/^$profilename\t/) {
      push(@profilefile, $_);
    }
  }
  close(PROFILEFILE);
  open(PROFILEFILE, ">$version\\Profiles.txt") or die get_translation('err_file_not_writing', "<$version\\Profiles.txt>");
  print PROFILEFILE @profilefile;
  close(PROFILEFILE);
}

sub CopyStrat {
  my ($version, $race, $strat) = @_;
  return unless @$strat[0];
  my $stratname = @$strat[0];
  ExtractStratSub('tmp', $version, $race, $stratname);
  InsertStratSub('tmp', $version, $race);
  system "del tmp";
}

sub CopyProfile {
  my ($version, $profile) = @_;
  return unless @$profile[0];
  my $profilename = @$profile[0];
  ExtractProfileSub('tmp', $version, $profilename);
  InsertProfileSub('tmp', $version);
  system "del tmp";
}

sub ExtractStratSub {
  my ($filename, $version, $race, $stratname) = @_;
  open(AIFILE, "$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$version\\$race\\BuildSequence.ai>");
  open(STRATFILE, "$version\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$version\\$race\\Strategy.txt>");
  open(TARGETFILE, ">$filename") or die get_translation('err_file_not_found', "<$filename>");
  print TARGETFILE "#AMAI 2.0 Strategy\n";
  my $line = <STRATFILE>;
  while (($line = (<STRATFILE> or die get_translation('err_strategy_not_found_s'))) !~ /^$stratname\t/) {}
  print TARGETFILE $line;
  while (($line = (<AIFILE> or die get_translation('err_strategy_not_found_b'))) !~ /\bfunction\s*init_strategy_$stratname\b/) {}
  print TARGETFILE $line;
  while (($line = (<AIFILE> or die get_translation('err_strategy_not_complete'))) !~ /endfunction/) {print TARGETFILE $line;}
  print TARGETFILE $line;
  while (($line = (<AIFILE> or die get_translation('err_strategy_not_complete'))) !~ /endfunction/) {print TARGETFILE $line;}
  print TARGETFILE $line;
  close(TARGETFILE);
  close(AIFILE);
  close(STRATFILE);
}

sub ExtractStrat {
  my ($main, $version, $race, $strat) = @_;
  return unless @$strat[0];
  my $stratname = @$strat[0];
  my $types = [['AMAI Strategies', '.ais']];
  $types = [['AMAI Strategies', '.ais'],[]] if ($fdialogbug);
  my $filename = $main->getSaveFile(
                -defaultextension => '.ais',
                -filetypes => $types );
  return unless ($filename and ($filename ne ""));
  ExtractStratSub($filename, $version, $race, $stratname);
}

sub ExtractProfileSub {
  my ($filename, $version, $profilename) = @_;
  open(PROFILEFILE, "$version\\Profiles.txt") or die get_translation('err_file_not_found', "<$version\\Profiles.txt>");
  open(TARGETFILE, ">$filename") or die get_translation('err_file_not_found', "<$filename>");
  print TARGETFILE "#AMAI 2.0 Profile\n";
  my $line = <PROFILEFILE>;
  while (($line = (<PROFILEFILE> or die get_translation('err_profile_not_found_p'))) !~ /^$profilename\t/) {}
  print TARGETFILE $line;
  close(TARGETFILE);
  close(PROFILEFILE);
}

sub ExtractProfile {
  my ($main, $version, $profile) = @_;
  return unless @$profile[0];
  my $profilename = @$profile[0];
  my $types = [['AMAI Profiles', '.aip']];
  $types = [['AMAI Profiles', '.aip'],[]] if ($fdialogbug);
  my $filename = $main->getSaveFile(
                -defaultextension => '.aip',
                -filetypes => $types );
  return unless ($filename and ($filename ne ""));
  ExtractProfileSub($filename, $version, $profilename);
}

sub InsertStratSub {
  my ($filename, $version, $race) = @_;
  my $stratlist = join ',', GetStratList($version, $race);
  open(SOURCE, $filename) or die get_translation('err_file_not_found', "<$filename>");
  open(AIFILE, ">>$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$version\\$race\\BuildSequence.ai>");
  open(STRATFILE, ">>$version\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$version\\$race\\Strategy.txt>");
  my $line = <SOURCE>;
  if ($line !~ /#AMAI 2.0 Strategy/) {die get_translation('err_not_file_s');}
  $line = <SOURCE>;
  $line =~ /^([^\t]*)\t/;
  my $oldstratname = $1;
  my $stratname = $oldstratname;
  my $x = 0;
  while ($stratlist =~ /\b$stratname\b/) {
    $x++;
    $stratname = "$oldstratname$x";
  }

  $line =~ s/^$oldstratname/$stratname/;
  print STRATFILE $line;
  print AIFILE "\n";
  while (<SOURCE>) {
    s/\b(function \w*_)$oldstratname\b/$1$stratname/;
    print AIFILE;
  }
  close(AIFILE);
  close(STRATFILE);
  close(SOURCE);
}

sub InsertStrat {
  my ($main, $version, $race) = @_;
  my $types = [['AMAI Strategies', '.ais']];
  $types = [['AMAI Strategies', '.ais'],[]] if ($fdialogbug);
  my $filename = $main->getOpenFile(
                -defaultextension => '.ais',
                -filetypes => $types );
  return unless ($filename and ($filename ne ""));
  InsertStratSub($filename, $version, $race);
}

sub InsertProfileSub {
  my ($filename, $version) = @_;
  my $profilelist = join ',', GetProfileList($version);
  open(SOURCE, $filename) or die get_translation('err_file_not_found', "<$filename>");
  open(PROFILEFILE, ">>$version\\Profiles.txt") or die get_translation('err_file_not_found', "<$version\\Profiles.txt>");
  my $line = <SOURCE>;
  if ($line !~ /#AMAI 2.0 Profile/) {die get_translation('err_not_file_p');}
  $line = <SOURCE>;
  $line =~ /^([^\t]*)\t/;
  my $oldprofilename = $1;
  my $profilename = $oldprofilename;
  my $x = 0;
  while ($profilelist =~ /\b$profilename\b/) {
    $x++;
    $profilename = "$oldprofilename$x";
  }

  $line =~ s/^$oldprofilename/$profilename/;
  print PROFILEFILE $line;
  close(PROFILEFILE);
  close(SOURCE);
}

sub InsertProfile {
  my ($main, $version) = @_;
  my $types = [['AMAI Profiles', '.aip']];
  $types = [['AMAI Profiles', '.aip'],[]] if ($fdialogbug);
  my $filename = $main->getOpenFile(
                -defaultextension => '.aip',
                -filetypes => $types );
  return unless ($filename and ($filename ne ""));
  InsertProfileSub($filename, $version);
}

sub EditStrat {
  my ($main, $version, $race, $strat) = @_;
  return unless @$strat[0];
  my $edit = $main->Toplevel(-title => get_translation('title_strategy_editor'));
  my $lframe = $edit->Frame->pack(-side => 'left');
  my $rframe = $edit->Frame->pack(-side => 'right');
  my $bframe = $rframe->Frame->pack(-side => 'right');
  my $strattable = $rframe->Table(-rows => 37)->pack(-side => 'left');
  open(TIERFILE, "$ver\\$race\\Tiers.txt") or die get_translation('err_file_not_found', "<$ver\\$race\\Tiers.txt>");
  my @tiers = <TIERFILE>;
  my $tiernum = @tiers;
  close(TIERFILE);
  my $textheight = 44 / ($tiernum + 1);
  my @buildtexttier = ();
  $lframe->Label(-text => get_translation('label_Init_code'))->pack;
  my $inittext = $lframe->Scrolled('TextUndo', -scrollbars => 'se', -wrap => 'none', -height => $textheight)->pack;
  for(my $i=1;$i<=$tiernum;$i++) {
    $lframe->Label(-text => get_translation('label_tier_code', "$i"))->pack;
    $buildtexttier[$i] = $lframe->Scrolled('TextUndo', -scrollbars => 'se', -wrap => 'none', -height => $textheight)->pack;
  }
  my $optarrayref = FillTable($strattable, $version, $race, @$strat[0]);
  FillTexts($inittext, \@buildtexttier, $version, $race, @$strat[0]);
  $bframe->Button(
                -text => get_translation('button_ok'),
                -command => sub {SaveStrat($edit, $inittext, \@buildtexttier, $strattable, $version, $race, @$strat[0], $optarrayref)},
                -width => 14)->pack;
  $bframe->Button(
                -text => get_translation('button_cancel'),
                -command => [$edit => 'destroy'],
                -width => 14)->pack;
  $edit->focusForce;
}

sub EditProfile {
  my ($main, $version, $profile) = @_;
  return unless @$profile[0];
  my $edit = $main->Toplevel(-title => get_translation('title_profile_editor'));
  my $bframe = $edit->Frame->pack(-side => 'right');
  my $profiletable = $edit->Table(-rows => 37)->pack(-side => 'left');
  my $optarrayref = FillProfileTable($profiletable, $version, @$profile[0]);
  $bframe->Button(
                -text => get_translation('button_ok'),
                -command => sub {SaveProfile($edit, $profiletable, $version, @$profile[0], $optarrayref)},
                -width => 14)->pack;
  $bframe->Button(
                -text => get_translation('button_cancel'),
                -command => [$edit => 'destroy'],
                -width => 14)->pack;
  $edit->focusForce;
}

sub GetVarList {
  my ($ver, $var, $race) = @_;
  open(VARFILE, "VarDefs.ini") or die get_translation('err_file_not_found', "<VarDefs.ini>");
  <VARFILE>;
  while(<VARFILE>) {
    chomp;
    if (/$var\t(.*)/) {
      my $fn = $1;
      $fn =~ s/\$RACE\$/$race/g;
      close(VARFILE);
      open(VARTABLE, "$ver\\$fn") or die get_translation('err_file_not_found', "<$ver\\$fn>");
      my @vt = ();
      while (<VARTABLE>) {
        /([^\t\n]*)(\t|\n|$)/;
        push @vt, $1;
      }
      close(VARTABLE);
      return @vt;
    }
  }
  return $var;
}

sub ExtendTable {
  my ($ver, $race, @table) = @_;
  my @outtable = ();
  foreach (@table) {
    my @l = ();
    push @l, $_;
    my $b = 1;
    while($b) {
      $b = 0;
      my @lout = ();
      foreach (@l) {
        if(/\$([^\$]*)\$/) {
          my $var = $1;
          my $it = $_;
          $b = 1;
          foreach (GetVarList($ver, $var, $race)) {
            my $itrep = $it;
            $itrep =~ s/\$$var\$/$_/g;
            push @lout, $itrep;
          }
        }
        else {
          push @lout, $_;
        }
      }
      @l = @lout;
    }
    push @outtable, @l;
  }
  return @outtable;
}

sub ExtendOptList {
  my ($ver, $dummy, @ilist) = @_;
  my @olist = ($dummy);
  foreach(@ilist) {
    if (/\%([^\%]+)\%/) {
      push @olist, GetVarList($ver, $1, '');
    }
    else {
      push @olist, $_;
    }
  }
  return @olist;
}

sub GetOptList {
  my $ver = shift;
  open(OPTFILE, "Optionlist.ini") or die get_translation('err_file_not_found', "<Optionlist.ini>");
  my %optlist = ();
  my @optfile = <OPTFILE>;
  close(OPTFILE);
  @optfile = ExtendTable($ver, '', @optfile);
  foreach (@optfile) {
    chomp;
    /([^:]*):([^:]*)/;
    my $optname = $1;
    my @optarray = split(',', $2);
    @optarray = ExtendOptList($ver, @optarray) if ($optarray[0] eq 'list');
    $optlist{$optname} = \@optarray;
  }
  return \%optlist;
}

sub OptionmenuAddOptions {
  my ($optmenu, $curval, @optlist) = @_;
  foreach (@optlist) {
    $optmenu->addOptions($_) unless $_ eq $curval;
  }
  $optmenu->addOptions($curval);
}

sub GetUnitLists {
  my ($version, $race) = @_;
  my @unitlist = (0);
  my @buildinglist = (0);
  my @upgradelist = (0);
  my @herolist = (0);
  open(UNITFILE, "$version\\StandardUnits.txt") or die get_translation('err_file_not_found', "<$version\\StandardUnits.txt>");
  while(<UNITFILE>) {
    my @line = split("\t", $_);
    push @buildinglist, $line[0] if ($line[2] =~ /$race/ and $line[4] eq "BUILDING");
    push @unitlist, $line[0] if (($line[2] =~ /$race/) and ($line[3] !~ /peon|mutated/) and $line[4] eq "UNIT");
    push @upgradelist, $line[0] if (($line[2] =~ /$race/) and ($line[3] =~ /upgrade/));
    push @herolist, $line[0] if (($line[2] =~ /$race|NEUTRAL/) and ($line[3] !~ /mutated/) and ($line[3] =~ /hero/));
  }
  close(UNITFILE);
  return (\@unitlist, \@buildinglist, \@upgradelist, \@herolist);
}

sub GetProfileUnitLists {
  my ($version, @races) = @_;
  my %unitlists;
  my %herolists;
  foreach (@races) {
    my @unitlist = (0);
    my @herolist = (0);
    $unitlists{$_} = \@unitlist;
    $herolists{$_} = \@herolist;
  }
  open(UNITFILE, "$version\\StandardUnits.txt") or die get_translation('err_file_not_found', "<$version\\StandardUnits.txt>");
  while(<UNITFILE>) {
    my @line = split("\t", $_);
    foreach (@races) {
      push @{$unitlists{$_}}, $line[0] if (($line[3] !~ /dummy|mutated|peon/) and ($line[2] =~ /$_/) and $line[4] eq "UNIT");
      push @{$herolists{$_}}, $line[0] if (($line[3] =~ /hero/) and ($line[3] !~ /mutated/) and ($line[2] =~ /$_/));
    }
  }
  close(UNITFILE);
  return (\%unitlists, \%herolists);
}

sub FillTable {
  my ($strattable, $version, $race, $strat) = @_;
  my $optlistref = GetOptList($version);
  my %optlist = %$optlistref;
  my ($unitlistref, $buildinglistref, $upgradelistref, $herolistref) = GetUnitLists($version, $race);
  my @unitlist = @{$unitlistref};
  my @buildinglist = @{$buildinglistref};
  my @upgradelist = @{$upgradelistref};
  my @herolist = @{$herolistref};
  open(STRATFILE, "$version\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$version\\$race\\Strategy.txt>");
  my $line = <STRATFILE>;
  chomp($line);
  my @opt = split("\t", $line);
  my $l;
  my $i = 0;
  foreach my $v (@opt) {
    $l = $strattable->Label(-text => $v);
    $strattable->put($i, 0, $l);
    $i++;
  }
  while (($line = (<STRATFILE> or die get_translation('err_strategy_not_found_s'))) !~ /^$strat\t/) {}
  chomp($line);
  my @optval = split("\t", $line);
  $i = 0;
  my @optarray = ();
  foreach my $v (@optval) {
    if ($optlist{$opt[$i]}) {
      my @optvalarray = @{$optlist{$opt[$i]}};
      $l = $strattable->Optionmenu(
                -variable => \($optarray[$i]),
                -width => 25)->pack;
      if ($optvalarray[0] eq 'list') {
        OptionmenuAddOptions($l, $v, @optvalarray[1..$#optvalarray]);
      }
      elsif ($optvalarray[0] eq 'unit') {
        OptionmenuAddOptions($l, $v, @unitlist);
      }
      elsif ($optvalarray[0] eq 'building') {
        OptionmenuAddOptions($l, $v, @buildinglist);
      }
      elsif ($optvalarray[0] eq 'hero') {
        OptionmenuAddOptions($l, $v, @herolist);
      }  
      else {
        OptionmenuAddOptions($l, $v, @upgradelist);
      }
    }
    else {
      $l = $strattable->Entry(-width => 25);
      $l->insert('end', $v);
    }
    $strattable->put($i, 1, $l);
    $i++;
  }
  close(STRATFILE);
  return \@optarray;
}

sub FillProfileTable {
  my ($profiletable, $version, $profile) = @_;
  my $optlistref = GetOptList($version);
  my %optlist = %$optlistref;
  my ($unitlistref, $herolistref) = GetProfileUnitLists($version, GetRaces($version), 'NEUTRAL');
  my %unitlists = %{$unitlistref};
  my %herolists = %{$herolistref};
  open(PROFILEFILE, "$version\\Profiles.txt") or die get_translation('err_file_not_found', "<$version\\Profiles.txt>");
  my $line = <PROFILEFILE>;
  chomp($line);
  my @opt = split("\t", $line);
  my $l;
  my $i = 0;
  foreach my $v (@opt) {
    $l = $profiletable->Label(-text => $v);
    $profiletable->put($i, 0, $l);
    $i++;
  }
  while (($line = (<PROFILEFILE> or die get_translation('err_profile_not_found_p'))) !~ /^$profile\t/) {}
  chomp($line);
  my @optval = split("\t", $line);
  $i = 0;
  my @optarray = ();
  foreach my $v (@optval) {
    if ($optlist{$opt[$i]}) {
      my @optvalarray = @{$optlist{$opt[$i]}};
      $l = $profiletable->Optionmenu(
                -variable => \($optarray[$i]),
                -width => 35)->pack;
      if ($optvalarray[0] eq 'list') {
        OptionmenuAddOptions($l, $v, @optvalarray[1..$#optvalarray]);
      }
      elsif ($optvalarray[0] eq 'unit') {
        OptionmenuAddOptions($l, $v, @{$unitlists{$optvalarray[1]}});
      }
      else {
        OptionmenuAddOptions($l, $v, @{$herolists{$optvalarray[1]}});
      }  
    }
    else {
      $l = $profiletable->Entry(-width => 40);
      $l->insert('end', $v);
    }
    $profiletable->put($i, 1, $l);
    $i++;
  }
  close(PROFILEFILE);
  return \@optarray;
}

sub AssembleTable {
  my ($strattable, $optarrayref) = @_;
  my @jl = ();
  for(my $i=0;$i<$strattable->totalRows;$i++) {
    if (defined @{$optarrayref}[$i]) {
      push @jl, @{$optarrayref}[$i];
    }
    else {
      push @jl, $strattable->get($i,1)->get;
    }
  }
  return join "\t", @jl;
}

sub FillTexts {
  my ($inittext, $buildtexttierref, $version, $race, $stratname, @optarray) = @_;
  my @buildtexttier = @{$buildtexttierref};
  open(AIFILE, "$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$version\\$race\\BuildSequence.ai>");
  my $line;
  while ((<AIFILE> or die get_translation('err_strategy_not_found_ai')) !~ /\bfunction\s*init_strategy_$stratname\b/) {}
  while (($line = (<AIFILE> or die get_translation('err_strategy_not_found_ai'))) !~ /endfunction/) {$inittext->insert('end', $line);}
  while ((<AIFILE> or die get_translation('err_strategy_not_found_ai')) !~ /\bfunction\s*build_sequence_$stratname\b/) {}
  while ((<AIFILE> or die get_translation('err_strategy_not_found_ai')) !~ /if.*tier.*==.*$#buildtexttier/) {}
  for(my $i=$#buildtexttier;$i>2;$i--) {
    my $j = $i-1;
    while (($line = (<AIFILE> or die get_translation('err_strategy_not_found_ai'))) !~ /elseif.*tier.*==.*$j/) {$buildtexttier[$i]->insert('end', $line);}
  }
  my $iflevel = 0;
  while ((($line = (<AIFILE> or die get_translation('err_strategy_not_found_ai'))) !~ /\belse\b/) or $iflevel != 0) {
    $buildtexttier[2]->insert('end', $line);
    $iflevel++ if ($line =~ /\bif/);
    $iflevel-- if ($line =~ /endif/);
  }
  $iflevel = 0;
  while ((($line = (<AIFILE> or die get_translation('err_strategy_not_found_ai'))) !~ /endif/) or $iflevel != 0) {
    $buildtexttier[1]->insert('end', $line);
    $iflevel++ if ($line =~ /\bif/);
    $iflevel-- if ($line =~ /endif/);
  }
  close(AIFILE);
}

sub SaveStrat {
  my ($edit, $inittext, $buildtexttierref, $strattable, $version, $race, $stratname, $optarrayref) = @_;
  my @buildtexttier = @{$buildtexttierref};
  my $newstratname = $strattable->get(0,1)->get;
  open(STRATFILE, "$version\\$race\\Strategy.txt") or die get_translation('err_file_not_found', "<$version\\$race\\Strategy.txt>");
  my @stratfile = ();
  while (<STRATFILE>) {
    if (/^$stratname\t/) {
      push(@stratfile, AssembleTable($strattable, $optarrayref));
      push(@stratfile, "\n");
    }
    else {
      push(@stratfile, $_);
    }
  }
  close(STRATFILE);
  open(STRATFILE, ">$version\\$race\\Strategy.txt") or die get_translation('err_file_not_writing', "<$version\\$race\\Strategy.txt>");
  print STRATFILE @stratfile;
  close(STRATFILE);
  @stratfile = ();
  open(AIFILE, "$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$version\\$race\\BuildSequence.ai>");
  my @aifile = ();
  while (<AIFILE>) {
    if (/\bfunction\s*init_strategy_$stratname\b/) {
      while ((<AIFILE> or die get_translation('err_strategy_not_complete')) !~ /endfunction/) {}
      while ((<AIFILE> or die get_translation('err_strategy_not_complete')) !~ /endfunction/) {}
      push(@aifile, "function init_strategy_$newstratname takes nothing returns nothing\n");
      push(@aifile, $inittext->get('1.0', 'end'));
      push(@aifile, "endfunction\n");
      push(@aifile, "function build_sequence_$newstratname takes nothing returns nothing\n");
      push(@aifile, "if tier == $#buildtexttier then\n");
      for(my $i=$#buildtexttier;$i>2;$i--) {
        my $j = $i-1;
        push(@aifile, $buildtexttier[$i]->get('1.0', 'end'));
        push(@aifile, "elseif tier == $j then\n");
      }
      push(@aifile, $buildtexttier[2]->get('1.0', 'end'));
      push(@aifile, "else\n");
      push(@aifile, $buildtexttier[1]->get('1.0', 'end'));
      push(@aifile, "endif\n");
      push(@aifile, "endfunction\n");
    }
    else {
      push(@aifile, $_);
    }
  }
  close(AIFILE);
  open(AIFILE, ">$version\\$race\\BuildSequence.ai") or die get_translation('err_file_not_writing', "<$version\\$race\\BuildSequence.ai>");
  print AIFILE @aifile;
  close(AIFILE);
  $edit->destroy;
}

sub SaveProfile {
  my ($edit, $profiletable, $version, $profilename, $optarrayref) = @_;
  my $newprofilename = $profiletable->get(0,1)->get;
  open(PROFILEFILE, "$version\\Profiles.txt") or die get_translation('err_file_not_found', "<$version\\Profiles.txt>");
  my @profilefile = ();
  while (<PROFILEFILE>) {
    if (/^$profilename\t/) {
      push(@profilefile, AssembleTable($profiletable, $optarrayref));
      push(@profilefile, "\n");
    }
    else {
      push(@profilefile, $_);
    }
  }
  close(PROFILEFILE);
  open(PROFILEFILE, ">$version\\Profiles.txt") or die get_translation('err_file_not_writing', "<$version\\Profiles.txt>");
  print PROFILEFILE @profilefile;
  close(PROFILEFILE);
  $edit->destroy;
}

sub EditRacialBuilds {
  my ($main, $ver, $race) = @_;
  my $edit = $main->Toplevel(-title => get_translation('title_racial_builds_editor'));
  my $lframe = $edit->Frame->pack(-side => 'left');
  my $rframe = $edit->Frame->pack(-side => 'right');
  my $textheight = 22;
  $lframe->Label(-text => get_translation('label_racial_Init_code'))->pack;
  my $inittext = $lframe->Scrolled('TextUndo', -scrollbars => 'se', -wrap => 'none', -height => $textheight)->pack;
  $lframe->Label(-text => get_translation('label_racial_build'))->pack;
  my $buildtext = $lframe->Scrolled('TextUndo', -scrollbars => 'se', -wrap => 'none', -height => $textheight)->pack;
  LoadRacialBuild($inittext, $buildtext, $ver, $race);
  $rframe->Button(
                -text => get_translation('button_ok'),
                -command => sub {SaveRacialBuild($edit, $inittext, $buildtext, $ver, $race)},
                -width => 14)->pack;
  $rframe->Button(
                -text => get_translation('button_cancel'),
                -command => [$edit => 'destroy'],
                -width => 14)->pack;
  $edit->focusForce;
}

sub LoadRacialBuild {
  my ($inittext, $buildtext, $ver, $race) = @_;
  open(AIFILE, "$ver\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$ver\\$race\\BuildSequence.ai>");
  my $line;
  while ((<AIFILE> or die get_translation('err_strategy_init_not_set')) !~ /function global_init_strategy/) {}
  while (($line = (<AIFILE> or die get_translation('err_strategy_init_not_complete'))) !~ /endfunction/) {$inittext->insert('end', $line);}
  while ((<AIFILE> or die get_translation('err_strategy_build_set')) !~ /function global_build_sequence/) {}
  while (($line = (<AIFILE> or die get_translation('err_strategy_build_complete'))) !~ /endfunction/) {$buildtext->insert('end', $line);}
  close(AIFILE);
}

sub SaveRacialBuild {
  my ($edit, $inittext, $buildtext, $ver, $race) = @_;
  open(AIFILE, "$ver\\$race\\BuildSequence.ai") or die get_translation('err_file_not_found', "<$ver\\$race\\BuildSequence.ai>");
  my @aifile = ();
  while (<AIFILE>) {
    if (/\bfunction\s*global_init_strategy\b/) {
      while ((<AIFILE> or die get_translation('err_global_build_set')) !~ /endfunction/) {}
      while ((<AIFILE> or die get_translation('err_global_build_set')) !~ /endfunction/) {}
      push(@aifile, "function global_init_strategy takes nothing returns nothing\n");
      push(@aifile, $inittext->get('1.0', 'end'));
      push(@aifile, "endfunction\n");
      push(@aifile, "function global_build_sequence takes nothing returns nothing\n");
      push(@aifile, $buildtext->get('1.0', 'end'));
      push(@aifile, "endfunction\n");
    }
    else {
      push(@aifile, $_);
    }
  }
  close(AIFILE);
  open(AIFILE, ">$ver\\$race\\BuildSequence.ai") or die get_translation('err_file_not_writing', "<$ver\\$race\\BuildSequence.ai>");
  print AIFILE @aifile;
  close(AIFILE);
  $edit->destroy;
}

sub EditSettings {
  my ($main, $file) = @_;
  my $edit = $main->Toplevel(-title => get_translation('title_settings_editor'));
  my $lframe = $edit->Frame->pack(-side => 'left');
  my $rframe = $edit->Frame->pack(-side => 'right');
  my $table = $lframe->Table(-rows => 37)->pack(-side => 'left');
  my $rownumber = LoadSettings($table, $file);
  $rframe->Button(
                -text => get_translation('button_ok'),
                -command => sub {SaveSettings($edit, $table, $file, $rownumber)},
                -width => 14)->pack;
  $rframe->Button(
                -text => get_translation('button_cancel'),
                -command => [$edit => 'destroy'],
                -width => 14)->pack;
  $edit->focusForce;
}

sub LoadSettings {
  my ($table, $file) = @_;
  open(SETTINGS, $file) or die get_translation('err_file_not_found', "<$file>");
  <SETTINGS>;
  my $i = 0;
  while(<SETTINGS>) {
    chomp;
    my @setting = split "\t", $_;
    my $l = $table->Label(-text => $setting[0]);
    $table->put($i, 0, $l);
    $l = $table->Entry(-width => 25);
    $l->insert('end', $setting[1]);
    $table->put($i, 1, $l);
    $l = $table->Label(-text => $setting[2]);
    $table->put($i, 2, $l);
    $i++;
  }
  close(SETTINGS);
  return $i;
}

sub SaveSettings {
  my ($edit, $table, $file, $rownumber) = @_;
  open(SETTINGS, ">$file") or die get_translation('err_file_not_writing', "<$file>");
  print SETTINGS "Variable Setting\tValue\tComment\n";
  for(my $i=0;$i<$rownumber;$i++) {
    my $setting = $table->get($i, 0)->cget('-text');
    my $value = $table->get($i, 1)->get;
    my $comment = $table->get($i, 2)->cget('-text');
    print SETTINGS "$setting\t$value\t$comment\n";
  }
  close(SETTINGS);
  $edit->destroy;
}