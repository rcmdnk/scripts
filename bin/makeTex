#!/usr/bin/env bash

# parameters
remaintex=0
output=summary
exclude=()

# help
HELP="Usage: $0 [-r] [-f <filename>] [-e <excludename>]
   -r  remain tex file
   -f  set output file name (default: $output)
   -e  exclude word (can use multiple time)
   -h  print this help
"

while getopts rf:e:h OPT;do
  ((OPTNUM++))
  case $OPT in
    "r" ) remaintex=1 ;;
    "f" ) output=$OPTARG ;;
    "e" ) exclude=(${exclude[*]} $OPTARG) ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "unknown option: $OPT" 1>&2;echo "$HELP" 1>&2; exit ;;
  esac
done

cat << EOF > "${output}.tex"
\documentclass[landscape]{article}
%\documentclass{article}
\usepackage[dvipdfm]{color,graphicx}
\usepackage[dvipdfm,colorlinks=true,linkcolor=blue,citecolor=blue,filecolor=blue,pagecolor=blue,urlcolor=blue,breaklinks=true]{hyperref}
%\usepackage{html}
\setlength{\topskip}{0mm}
\setlength{\footskip}{0mm}
\setlength{\headheight}{0mm}
\setlength{\headsep}{0mm}
\setlength{\topmargin}{0mm}
\setlength{\oddsidemargin}{0mm}
\addtolength{\oddsidemargin}{-1truein}
\addtolength{\oddsidemargin}{12mm}
%\setlength{\textheight}{\paperheight}
\setlength{\textwidth}{\paperwidth}
\addtolength{\textwidth}{-24mm}
\def\textfraction{.001}

%\setcounter{topnumber}{10}
%\def\topfraction{0.}
%\setcounter{bottomnumber}{10}
%\def\bottomfraction{0.}
%\setcounter{totalnumber}{10}
%\def\textfraction{0.0}

%\def\floatpagefraction{0.0}

\newcommand{\makehisto}[2]{
\begin{figure}[htbp]
  \begin{center}
%    \includegraphics[angle=90,width=0.8\hsize]{#1.eps}
%    \includegraphics{#1.eps}
%    \includegraphics[width=0.7\hsize]{#1.eps}
    \includegraphics[height=0.7\vsize]{#1.eps}
    \caption{#2}
  \end{center}
\end{figure}
}

\newcommand{\somehisto}[2]{
%\subsection{#1}
\makehisto{#1}{#2}
\clearpage
}

\newcommand{\minihisto}[1]{
  \begin{minipage}{0.50\hsize}
    \begin{center}
      \includegraphics[width=1\hsize]{#1.eps}
      \caption{#1}
    \end{center}
  \end{minipage}
}

\newcommand{\twohisto}[2]{
\begin{figure}[htb]
\minihisto{#1}
\minihisto{#2}
\end{figure}
}

\begin{document}
%\setcounter{page}{0}
\today \\\\
\listoffigures
\clearpage
EOF

ls -v ./*.eps > eps.dat
while read -r file;do
  flag=1
  for e in ${exclude[*]};do
    if echo "$file"|grep -q "$e";then
      flag=0
      break
    fi
  done
  if [ $flag -eq 0 ];then continue;fi
  epsname=${file%.eps}
  name=${epsname//_/\\\_}
  echo "\somehisto{${epsname}}{${name}}" >> "$output.tex"
done < eps.dat
rm -f eps.dat
echo "" >> "$output.tex"
echo "\end{document}" >> "$output.tex"

platex "$output"
platex "$output"
bibtex "$output"
bibtex "$output"
platex "$output"
platex "$output"

if type -a dvipidfmx >& /dev/null;then
  dvipdfmx -l "$output.dvi"
else
  dvipdfm -l "$output.dvi"
fi

#l2h summary
rm -rf "$output.log"
rm -rf "$output.lof"
rm -rf "$output.dvi"
rm -rf "$output.aux"
rm -rf "$output.blg"
rm -rf "$output.bbl"
rm -rf "$output.ps"
rm -rf "$output.out"
if [ $remaintex -eq 0 ];then
  rm -rf "$output.tex"
fi

