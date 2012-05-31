# Loads the i18n translations file for validation errors
translation_dir = [File.expand_path("../../../config/locales/en.yml", __FILE__)]
I18n.load_path += translation_dir
