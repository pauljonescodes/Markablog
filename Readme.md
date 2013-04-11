Markablog Static Site Generator
-------------------------------

I really like writing, Markdown, and that GitHub will host static content.

I really do not like complicated.

All the static site generators I experimented with were too complicated for what I wanted to accomplish.

So I write this little Perl hack that will generate a static site that is very, very simple.

### Quick start

Any file in `/posts` will be made into its own page and put into the index after `build.pl` is ran.

The naming convention should be (but doesn't strictly *need* to be) `[YEARMNDY][URL Title] optional.whatever`.

In your file, I recommend starting every document with,

	Your Readable Title {{meta}}
	----------------------------

But who am I to tell you what to do?