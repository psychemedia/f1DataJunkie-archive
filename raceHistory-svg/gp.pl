#!/bin/perl
#----------------------------------------------------------------------
# Hacky script to parse the SVG output of a gnuplot graph (parses as text,
# not as XML) and highlight the nearby lines at any point.
# Takes a parameter representing the GROUP number of the car to consider
# a target and an optional string of the CSV header line which it will
# use to put better titles on the chart elements
#
# There are better ways to do this (eg an XML parser) but then you'd need
# modules installed, so this is specifically meant to be self contained.
# See also the SVG scripting is done without needing external files/libraries
#
# If you invoke these files from HTML, use the object tag
#     <object data="gp1.svg" width='1000' height='1000' type="image/svg+xml"></object>
# rather than the image tag and then the scripting will still apply
#----------------------------------------------------------------------
use strict;

sub svgStyleSheet {
    return <<ENDCSS;
<style type="text/css"><![CDATA[
    .back {
      opacity: 0;       /* note pointer-events=all on the appropriate elements */
      stroke-width: 5;
    }
    .car {
      opacity: 0.25;
    }
    .car0, .car0plus {
      /* target car */
      opacity: 1.0 !important;
      stroke-width: 2;
    }
    .car1a, .car1b {
      /* cars 1 (a)head and 1 (b)ehind */
      opacity: .9 !important;
      stroke-width: 2;
    }
    .car2a, .car2b {
      /* cars 2 (a)head and 2 (b)ehind (etc for (car 3a.....) */
      opacity: .75 !important;
      stroke-width: 2;
    }
    .car3a, .car3b {
      opacity: .5 !important;
      stroke-width: 1;
    }
    .car4a, .car4b {
      opacity: .4 !important;
      stroke-width: 1;
    }
    ]]>
</style>
ENDCSS
}

sub svgZoomJs {
    return <<ENDJS;
<script type='text/javascript'><![CDATA[
   // Chrome and Safari will execute scripts in SVG, so this scroll to zoom
   // is browser specific
   // If you invoke these files from HTML, use the object tag
   //    <object data="gp1.svg" width='1000' height='1000' type="image/svg+xml"></object>
   // rather than the image tag and then the scripting will still apply
   initZoom = function(tgtEl) {
     var zoom = 1,
         translate = [0,0],
         pageOffset = [tgtEl.offsetLeft, tgtEl.offsetTop];

     var page2viewportXY = function (xy) {
          // Convert this page position (coordinate system within the document) into
          // an offset in actual screen pixels from the viewport origin
          return [ xy[0] - pageOffset[0], xy[1] - pageOffset[1] ];
     };

     var viewport2worldXY = function (xy) {
          // Convert these a viewport position (screen position relative to the chart
          // element) to world coordinates for the chart, allowing for zoom and pan
          // Note we apply the scaling first
          return [ (xy[0] / zoom) - translate[0],
                   (xy[1] / zoom) - translate[1] ];
     };

     var rollMouse = function(evt) {
       if (tgtEl && evt.wheelDelta)
       {
          var viewportXY = page2viewportXY([evt.pageX, evt.pageY]);
          var worldXY    = viewport2worldXY(viewportXY);

          zoom *= (evt.wheelDelta > 0 ? 1.25 : 0.9);

          var newworldXY = viewport2worldXY(viewportXY);
          translate[0] += newworldXY[0] - worldXY[0];
          translate[1] += newworldXY[1] - worldXY[1];

          if (zoom < 1) {
             zoom = 1;
             translate = [0,0];
          }
          var tzoom = "scale("+zoom+")";
          var ttran = "translate("+translate[0]+","+translate[1]+")";
          tgtEl.setAttribute("transform", tzoom+" "+ttran );

          evt.stopEvent && evt.stopEvent();
          evt.preventDefault && evt.preventDefault();
          evt.stopPropagation && evt.stopPropagation();
          return false;
       }
     };

     // SVG draws later element over earlier elements, so to catch mouse rolls anywhere (not just
     // over lines etc) we put an empty rectangle at the very back of the doc
     var backRect = document.createElementNS('http://www.w3.org/2000/svg', "rect");
     backRect.setAttribute("opacity", "0");
     backRect.setAttribute("pointer-events", "all");    // events for fill and border despite opacity
     backRect.setAttribute("width", "100%");
     backRect.setAttribute("height", "100%");
     backRect.onmousewheel = rollMouse;
     tgtEl.insertBefore(backRect,tgtEl.firstChild);
   };
]]>
</script>
ENDJS
}

# Return a series of lines that are the SVG
# we will highlight position relative to group $tgtgrp in $lines of XML
sub process {
    my ($tgtgrp,$drivers,$lines) = @_;
    my $plotgrp;
    my $dvals = { };    # will build a hash of plot group to the (x,y) data values for each x pos (lap)

    # process all the lines of XML hack parsing the data values
    foreach (@$lines)
    {
        # having made data point a dot, now replace that with a small line for the key
        # and the data points
        if (/^(\s*)<circle.*\bid='gpDot'/) {
            $_ = "$1<path id='gpDot' d='M0,0 L5,0'/>\n";
        }

        # now look for data points and extract the coordinates
        if (/\s*<a xlink:title="Plot #(\d+)">/)
        {
            $plotgrp = $1;
        }
        if ($plotgrp && /<use xlink:href='#gpDot' x='(.*?)' y='(.*?)'/) {
            # ignore the first such data value as it's the key, not the data
            if (!$dvals->{$plotgrp})
            {
                $dvals->{$plotgrp} = [];
            }
            else
            {
                push(@{$dvals->{$plotgrp}}, [$1,$2]);
            }
        }
    }

    # the origin of the graph (time diff 0 at lap 0)
    my($x0,$y0) = @{$dvals->{$tgtgrp}->[0]};

    # now for each lap, scan all the dvals looking for position relative to grp $dvals
    my @grps = keys %$dvals;
    my $numlaps = int(@{$dvals->{$tgtgrp}});
    for (my $lap = 0; $lap < $numlaps; $lap++)
    {
        my $tgty    = $dvals->{$tgtgrp}->[$lap]->[1];   # don't assume our tgt group is always at $y0
        my @rtimes  = map($dvals->{$_}->[$lap] ? { grp => $_, t => $dvals->{$_}->[$lap]->[1]} : (), @grps);
        my @stimes  = sort { $a->{t} <=> $b->{t} } @rtimes;
        my $numcars = int(@stimes);
        my $lappos  = int(grep($_->{t} < $tgty, @stimes));       # position - 0 based !! :)

        # now add a position figure for all cars as position relative to $lappos
        foreach my $pos (0 .. $numcars-1)
        {
            my $car = $stimes[$pos]->{grp};
            my $relpos = $pos - $lappos;        # -ve number are AHEAD, +ve are BEHIND
            push(@{$dvals->{$car}->[$lap]}, $relpos);
        }
    }

    # and now process the line again, this time supplementing the datapoints with lines
    # of the correct start/end point and with a style representing position
    $plotgrp = undef;
    foreach (@$lines)
    {
        if (/^(\s*)<defs>/) {
            # now add our inline styles for lines based on position
            $_ .= svgStyleSheet();
        }
        elsif (m!^<\/defs>!)
        {
            # Wrap an SVG group around the entire chart and code to zoom that group
            $_ .= svgZoomJs() . "<g onload='initZoom(this)' transform='scale(1) translate(0,0)'>";
        }
        elsif (m!^</svg>!)
        {
            # close the extra group we added
            $_ = "</g>".$_;
        }

        # now look for data points
        if (/^(\s*<a xlink:title=")(Plot #)(\d+)(">.*)$/)
        {
            $plotgrp = $3;
            # Firefox shows tooltips of the title from this <a> tag
            $_ = $1.($drivers->[$plotgrp] || "Plot #$plotgrp").$4;
        }
        if ($plotgrp && /<use xlink:href='#gpDot' x='(.*?)' y='(.*?)'/) {
            # keep the first such data value as it's the key, not the data
            # but then add in our new data lines
            if ($dvals->{$plotgrp})
            {
                my($px,$py) = ($x0,$y0);
                foreach my $lapnum (1 .. int(@{$dvals->{$plotgrp}}))
                {
                    my($x,$y,$pos) = @{$dvals->{$plotgrp}->[$lapnum-1]};

                    # the last dataset is our "+1 lap" pseudocar
                    my $class = $plotgrp == int(@grps) ? "car0plus"
                              : $pos == 0              ? "car0"
                              : ($pos < 0)             ? ("car".(-$pos)."a")
                              : "car${pos}b";

                    # SVG trick #1 - put a title within an element and it displays as a tooltip in viewers on mouse over (most browsers)
                    # SVG trick #2 - put a wider transparent version for fuzzy hit testing
                    my $driver = $drivers->[$plotgrp] || "Plot $plotgrp";
                    my $title = "<title>$driver, Lap $lapnum</title>";
                    $_ = $_ .
                        "<path class='back' d='M $px,$py L $x,$y'>$title</path>\n" .
                        "<path class='car $class' d='M $px,$py L $x,$y'>$title</path>\n";
                    ($px,$py) = ($x,$y);
                }
                delete $dvals->{$plotgrp};
            }
            else
            {
                # Could do this to effectively delete later data points
                # but actually the small lines help you see true gaps at each lap
                #$_ = "";
            }
        }
    }

    return @$lines;
}

my $tgtgrp  = $ARGV[0] =~ /^\d+$/  ? shift : 3;
my $drivers = $ARGV[0] =~ /^lap,/i ? shift : [];
print(join("", process($tgtgrp, [split(",", $drivers)], [<>])), "\n");
