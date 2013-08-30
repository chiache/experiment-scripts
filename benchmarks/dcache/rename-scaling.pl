#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;

die "Usage: $0 THREADS COUNT\n" if @ARGV < 2;

my $username = $ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
my $prefix = "/var/tmp/$username/rename";
my $threads = shift @ARGV;
my $count = shift @ARGV;
my $program = dirname(abs_path(__FILE__)) . "/link_unlink_test";

die "THREADS or COUNT has to be non-zero\n" if $threads == 0 || $count == 0;

die "$prefix does not exist\n" if ! -d $prefix;

# Let's not scale work with the thread count
$count /= $threads;

# Some setup
for(1..$threads){
	mkdir "$prefix/$_";
	mkdir "$prefix/$_/a";
	mkdir "$prefix/$_/b";
	if ($count % 2) {
		`touch $prefix/$_/a/a`;
		`rm $prefix/$_/b/b`;
	} else {
		`rm $prefix/$_/a/a`;
		`touch $prefix/$_/b/b`;
	}
}

for(1..$threads){
	my $pid = fork();
	if($pid){
		# Do nothing
	} elsif(defined $pid){
		print `cd $prefix/$_ && $program ./a/a ./b/b $count`;
		exit;
	} else{
		die "Tragically";
	}
}

my $deadchild;

do{
	$deadchild = wait();
} while($deadchild != -1);
