require File.expand_path('../../spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationEvent do
  #ease of use
  Event = RedmineNotificationCenter::NotificationEvent

  describe "#candidates" do
    let!(:author) { stub(:active? => true) }
    let!(:assignee) { stub(:active? => true) }
    let!(:project) { stub(:users => []) }
    let!(:issue) { stub(:project => project, :visible? => true).as_null_object }
    let!(:event) { Event.new(:issue_added, issue) }

    describe "for issues" do
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
  end
end
