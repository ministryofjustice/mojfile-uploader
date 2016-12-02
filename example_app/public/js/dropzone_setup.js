Dropzone.autoDiscover = false;

DropzoneSetup = {
  $target: {},
  $uploadedFiles: $('.uploaded-files'),
  $collectionRef: $('input[name=collection_ref]').val(),

  init: function () {
    var self = this;
    this.$target = $('.dropzone');

    this.$target.dropzone({
      url: '/upload',
      maxFilesize: 20,
      addRemoveLinks: true,
      createImageThumbnails: false,

      success: function (file, response) {
      },

      removedfile: function (file) {
        var name = file.name,
          collection = self.$collectionRef,
          url = ['', collection, name].join('/');

        $.ajax({
          type: 'DELETE',
          url: url,
          success: function (data) {
            $(file.previewElement).remove();
          }
        });
      }
    });
  }
};

DropzoneSetup.init();
