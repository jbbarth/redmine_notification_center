require File.expand_path('../../fast_spec_helper', __FILE__)

describe "Mailer and models checksums" do
  it 'has coherent checksum for Mailer' do
    # the main thing ! if it changes, we're absolutely
    # sure we need an update on our code
    'app/models/mailer.rb'.should have_checksum 'be31d197e1388230ff52d8c9df1500ac'
  end

  it 'has coherent checksum for models that impact notifications/permissions/visibilities' do
    'app/models/mailer.rb'.should have_checksum 'be31d197e1388230ff52d8c9df1500ac'
    'app/models/board.rb'.should have_checksum '3384be003b7ed5a3ccfcd3342c7d3179'
    'app/models/document.rb'.should have_checksum 'fe6da8f542f9f18218d4a73e36747390'
    'app/models/issue.rb'.should have_checksum '6dc0c9364beef459ffd52b7ec4e84264'
    'app/models/journal.rb'.should have_checksum 'f5badcc65d1ff0d547edd95cf24f9fdf'
    'app/models/message.rb'.should have_checksum '925f26e6f93e3d269acedfb107f3a2ba'
    'app/models/news.rb'.should have_checksum '1c4fc664e4d04ebeefa9fef5aa4abd5d'
    'app/models/project.rb'.should have_checksum 'c47ff0e1aee1d03e68d919ca8a685381'
    'app/models/user.rb'.should have_checksum '188899242a7509fc0d5b436911d1b4e1'
    'app/models/user_preference.rb'.should have_checksum 'f9fe85f05e203d5f52da62446987f5ef'
    'app/models/watcher.rb'.should have_checksum '1089f1a7801364274a4e6a98ddcaef3c'
    'app/models/wiki.rb'.should have_checksum '8ed7bfd40c2fcbdb8b4435dfb0644f50'
    'app/models/wiki_content.rb'.should have_checksum 'e129ca603c33d920800aeeee82ed6ef3'
    'app/models/wiki_page.rb'.should have_checksum '87f21707409dc68b1c169b6547f966d4'
  end
end
