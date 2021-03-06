React = require 'react'
moment = require 'moment'
RichTextParagraph = React.createFactory require '../../../../../../components/rich_text2/components/input_paragraph.coffee'
{ div, p, textarea } = React.DOM


module.exports = React.createClass
  displayName: 'SectionHeader'

  changeTitle: (e) ->
    if e.key is 'Enter'
      e.preventDefault()

  setTitle: ->
    @props.article.set 'title', this.refs.title.value
    @props.saveArticle()

  setLeadParagraph: (html) ->
    @props.article.set 'lead_paragraph', html
    @props.saveArticle()

  renderLeadParagraph: ->
    div {
      className: 'edit-header__lead-paragraph'
    },
      RichTextParagraph {
        text: @props.article.get('lead_paragraph')
        onChange: @setLeadParagraph
        placeholder: 'Lead paragraph (optional)'
      }

  render: ->
    layout = @props.article.get('layout')
    vertical = @props.article.get('vertical')?.name
    div { className: 'edit-header' },
      unless layout is 'classic'
        div {
          className: 'edit-header__vertical' + if vertical then '' else ' placeholder'
        },
          vertical or 'Missing Vertical'

      div { className: 'edit-header__title' },
        textarea {
          className: 'invisible-input'
          placeholder: 'Type a title'
          defaultValue: @props.article.get 'title'
          onKeyPress: @changeTitle
          onKeyUp: @setTitle
          ref: 'title'
        }
        unless @props.article.get('title')?.length > 0
          div { className: 'edit-required' }

      if layout is 'classic'
        @renderLeadParagraph()

      div { className: 'edit-header__author' },
        if @props.article.get('author')
          p { className: 'author' },
            @props.article.get('author').name
        p { className: 'date' }, @props.article.getPublishDate()

      if layout is 'standard' and @props.article.get('lead_paragraph').length
        @renderLeadParagraph()
