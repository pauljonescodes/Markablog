#!/usr/bin/perl -w

use strict;
use Cwd;
use CGI qw(:standard);
use File::Slurp;
use URI::Escape;

my $cwd				 = getcwd;
my $posts_dir_name	 = $cwd . '/posts';
my $css_dir_name	 = $cwd . '/css';
my $html_dir_name	 = $cwd . '/html';
my $js_dir_name		 = $cwd . '/js';

my $doctype_template = read_file($html_dir_name . '/doctype');
my $default_template = read_file($html_dir_name . '/default');
my $footer_template	 = read_file($html_dir_name . '/footer' );
my $header_template	 = read_file($html_dir_name . '/header' );
my $index_template	 = read_file($html_dir_name . '/index'	);
my $post_template	 = read_file($html_dir_name . '/post');

my $css_link;
my $js_head;
my $js_foot;

opendir( CSSDIR, $css_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @CSS = readdir(CSSDIR);
closedir( CSSDIR );

foreach my $currentstylesheet (@CSS) {
	if ($currentstylesheet ne "." && $currentstylesheet ne "..") {
		$css_link .= "<link href='css/$currentstylesheet' type='text/css' rel='stylesheet'>\n"; 
	}
}

# <link href="" media="all" rel="stylesheet" type="text/css">

opendir( POSTSDIR, $posts_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @POSTS = readdir(POSTSDIR);
closedir( POSTSDIR );

foreach my $currentpost (@POSTS) {
	if ($currentpost ne "." && $currentpost ne "..") {
		my ($date, $title) = $currentpost =~ /\[([^\]]*)\]/g;
		
		my $post_dir_escape = php_escapeshellarg($posts_dir_name . '/' . $currentpost);
		my $post_content = qx/.\/Markdown.pl $post_dir_escape/;
		
		my $find = "{{content}}";
		my $replace = '"$post_content"';
		
		my $current_post_template = $post_template;
		$current_post_template =~ s/$find/$replace/ee;
		
		my $post_html;
		
		$post_html .= $doctype_template . "\n";
		
		$post_html .= "<head>\n";
		$post_html .= $header_template;
		$post_html .= $css_link;
		$post_html .= "</head>\n";
		
		$post_html .= "<body>\n";
		$post_html .= $default_template . "\n";
		
		$post_html .= $current_post_template;
		
		$post_html .= $footer_template . "\n"; 
		
		$post_html .= "</body>\n";
		$post_html .= "</html>\n";
		
		$title = uri_escape($title);
		open (POSTHTMLFILE, ">$title.html");
		print POSTHTMLFILE $post_html;
		close (POSTHTMLFILE);
	}
}

sub php_escapeshellarg { 
	my $str = @_ ? shift : $_;
	$str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
	return "'$str'";
}