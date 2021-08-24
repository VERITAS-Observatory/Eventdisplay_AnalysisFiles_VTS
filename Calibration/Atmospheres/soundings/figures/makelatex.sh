rm -f atmospheresfigures.tex
touch atmospheresfigures.tex

for A in 2008-2009 2009-2010 2010-2011 2011-2012 2012-2013 2013-2014 2014-2015 2015-2016 2016-2017 2017-2018 2019-2020
do
    echo "\\\section*{Season $A}" >> atmospheresfigures.tex
    echo "\\\\noindent\\\\begin{minipage}{\\\\textwidth}" >> atmospheresfigures.tex
    echo "\\\\centering" >> atmospheresfigures.tex
#    echo "\\\begin{figure}[!hb]" >> atmospheresfigures.tex
    echo "\\\includegraphics[width=0.9\\\textwidth]{season-$A-density.pdf}" >> atmospheresfigures.tex
    echo "\\\includegraphics[width=0.9\\\textwidth]{season-relativeWinter-$A-density.pdf}" >> atmospheresfigures.tex
    echo "\\\includegraphics[width=0.9\\\textwidth]{season-relativeSummer-$A-density.pdf}" >> atmospheresfigures.tex
#    echo "\\\end{figure}" >> atmospheresfigures.tex
    echo "\\\end{minipage}" >> atmospheresfigures.tex

done
