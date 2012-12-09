require File.expand_path('../../spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationEvent do
  #ease of use
  Event = RedmineNotificationCenter::NotificationEvent

  describe "#candidates" do
    let!(:author) { stub(:active? => true) }
    let!(:assignee) { stub(:active? => true) }
    let!(:project) { stub(:users => []) }
    let!(:issue) { stub(:author => nil, :assigned_to => nil, :assigned_to_was => nil,
                        :project => project, :visible? => true) }

    describe "for :issue_added type" do
      let!(:event) { Event.new(:issue_added, issue) }

      it "should include the author" do
        issue.stub(:author) { author }
        event.candidates.should include author
      end

      it "should include the assignee" do
        issue.stub(:assigned_to) { assignee }
        event.candidates.should include assignee
      end

      it "should not include inactive users" do
        inactive = stub(:active? => false)
        issue.stub(:author) { inactive }
        event.candidates.should_not include inactive
      end

      it "should include other user on the project" do
        other_user = stub(:active? => true)
        project.stub(:users => [other_user])
        event.candidates.should include other_user
      end

      it "shouldn't include the same user twice" do
        issue.stub(:author => author, :assigned_to => author)
        candidates = event.candidates
        candidates.size.should == candidates.uniq.size
      end

      it "should remove users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        issue.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end

    describe "for :issue_edited type" do
      let!(:event) { Event.new(:issue_edited, issue) }

      it "should include the author" do
        issue.stub(:author) { author }
        event.candidates.should include author
      end

      it "should include the previous assignee" do
        issue.stub(:assigned_to_was) { assignee }
        event.candidates.should include assignee
      end
    end

    describe "for :document_added" do
      let!(:document) { stub(:project => project, :visible? => true) }
      let!(:event) { Event.new(:document_added, document) }

      it "delegates candidates to project.users" do
        project.stub(:users) { [author, assignee] }
        event.candidates.should == [author, assignee]
      end

      it "removes users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        document.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end

    describe "for :news_added" do
      let!(:news) { stub(:project => project, :visible? => true) }
      let!(:event) { Event.new(:news_added, news) }

      it "delegates candidates to project.users" do
        project.stub(:users) { [author, assignee] }
        event.candidates.should == [author, assignee]
      end

      it "removes users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        news.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end

    describe "for :news_comment_added" do
      let!(:news) { stub(:project => project, :visible? => true) }
      let!(:event) { Event.new(:news_comment_added, news) }

      it "delegates candidates to project.users" do
        project.stub(:users) { [author, assignee] }
        event.candidates.should == [author, assignee]
      end

      it "removes users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        news.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end

    describe "for :message_posted" do
      let!(:message) { stub(:project => project, :visible? => true) }
      let!(:event) { Event.new(:message_posted, message) }

      it "delegates candidates to project.users" do
        project.stub(:users) { [author, assignee] }
        event.candidates.should == [author, assignee]
      end

      it "removes users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        message.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end

    describe "for :wiki_content_added" do
      let!(:wiki_content) { stub(:project => project, :visible? => true) }
      let!(:event) { Event.new(:wiki_content_added, wiki_content) }

      it "delegates candidates to project.users" do
        project.stub(:users) { [author, assignee] }
        event.candidates.should == [author, assignee]
      end

      it "removes users who cannot view the issue" do
        blind = stub
        project.stub(:users => [blind])
        wiki_content.stub(:visible?).with(blind).and_return(false)
        event.candidates.should_not include blind
      end
    end
  end
end
