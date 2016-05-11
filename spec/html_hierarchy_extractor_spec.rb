require 'spec_helper'

describe(HTMLHierarchyExtractor) do
  describe 'extract' do
    it 'should load from an HTML string' do
      # Given
      input = '<p>foo</p>'

      # When
      actual = HTMLHierarchyExtractor.new(input).extract

      # Then
      expect(actual.size).to eq 1
    end

    describe 'html' do
      it 'should extract outer html' do
        # Given
        input = '<p>foo</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:html]).to eq '<p>foo</p>'
      end

      it 'should trim content' do
        # Given
        input = '<p>foo</p>'\
                '<blink>irrelevant</blink>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:html]).to eq '<p>foo</p>'
      end
    end

    describe 'text' do
      it 'should extract inner text' do
        # Given
        input = '<p>foo</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:text]).to eq 'foo'
      end

      it 'should extract UTF8 correctly' do
        # Given
        input = '<p>UTF8‽✗✓</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:text]).to eq 'UTF8‽✗✓'
      end
    end

    describe 'tag_name' do
      it 'should extract the tag name' do
        # Given
        input = '<p>foo</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:tag_name]).to eq 'p'
      end

      it 'should always return lowercase' do
        # Given
        input = '<P>foo</P>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:tag_name]).to eq 'p'
      end
    end

    describe 'hierarchy' do
      it 'should extract a simple hierarchy' do
        # Given
        input = '<h1>Foo</h1>'\
                '<p>First paragraph</p>'\
                '<h2>Bar</h2>'\
                '<p>Second paragraph</p>'\
                '<h3>Baz</h3>'\
                '<p>Third paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[0][:hierarchy][:lvl2]).to eq nil
        expect(actual[0][:hierarchy][:lvl3]).to eq nil

        expect(actual[1][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[1][:hierarchy][:lvl2]).to eq 'Bar'
        expect(actual[1][:hierarchy][:lvl3]).to eq nil

        expect(actual[2][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[2][:hierarchy][:lvl2]).to eq 'Bar'
        expect(actual[2][:hierarchy][:lvl3]).to eq 'Baz'
      end

      it 'should use inner text of headings' do
        # Given
        input = '<h1><a href="#">Foo</a><span></span></h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[0][:hierarchy][:lvl2]).to eq nil
        expect(actual[0][:hierarchy][:lvl3]).to eq nil
      end

      it 'should handle nodes not in any hierarchy' do
        # Given
        input = '<p>First paragraph</p>'\
                '<h1>Foo</h1>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:hierarchy][:lvl1]).to eq nil
        expect(actual[0][:hierarchy][:lvl2]).to eq nil
        expect(actual[0][:hierarchy][:lvl3]).to eq nil
      end

      it 'should handle any number of wrappers' do
        # Given
        input = '<header>'\
                  '<h1>Foo</h1>'\
                  '<p>First paragraph</p>'\
                '</header>'\
                '<div>'\
                  '<div>'\
                    '<div>'\
                      '<h2>Bar</h2>'\
                      '<p>Second paragraph</p>'\
                    '</div>'\
                  '</div>'\
                  '<div>'\
                    '<h3>Baz</h3>'\
                    '<p>Third paragraph</p>'\
                  '</div>'\
                '</div>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[0][:hierarchy][:lvl2]).to eq nil
        expect(actual[0][:hierarchy][:lvl3]).to eq nil

        expect(actual[1][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[1][:hierarchy][:lvl2]).to eq 'Bar'
        expect(actual[1][:hierarchy][:lvl3]).to eq nil

        expect(actual[2][:hierarchy][:lvl1]).to eq 'Foo'
        expect(actual[2][:hierarchy][:lvl2]).to eq 'Bar'
        expect(actual[2][:hierarchy][:lvl3]).to eq 'Baz'
      end
    end

    describe 'anchor' do
      it 'should get the anchor of parent' do
        # Given
        input = '<h1 name="anchor">Foo</h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq 'anchor'
      end

      it 'should get no anchor if none found' do
        # Given
        input = '<h1>Foo</h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq nil
      end

      it 'should use the id as anchor if no name set' do
        # Given
        input = '<h1 id="anchor">Foo</h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq 'anchor'
      end

      it 'should be set to nil if no name nor id' do
        # Given
        input = '<h1>Foo</h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq nil
      end

      it 'should get the anchor of closest parent with an anchor' do
        # Given
        input = '<h1 name="anchor">Foo</h1>'\
                '<p>First paragraph</p>'\
                '<h2>Bar</h2>'\
                '<p>Second paragraph</p>'\
                '<h3 name="subanchor">Baz</h3>'\
                '<p>Third paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq 'anchor'
        expect(actual[1][:anchor]).to eq 'anchor'
        expect(actual[2][:anchor]).to eq 'subanchor'
      end

      it 'should get anchor even if heading not a direct parent' do
        # Given
        input = '<header>'\
                  '<h1 name="anchor">Foo</h1>'\
                  '<p>First paragraph</p>'\
                '</header>'\
                '<div>'\
                  '<div>'\
                    '<div>'\
                      '<h2>Bar</h2>'\
                      '<p>Second paragraph</p>'\
                    '</div>'\
                  '</div>'\
                  '<div>'\
                    '<h3 name="subanchor">Baz</h3>'\
                    '<p>Third paragraph</p>'\
                  '</div>'\
                '</div>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq 'anchor'
        expect(actual[1][:anchor]).to eq 'anchor'
        expect(actual[2][:anchor]).to eq 'subanchor'
      end

      it 'should get anchor if not directly on the header but inner element' do
        # Given
        # Given
        input = '<h1><a name="anchor">Foo</a></h1>'\
                '<p>First paragraph</p>'

        # When
        actual = HTMLHierarchyExtractor.new(input).extract

        # Then
        expect(actual[0][:anchor]).to eq 'anchor'
      end
    end
  end
end
