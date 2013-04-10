#!/usr/bin/perl -w

use strict;
use Cwd;
use CGI qw(:standard);
use File::Slurp;

my $cwd              = getcwd;
my $posts_dir_name   = $cwd . '/posts';
my $css_dir_name     = $cwd . '/css';
my $html_dir_name    = $cwd . '/html';
my $js_dir_name      = $cwd . '/js';

my $doctype_template = read_file($html_dir_name . '/doctype');
my $default_template = read_file($html_dir_name . '/default');
my $footer_template  = read_file($html_dir_name . '/footer' );
my $header_template  = read_file($html_dir_name . '/header' );
my $index_template   = read_file($html_dir_name . '/index'  );
my $post_template    = read_file($html_dir_name . '/post');

my $css_link;
my $js_head;
my $js_foot;

opendir( CSSDIR, $css_dir_name ) || warn "Error in opening dir $posts_dir_name\n";
my @CSS = readdir(CSSDIR);
closedir( CSSDIR );

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
		
		print $doctype_template . "\n";
		
		print "<head>\n";
		print $header_template;
		print "</head>\n";
		
		print "<body>\n";
		print $default_template . "\n";
		
		print $current_post_template;
		
		print $footer_template . "\n"; 
		
		print "</body>\n";
		print "</html>\n";
	}
}

sub php_escapeshellarg { 
    my $str = @_ ? shift : $_;
    $str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
    return "'$str'";
}