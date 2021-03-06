#
# Image Collection section allows uploading a mix of images and artworks
#
_ = require 'underscore'
React = require 'react'
imagesLoaded = require 'imagesloaded'
Artwork = React.createFactory require './components/artwork.coffee'
Image = React.createFactory require './components/image.coffee'
Controls = React.createFactory require './components/controls.coffee'
DragContainer = React.createFactory require '../../../../../../components/drag_drop/index.coffee'
{ fillWidth }  = require '../../../../../../components/fill_width/index.coffee'
{ div, section, ul, li } = React.DOM

components = require('@artsy/reaction-force/dist/components/publishing/index').default
ImagesetPreviewClassic = React.createFactory components.ImagesetPreviewClassic

module.exports = React.createClass
  displayName: 'SectionImageCollection'

  getInitialState: ->
    progress: null
    imagesLoaded: false
    dimensions: []

  componentDidMount: ->
    @$list = $(@refs.images)
    @onChange()

  onChange: ->
    sizes = @getFillWidthSizes()
    imagesLoaded $(@refs.images), @onImagesLoaded(sizes)

  onImagesLoaded: (sizes) ->
    @setState
      progress: null
      imagesLoaded: true
      dimensions: fillWidth(
        @props.section.get('images'),
        sizes.targetHeight,
        sizes.containerSize,
        @props.section.get('layout') or @props.section.get('type')
      )

  getFillWidthSizes: ->
    articleLayout = @props.article.get('layout')
    sectionLayout = @props.section.get('layout')
    if articleLayout is 'classic'
      containerSize = if sectionLayout is 'column_width' then 580 else 900
    else if articleLayout is 'standard'
      containerSize = if sectionLayout is 'column_width' then 680 else 780
    targetHeight = window.innerHeight * .7
    if @props.section.get('type') is 'image_set' and @props.section.get('images').length > 3
      targetHeight = 400
    return {containerSize: containerSize, targetHeight: targetHeight}

  setProgress: (progress) ->
    if progress
      @setState
        progress: progress
        imagesLoaded: false
    else
      @onChange()

  removeItem: (item) -> =>
    @setState imagesLoaded: false
    newImages = _.without @props.section.get('images'), item
    @props.section.set images: newImages
    @onChange()

  onDragEnd: (images) ->
    @setState imagesLoaded: false
    @props.section.set images: images
    @onChange()

  largeImagesetClass: ->
    imagesetClass = ''
    if @props.section.get('type') is 'image_set'
      if @props.section.get('images').length > 3
        imagesetClass = ' imageset-block'
      if @props.section.get('images').length > 6
        imagesetClass = ' imageset-block imageset-block--long'
    imagesetClass

  render: ->
    images = @props.section.get 'images' or []
    hasImages = images.length > 0
    isSingle = if images.length is 1 then ' single' else ''
    listClass = if hasImages then '' else ' image-collection__list--placeholder'

    section {
      className: 'edit-section--image-collection' + @largeImagesetClass()
      onClick: @props.setEditing(true)
    },
      if @props.editing
        Controls {
          section: @props.section
          images: images
          setProgress: @setProgress
          onChange: @onChange
          channel: @props.channel
          editing: @props.editing
          article: @props.article
        }
      if @state.progress
        div { className: 'upload-progress-container' },
          div {
            className: 'upload-progress'
            style: width: (@state.progress * 100) + '%'
          }
      div {
        className: 'image-collection__list' + listClass + isSingle
        ref: 'images'
        style:
          opacity: if @state.imagesLoaded then 1 else 0
      },
        if hasImages
          if !@props.editing and @props.section.get('type') is 'image_set'
            ImagesetPreviewClassic {
              images: images
            }
          else
            DragContainer {
              items: images
              onDragEnd: @onDragEnd
              isDraggable: @props.editing
              dimensions: @state.dimensions
            },
              images.map (item, i) =>
                if item.type is 'artwork'
                  Artwork {
                    key: i
                    index: i
                    artwork: item
                    removeItem: @removeItem
                    editing:  @props.editing
                    imagesLoaded: @state.imagesLoaded
                    dimensions: @state.dimensions
                    article: @props.article
                  }
                else
                  Image {
                    index: i
                    key: i
                    image: item
                    removeItem: @removeItem
                    editing:  @props.editing
                    dimensions: @state.dimensions
                    imagesLoaded: @state.imagesLoaded
                  }
        else
          div { className: 'image-collection__placeholder' }, 'Add images and artworks above'
