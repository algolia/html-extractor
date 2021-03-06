require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe(AlgoliaHTMLExtractor) do
  let(:current) { AlgoliaHTMLExtractor }
  describe '.run' do
    it 'should load from an HTML string' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual.size).to eq 1
    end

    it 'should allow overriding of the default css selector of nodes' do
      # Given
      input = '<div>foo</div>'

      # When
      options = {
        css_selector: 'div'
      }
      actual = AlgoliaHTMLExtractor.run(input, options: options)

      # Then
      expect(actual.size).to eq 1
    end

    it 'should export the Nokogiri node' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:node]).to be_an(Nokogiri::XML::Element)
    end

    it 'should remove empty elements' do
      # Given
      input = '<p></p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual.size).to eq 0
    end

    it 'should add the DOM position to each element' do
      # Given
      input = '<p>foo</p>
               <p>bar</p>
               <p>baz</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:custom_ranking][:position]).to eq 0
      expect(actual[1][:custom_ranking][:position]).to eq 1
      expect(actual[2][:custom_ranking][:position]).to eq 2
    end
  end

  describe 'extract_html' do
    it 'should extract outer html' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:html]).to eq '<p>foo</p>'
    end

    it 'should trim content' do
      # Given
      input = '<p>foo</p>
               <blink>irrelevant</blink>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:html]).to eq '<p>foo</p>'
    end

    it 'should remove excluded tags' do
      # Given
      input = '<p>foo<script src="evil.com" /></p>'

      # When
      options = {
        tags_to_exclude: 'script'
      }
      actual = AlgoliaHTMLExtractor.run(input, options: options)

      # Then
      expect(actual[0][:html]).to eq '<p>foo</p>'
    end
  end

  describe 'extract_text' do
    it 'should extract inner text' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:content]).to eq 'foo'
    end

    it 'should extract UTF8 correctly' do
      # Given
      input = '<p>UTF8‽✗✓</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:content]).to eq 'UTF8‽✗✓'
    end
  end

  describe 'extract_tag_name' do
    subject { current.extract_tag_name(node) }
    describe do
      let(:node) { double('Node', name: 'P') }
      it { should eq 'p' }
    end
  end

  describe 'extract_headings' do
    it 'should extract a simple hierarchy' do
      # Given
      input = '<h1>Foo</h1>
               <p>First paragraph</p>
               <h2>Bar</h2>
               <p>Second paragraph</p>
               <h3>Baz</h3>
               <p>Third paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:headings]).to eq ['Foo']

      expect(actual[1][:headings]).to eq %w[Foo Bar]

      expect(actual[2][:headings]).to eq %w[Foo Bar Baz]
    end

    it 'should have an empty array when no headings' do
      # Given
      input = '<p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:headings]).to eq []
    end

    it 'should use inner text of headings' do
      # Given
      input = '<h1><a href="#">Foo</a><span></span></h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:headings]).to eq ['Foo']
    end

    it 'should handle nodes not in any hierarchy' do
      # Given
      input = '<p>First paragraph</p>
               <h1>Foo</h1>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:headings]).to eq []
    end

    it 'should handle any number of wrappers' do
      # Given
      input = '<header>
                 <h1>Foo</h1>
                 <p>First paragraph</p>
               </header>
               <div>
                 <div>
                   <div>
                     <h2>Bar</h2>
                     <p>Second paragraph</p>
                     </div>
                   </div>
                 <div>
                   <h3>Baz</h3>
                   <p>Third paragraph</p>
                 </div>
               </div>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:headings]).to eq ['Foo']

      expect(actual[1][:headings]).to eq %w[Foo Bar]

      expect(actual[2][:headings]).to eq %w[Foo Bar Baz]
    end
  end

  describe 'extract_anchor' do
    it 'should get the anchor of parent' do
      # Given
      input = '<h1 name="anchor">Foo</h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq 'anchor'
    end

    it 'should get no anchor if none found' do
      # Given
      input = '<h1>Foo</h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq nil
    end

    it 'should use the id as anchor if no name set' do
      # Given
      input = '<h1 id="anchor">Foo</h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq 'anchor'
    end

    it 'should be set to nil if no name nor id' do
      # Given
      input = '<h1>Foo</h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq nil
    end

    it 'should get the anchor of closest parent with an anchor' do
      # Given
      input = '<h1 name="anchor">Foo</h1>
               <p>First paragraph</p>
               <h2>Bar</h2>
               <p>Second paragraph</p>
               <h3 name="subanchor">Baz</h3>
               <p>Third paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq 'anchor'
      expect(actual[1][:anchor]).to eq 'anchor'
      expect(actual[2][:anchor]).to eq 'subanchor'
    end

    it 'should get anchor even if heading not a direct parent' do
      # Given
      input = '<header>
                 <h1 name="anchor">Foo</h1>
                 <p>First paragraph</p>
               </header>
               <div>
                 <div>
                   <div>
                     <h2>Bar</h2>
                     <p>Second paragraph</p>
                   </div>
                 </div>
                 <div>
                   <h3 name="subanchor">Baz</h3>
                   <p>Third paragraph</p>
                 </div>
               </div>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq 'anchor'
      expect(actual[1][:anchor]).to eq 'anchor'
      expect(actual[2][:anchor]).to eq 'subanchor'
    end

    it 'should get anchor if not directly on the header but inner element' do
      # Given
      input = '<h1><a name="anchor">Foo</a></h1>
               <p>First paragraph</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:anchor]).to eq 'anchor'
    end
  end

  describe 'uuid' do
    it 'should give different uuid if different content' do
      # Given
      input_a = { content: 'foo' }
      input_b = { content: 'bar' }

      # When
      actual_a = AlgoliaHTMLExtractor.uuid(input_a)
      actual_b = AlgoliaHTMLExtractor.uuid(input_b)

      # Then
      expect(actual_a).not_to eq(actual_b)
    end

    it 'should ignore the objectID key' do
      # Given
      input_a = { content: 'foo', objectID: 'AAA' }
      input_b = { content: 'foo', objectID: 'BBB' }

      # When
      actual_a = AlgoliaHTMLExtractor.uuid(input_a)
      actual_b = AlgoliaHTMLExtractor.uuid(input_b)

      # Then
      expect(actual_a).to eq(actual_b)
    end

    it 'should give different uuid if different HTML tag' do
      # Given
      input_a = '<p>foo</p>'
      input_b = '<p class="bar">foo</p>'

      # When
      actual_a = AlgoliaHTMLExtractor.run(input_a)[0]
      actual_b = AlgoliaHTMLExtractor.run(input_b)[0]

      # Then
      expect(actual_a[:objectID]).not_to eq(actual_b[:objectID])
    end

    it 'should give different uuid if different position in page' do
      # Given
      input_a = '<p>foo</p><p>bar</p>'
      input_b = '<p>foo</p><p>foo again</p><p>bar</p>'

      # When
      actual_a = AlgoliaHTMLExtractor.run(input_a)[1]
      actual_b = AlgoliaHTMLExtractor.run(input_b)[2]

      # Then
      expect(actual_a[:objectID]).not_to eq(actual_b[:objectID])
    end

    it 'should give different uuid if different parent header' do
      # Given
      input_a = '<h1 name="foo">foo</h1><p>bar</p>'
      input_b = '<h1 name="bar">bar</h1><p>bar</p>'

      # When
      actual_a = AlgoliaHTMLExtractor.run(input_a)[0]
      actual_b = AlgoliaHTMLExtractor.run(input_b)[0]

      # Then
      expect(actual_a[:objectID]).not_to eq(actual_b[:objectID])
    end

    it 'should always give the same uuid for the same content' do
      # Given
      input_a = '<h1 name="foo">foo</h1><p>bar</p>'
      input_b = '<h1 name="foo">foo</h1><p>bar</p>'

      # When
      actual_a = AlgoliaHTMLExtractor.run(input_a)[0]
      actual_b = AlgoliaHTMLExtractor.run(input_b)[0]

      # Then
      expect(actual_a[:objectID]).to eq(actual_b[:objectID])
    end
  end

  describe 'heading_weight' do
    it 'should have 100 if no heading' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:custom_ranking][:heading]).to eq 100
    end

    it 'should have decreasing value under small headers' do
      # Given
      input = '<h1 name="one">bar</h1><p>foo</p>
               <h2 name="two">bar</h2><p>foo</p>
               <h3 name="three">bar</h3><p>foo</p>
               <h4 name="four">bar</h4><p>foo</p>
               <h5 name="five">bar</h5><p>foo</p>
               <h6 name="six">bar</h6><p>foo</p>'

      # When
      actual = AlgoliaHTMLExtractor.run(input)

      # Then
      expect(actual[0][:custom_ranking][:heading]).to eq 90
      expect(actual[1][:custom_ranking][:heading]).to eq 80
      expect(actual[2][:custom_ranking][:heading]).to eq 70
      expect(actual[3][:custom_ranking][:heading]).to eq 60
      expect(actual[4][:custom_ranking][:heading]).to eq 50
      expect(actual[5][:custom_ranking][:heading]).to eq 40
    end
  end
end
# rubocop:enable Metrics/BlockLength
