---
title: "Sentiment Analysis of 10-K Files"
date: '2021-19-08T00:00:00Z'
draft: no
featured: no
gallery_item: null
image:
  caption: null
  focal_point: null
  preview_only: null
projects: []
subtitle: null
summary: null
tags:
- 10-K
- Sentiment Analysis
- Negative Dictionary
- Textual Analysis
- Python

authors: VictorDahan
---

# Downloading 10-K files

In this section we are going to download 100 10-K files from the SEC Edgar website. To do that, we need to download an index file from the following website: https://www.sec.gov/Archives/edgar/full-index/2021/QTR1/. The file is called "company.idx" and has the names, date, and link from all financial reports in 2021.

With this file in hand, we are going to write a command to download the first 100 10-K files that appear on the list.

      	# Open the company idx file
      	index_file = open("company.idx").readlines()

    		#Just confirming the header of the file		
    		print(index_file[:10])


