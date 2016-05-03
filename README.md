# html-hierarchy-extractor

This gems lets you extract the hierarchy of headings and content from any HTML
page into and array of elements.

It is intended to be used with Algolia to improve relevance of search results
inside large HTML pages.

Note: This repo is still a work in progress, and follows the RDD (Readme Driven
Development) principle. All you see in the Readme might not be implemented yet.

## How to use

```ruby
page = HTMLHierarchyExtractor(html) # Or filepath
page.extract
```
