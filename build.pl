#!/usr/bin/perl -w

use strict;
use Cwd;
use File::Slurp;
use URI::Escape;
use File::Basename;

#
# Some metadata
#

my $sitename = "Markablog";

#
# These are the base directories my engine uses
#

my $cwd				 = getcwd;
my $posts_dir_name	 = $cwd . '/posts';
my $css_dir_name	 = $cwd . '/css';
my $html_dir_name	 = $cwd . '/html';
my $js_dir_name		 = $cwd . '/js';
my $pages_dir_name   = $cwd . '/pages';

#
# The HTML snippets used for templating
#

my $doctype_template = read_file($html_dir_name . '/doctype');
my $default_template = read_file($html_dir_name . '/default');
my $footer_template	 = read_file($html_dir_name . '/footer' );
my $header_template	 = read_file($html_dir_name . '/header' );
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

my $post_count  = 0; # counts the total number of posts
my $index_count = 1; # counts the number of index pages, starting with index.html at 1
my $previous    = 0; # counter used to make back and next button
my $next        = 0; # counter used to make back and next button
my $navlinks    = "<a href = 'index.html'>Index</a>";

my $find = "{{sitename}}";
my $replace = '"$sitename <small>Simple Static Site Generator</small>"';
$default_template =~ s/$find/$replace/ee;

opendir( CSSDIR, $css_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @CSS = readdir(CSSDIR);
closedir( CSSDIR );

foreach my $currentstylesheet (@CSS) {
	if ($currentstylesheet ne "." && $currentstylesheet ne ".." && $currentstylesheet ne ".DS_Store") {
		$css_link .= "<link href='css/$currentstylesheet' type='text/css' rel='stylesheet'>\n"; 
	}
}

opendir( POSTSDIR, $posts_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @POSTS = readdir(POSTSDIR);
closedir( POSTSDIR );

#
# Build pages
#

opendir( PAGESDIR, $pages_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @PAGES = readdir(PAGESDIR);
closedir( PAGESDIR );

foreach my $currentpage (@PAGES) {
	if ($currentpage ne "." && $currentpage ne ".." && $currentpage ne ".DS_Store") {
	   my $title = basename($currentpage, '.md');
	   $navlinks .= " | <a href = '$title.html'>$title</a>";
	}
}

$find = "{{nav}}";
$replace = '"$navlinks"';
$default_template =~ s/$find/$replace/ee;

foreach my $currentpage (@PAGES) {
	if ($currentpage ne "." && $currentpage ne ".." && $currentpage ne ".DS_Store") {
        my $title = basename($currentpage, '.md');
        
        open (PAGEHTMLFILE, ">$title.html");
        
        print PAGEHTMLFILE $doctype_template . "\n";
        print PAGEHTMLFILE "<head>\n";
        print PAGEHTMLFILE "<title>$sitename - $title</title>";
        print PAGEHTMLFILE $header_template;
        print PAGEHTMLFILE $css_link;
        print PAGEHTMLFILE "</head>\n";
        print PAGEHTMLFILE "<body>\n";
        print PAGEHTMLFILE "<div class='container'>\n";
        print PAGEHTMLFILE $default_template . "\n";
        
        my $page_dir_escape = php_escapeshellarg($pages_dir_name . '/' . $currentpage);
        my $page_content = qx/.\/Markdown.pl $page_dir_escape/;
        
        print PAGEHTMLFILE "<div class = 'row-fluid'><article class='span8 offset2 well'>";
        print PAGEHTMLFILE $page_content;
        print PAGEHTMLFILE "</article></div>";
        print PAGEHTMLFILE $footer_template . "\n"; 
        print PAGEHTMLFILE "</div>\n";
        print PAGEHTMLFILE "</body>\n";
        print PAGEHTMLFILE "</html>\n";
        
        close (PAGEHTMLFILE);
    }
}

#
# Begin building first index
#

open (INDEXHTMLFILE, ">index.html");
print INDEXHTMLFILE $doctype_template . "\n";
print INDEXHTMLFILE "<head>\n";
print INDEXHTMLFILE "<title>$sitename</title>\n";
print INDEXHTMLFILE $header_template;
print INDEXHTMLFILE $css_link;
print INDEXHTMLFILE "</head>\n";
print INDEXHTMLFILE "<body>\n";
print INDEXHTMLFILE "<div class='container'>\n";
print INDEXHTMLFILE $default_template . "\n";

#
# Begin building tags
#

# open (TAGHTMLFILE, ">tags.html");
# print TAGHTMLFILE $doctype_template . "\n";
# print TAGHTMLFILE "<head>\n";
# print TAGHTMLFILE "<title>$sitename</title>\n";
# print TAGHTMLFILE $header_template;
# print TAGHTMLFILE $css_link;
# print TAGHTMLFILE "</head>\n";
# print TAGHTMLFILE "<body>\n";
# print TAGHTMLFILE "<div class='container'>\n";
# print TAGHTMLFILE $default_template . "\n";

#
# Now things get serious, start building blog from posts
#

foreach my $currentpost (reverse sort(@POSTS)) {
	if ($currentpost ne "." && $currentpost ne ".." && $currentpost ne ".DS_Store") {
		$post_count++;
		
		if ($post_count % 5 == 0) {
			
			$previous = $index_count - 1;
			$next = $index_count + 1;
			
			if ($index_count == 1) {			
				print INDEXHTMLFILE "<div class = 'row-fluid'>";
				print INDEXHTMLFILE "<div class = 'span8 offset2'>";
				
				print INDEXHTMLFILE get_next_button($next);
				
				print INDEXHTMLFILE "</div>";
				print INDEXHTMLFILE "</div>";
			} else {
				print INDEXHTMLFILE "<div class = 'row-fluid'>";
				print INDEXHTMLFILE "<div class = 'span8 offset2'>";
				
				print INDEXHTMLFILE get_prev_button($previous);
				print INDEXHTMLFILE get_next_button($next);
				
				print INDEXHTMLFILE "</div>";
				print INDEXHTMLFILE "</div>";
			}

			
			$index_count++;
			
			print INDEXHTMLFILE $footer_template . "\n"; 
			print INDEXHTMLFILE "</div>\n";
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
			print INDEXHTMLFILE "<div class='container'>\n";
			print INDEXHTMLFILE $default_template . "\n";
		}
		
		#
		# Get data and title, make url
		#
		
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
		
			 $find	  = "{{meta}}";
			 $replace = '"$meta"';
		
		my $post_dir_escape = php_escapeshellarg($posts_dir_name . '/' . $currentpost);
		my $post_content = qx/.\/Markdown.pl $post_dir_escape/;
		$post_content =~ s/$find/$replace/ee;
		
			 $find = "{{content}}";
			 $replace = '"$post_content"';
		my $current_post_template = $post_template;
			 $current_post_template =~ s/$find/$replace/ee;
		
		my @hashtags = $post_content =~ /(#[A-z_]\w+)/;
		
		open (POSTHTMLFILE, ">$post_url");
		
		print POSTHTMLFILE $doctype_template . "\n";
		print POSTHTMLFILE "<head>\n";
		print POSTHTMLFILE "<title>$sitename - $title</title>";
		print POSTHTMLFILE $header_template;
		print POSTHTMLFILE $css_link;
		print POSTHTMLFILE "</head>\n";
		print POSTHTMLFILE "<body>\n";
		print POSTHTMLFILE "<div class='container'>\n";
		print POSTHTMLFILE $default_template . "\n";
		print POSTHTMLFILE $current_post_template;
		print POSTHTMLFILE $footer_template . "\n"; 
		print POSTHTMLFILE "</div>\n";
		print POSTHTMLFILE "</body>\n";
		print POSTHTMLFILE "</html>\n";
		
		close (POSTHTMLFILE);
		
		#
		# Add post to index
		#
		
		print INDEXHTMLFILE $current_post_template;
	}
}

# print TAGHTMLFILE $footer_template . "\n";
# print TAGHTMLFILE "</div>\n"; 
# print TAGHTMLFILE "</body>\n";
# print TAGHTMLFILE "</html>\n";

if ($post_count % 5 != 0) {

	$previous = $index_count - 1;
	$next = $index_count + 1;
	
	if ($index_count > 1) {	
		print INDEXHTMLFILE "<div class = 'row-fluid'>";
		print INDEXHTMLFILE "<div class = 'span8 offset2'>";
		
		my $tmppre = "1";
		if ($previous eq 1) {
			$tmppre = 'index';
		}
			
		print INDEXHTMLFILE get_prev_button($tmppre);
		print INDEXHTMLFILE "</div>";
		print INDEXHTMLFILE "</div>";
	}
	
	print INDEXHTMLFILE $footer_template . "\n";
	print INDEXHTMLFILE "</div>\n"; 
	print INDEXHTMLFILE "</body>\n";
	print INDEXHTMLFILE "</html>\n";
}

sub get_next_button {
    return "<a href='@_.html' class='btn pull-right'>Next <i class='icon-black icon-arrow-right'></i></a>"
}

sub get_prev_button {
    return "<a href='@_.html' class='btn'><i class='icon-black icon-arrow-left'></i> Previous</a>"
}

sub php_escapeshellarg { 
	my $str = @_ ? shift : $_;
	$str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
	return "'$str'";
}
