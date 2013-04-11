#!/usr/bin/perl -w

use strict;
use Cwd;
use File::Slurp;
use URI::Escape;

#
# Some metadata
#

my $sitename = "PLJNS.com";

#
# These are the base directories my engine uses
#

my $cwd				 = getcwd;
my $posts_dir_name	 = $cwd . '/posts';
my $css_dir_name	 = $cwd . '/css';
my $html_dir_name	 = $cwd . '/html';
my $js_dir_name		 = $cwd . '/js';

#
# The HTML snippets used for templating
#

my $doctype_template = read_file($html_dir_name . '/doctype');
my $default_template = read_file($html_dir_name . '/default');
my $footer_template	 = read_file($html_dir_name . '/footer' );
my $header_template	 = read_file($html_dir_name . '/header' );
my $index_template	 = read_file($html_dir_name . '/index'	);
my $post_template	 = read_file($html_dir_name . '/post');

#
# For the contents of /css and /js
#

my $css_link;
my $js_head;
my $js_foot;

#
# For building indeces
#

my @post_urls;

opendir( CSSDIR, $css_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @CSS = readdir(CSSDIR);
closedir( CSSDIR );

foreach my $currentstylesheet (@CSS) {
	if ($currentstylesheet ne "." && $currentstylesheet ne ".." && $currentstylesheet ne ".DS_Store") {
		$css_link .= "<link href='css/$currentstylesheet' type='text/css' rel='stylesheet'>\n"; 
	}
}

# <link href="" media="all" rel="stylesheet" type="text/css">

opendir( POSTSDIR, $posts_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @POSTS = readdir(POSTSDIR);
closedir( POSTSDIR );

my $post_count = 0;
my $index_count = 1;
my $previous;
my $next;

open (INDEXHTMLFILE, ">$index_count.html");
print INDEXHTMLFILE $doctype_template . "\n";
print INDEXHTMLFILE "<head>\n";
print INDEXHTMLFILE "<title>$sitename</title>";
print INDEXHTMLFILE $header_template;
print INDEXHTMLFILE $css_link;
print INDEXHTMLFILE "</head>\n";
print INDEXHTMLFILE "<body>\n";
print INDEXHTMLFILE $default_template . "\n";


foreach my $currentpost (reverse(@POSTS)) {
	if ($currentpost ne "." && $currentpost ne ".." && $currentpost ne ".DS_Store") {
		$post_count++;
		
		if ($post_count % 5 == 0) {
			
			$previous = $index_count - 1;
			$next = $index_count + 1;
			
			if ($index_count == 1) {			
				print INDEXHTMLFILE "<div class = 'row-fluid'><div class = 'span2'>";
				print INDEXHTMLFILE "</div>";
				
				print INDEXHTMLFILE "<div class = 'span8'>";
				
				# print INDEXHTMLFILE "<a href='$previous.html' class='btn btn-small'><i class='icon-white icon-chevron-left'></i> Previous</a>";
				print INDEXHTMLFILE "<a href='$next.html' class='btn btn-small pull-right'>Next <i class='icon-white icon-chevron-right'></i></a>";
				
				print INDEXHTMLFILE "</div>";
				
				print INDEXHTMLFILE "<div class = 'span2'>";
				print INDEXHTMLFILE "</div></div>";
			} else {
				print INDEXHTMLFILE "<div class = 'row-fluid'><div class = 'span2'>";
				print INDEXHTMLFILE "</div>";
				
				print INDEXHTMLFILE "<div class = 'span8'>";
				
				print INDEXHTMLFILE "<a href='$previous.html' class='btn btn-small'><i class='icon-white icon-chevron-left'></i> Previous</a>";
				print INDEXHTMLFILE "<a href='$next.html' class='btn btn-small pull-right'>Next <i class='icon-white icon-chevron-right'></i></a>";
				
				print INDEXHTMLFILE "</div>";
				
				print INDEXHTMLFILE "<div class = 'span2'>";
				print INDEXHTMLFILE "</div></div>";
			}

			
			$index_count++;
			
			print INDEXHTMLFILE $footer_template . "\n"; 
			print INDEXHTMLFILE "</body>\n";
			print INDEXHTMLFILE "</html>\n";
			
			close(INDEXHTMLFILE);
			
			open (INDEXHTMLFILE, ">$index_count.html");
			print INDEXHTMLFILE $doctype_template . "\n";
			print INDEXHTMLFILE "<head>\n";
			print INDEXHTMLFILE "<title>$sitename</title>";
			print INDEXHTMLFILE $header_template;
			print INDEXHTMLFILE $css_link;
			print INDEXHTMLFILE "</head>\n";
			print INDEXHTMLFILE "<body>\n";
			print INDEXHTMLFILE $default_template . "\n";
		}
		
		#
		# Get data and title, make url
		#
		
		print $currentpost . "\n";
		
		my ($date, $title) = $currentpost =~ /\[([^\]]*)\]/g;
		
		my $day = substr $date, 6, 2;
		my $mon = substr $date, 4, 2;
		my $monlast = substr($mon, 1, 1);
		my $year = substr $date, 0, 4;
		
		my @months = qw(Plc January February March April May June July August September October November December);
		my @endings = qw(th st nd rd th th th th th th);
		
		my $readdate = $months[$mon] . " " . $day . $endings[$monlast] . ", " . $year; 
		
		my $post_url = $date . $title . '.html';
		my $meta = "<small><a href = '$post_url'>$readdate</a></small>";
		
		#
		# Get HTML snippet from Markdown
		#
		
		my $find    = "{{meta}}";
		my $replace = '"$meta"';
		
		my $post_dir_escape = php_escapeshellarg($posts_dir_name . '/' . $currentpost);
		my $post_content = qx/.\/Markdown.pl $post_dir_escape/;
		   $post_content =~ s/$find/$replace/ee;
		
		   $find = "{{content}}";
		   $replace = '"$post_content"';
		my $current_post_template = $post_template;
		   $current_post_template =~ s/$find/$replace/ee;
		
		
		open (POSTHTMLFILE, ">$post_url");
		
		print POSTHTMLFILE $doctype_template . "\n";
		print POSTHTMLFILE "<head>\n";
		print POSTHTMLFILE "<title>$sitename - $title</title>";
		print POSTHTMLFILE $header_template;
		print POSTHTMLFILE $css_link;
		print POSTHTMLFILE "</head>\n";
		print POSTHTMLFILE "<body>\n";
		print POSTHTMLFILE $default_template . "\n";
		print POSTHTMLFILE $current_post_template;
		print POSTHTMLFILE $footer_template . "\n"; 
		print POSTHTMLFILE "</body>\n";
		print POSTHTMLFILE "</html>\n";
		
		close (POSTHTMLFILE);
		
		#
		# Add post to index
		#
		
		print INDEXHTMLFILE $current_post_template;
	}
}

if ($post_count % 5 != 0) {

	$previous = $index_count - 1;
	$next = $index_count + 1;

	print INDEXHTMLFILE "<div class = 'row-fluid'><div class = 'span2'>";
	print INDEXHTMLFILE "</div>";
	
	print INDEXHTMLFILE "<div class = 'span8'>";
	
	print INDEXHTMLFILE "<a href='$previous.html' class='btn btn-small'><i class='icon-white icon-chevron-left'></i> Previous</a>";
	
	print INDEXHTMLFILE "</div>";
	
	print INDEXHTMLFILE "<div class = 'span2'>";
	print INDEXHTMLFILE "</div></div>";

	print INDEXHTMLFILE $footer_template . "\n"; 
	print INDEXHTMLFILE "</body>\n";
	print INDEXHTMLFILE "</html>\n";
}

sub php_escapeshellarg { 
	my $str = @_ ? shift : $_;
	$str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
	return "'$str'";
}