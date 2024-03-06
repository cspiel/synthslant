#  SynthSlant &ndash; Synthetic slanting of glyphs

Package `synthslant` slants short pieces of text to the right or to
the left.

##  Installation

The necessary files to install synthslant are
*synthslant.ins* and *synthslant.dtx*.  Running LaTeX on
*synthslant.ins* in particular produces *synthslant.sty*:

        latex synthslant.ins

After extraction from *synthslant.dtx* place *synthslant.sty* in a
directory mentioned in your TEXINPUTS paths or copy it into one of the
directories for your LaTeX installation's *sty*-files and run
**mktexlsr** or equivalent.

To build the documentation it is easier to use the GNU *Makefile*:

        make

LuaLaTeX users will want to override the default LaTeX command
**pdflatex** with **lualatex** by saying

        make LATEX=lualatex

To construct the manual *synthslant.pdf* a working
[MetaPost](https://tug.org/metapost.html) installation is required.
Moreover, besides the usual POSIX utilities
[**base64**](https://www.gnu.org/software/coreutils/manual/html_node/base64-invocation.html)
is needed to recover the graphics file stored as printable ASCII
characters inside of *synthslant.dtx*.  Cautious users can run

        make tool-check

ahead to verify that the required utilities are installed and
working.

##  Usage

Load the package with the usual incantation

        \usepackage{synthslant}

See Section 2 of the package documentation for available options.

##  Credits

Synthslant is written by Ch. L. Spiel <cspiel@users.sourceforge.org>.

##  License

Released under the
[LaTeX Project Public License v1.3c](https://www.latex-project.org/lppl.txt)
or later.
