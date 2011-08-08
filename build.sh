#!/bin/sh
pandoc -s --css=style.css --toc -o index.html *markdown
