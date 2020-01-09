module SagePay
  base = '1.0.2'

  # SB-specific versioning "algorithm" to accommodate BNW/Jenkins/gemstash
  VERSION = (pre = ENV.fetch('GEM_PRE_RELEASE', '')).empty? ? base : "#{base}.#{pre}"
end
