#!/bin/sh
pandoc -5 -s --css=style.css --toc -o index.html *markdown
