# RestClient won’t treat a StringIO object as a file for the purpose of
# a multipart form field, as StringIO doesn’t respond to `#path`.
# This works around this problem by including a dummy path method.
# The return value of this method does not matter.  It has been set to such to
# avoid new-to-the-project developer confusion when looking at response values
# and the like.

module MojFile
  class DummyPath < StringIO
    def path
      'DOES NOT MATTER'
    end
  end
end
