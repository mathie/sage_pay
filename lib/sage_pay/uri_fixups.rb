module URI
  module REGEXP
    module PATTERN

      # FIXME: SagePay insists that curly brackets in URLs is OK, so we have
      # to convince the URI parser that's the case. First we have to update
      # the constant in question.
      remove_const :UNRESERVED
      UNRESERVED = "-_.!~*'()#{ALNUM}\{\}"

      # FIXME: Then we have to update all the dependent constants we care
      # about.
      remove_const :URIC
      remove_const :QUERY
      remove_const :X_ABS_URI
      URIC = "(?:[#{UNRESERVED}#{RESERVED}]|#{ESCAPED})"
      QUERY = "#{URIC}*"
      X_ABS_URI = "
        (#{PATTERN::SCHEME}):                     (?# 1: scheme)
        (?:
           (#{PATTERN::OPAQUE_PART})              (?# 2: opaque)
        |
           (?:(?:
             //(?:
                 (?:(?:(#{PATTERN::USERINFO})@)?  (?# 3: userinfo)
                   (?:(#{PATTERN::HOST})(?::(\\d*))?))?(?# 4: host, 5: port)
               |
                 (#{PATTERN::REG_NAME})           (?# 6: registry)
               )
             |
             (?!//))                              (?# XXX: '//' is the mark for hostport)
             (#{PATTERN::ABS_PATH})?              (?# 7: path)
           )(?:\\?(#{PATTERN::QUERY}))?           (?# 8: query)
        )
        (?:\\#(#{PATTERN::FRAGMENT}))?            (?# 9: fragment)
      "
    end
    #remove_const :ABS_URI if defined? :ABS_URI
    ABS_URI = Regexp.new('^' + PATTERN::X_ABS_URI + '$', #'
                         Regexp::EXTENDED, 'N').freeze
  end
end
