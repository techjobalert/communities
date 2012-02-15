class NotifySummary
  attr_reader :user, :from_date, :to_date
  def initialize(user_to_notify, _from_date = DateTime.now, _to_date = DateTime.now)
    @user, @from_date, @to_date = user_to_notify, _from_date, _to_date
    @events = {
      :challenges => {},
      :ideas => {},
      :comments => {}
    }
  end

  def email
    #"provectusit.mailer@gmail.com"
    user.notify_email.blank? ? user.email : user.notify_email
  end

  # For vote put voter_id into event_id
  def add_event(event_subject_type, event_subject_id, event_type, event_id)
    evs = events_ids(event_subject_type, event_subject_id, event_type)
    evs << event_id
  end

  # For votes put voter_ids into event_ids
  def add_events(event_subject_type, event_subject_id, event_type, event_ids)
    evs = events_ids(event_subject_type, event_subject_id, event_type)
    evs += event_ids
  end

  def challenge_voters(challenge_id)
    ids = events_ids(:challenges, challenge_id, :votes).uniq
    ids.empty? ? nil : User.where("id in (?)", ids)
  end

  def challenge_comments(challenge_id)
    #todo: test challenge comments
    ids = events_ids(:challenges, challenge_id, :comments)
    ids.empty? ? nil : Commenting::Comment.where("id in (?)", ids)
  end

  def challenge_ideas(challenge_id)
    #todo: test challenge reactions
    ids = events_ids(:challenges, challenge_id, :ideas)
    ids.empty? ? nil : Idea.where("id in (?)", ids)
  end

  def idea_voters(idea_id)
    ids = events_ids(:ideas, idea_id, :votes).uniq
    ids.empty? ? nil : User.where("id in (?)", ids)
  end

  def idea_comments(idea_id)
    #todo: test idea comments
    ids = events_ids(:ideas, idea_id, :comments)
    ids.empty? ? nil : Commenting::Comment.where("id in (?)", ids)
  end

  def idea_reactions(idea_id)
    #todo: test idea reactions
    ids = events_ids(:ideas, idea_id, :reactions)
    ids.empty? ? nil : Reaction.where("id in (?)", ids)
  end

  def comment_comments(comment_id)
    #todo: test comment comments
    ids = events_ids(:comments, comment_id, :comments)
    ids.empty? ? nil : Commenting::Comment.where("id in (?)", ids)
  end

  def challenges
    @events[:challenges].empty? ? nil : Challenge.where("id in (?)", @events[:challenges].keys)
  end

  def ideas
    @events[:ideas].empty? ? nil : Idea.where("id in (?)", @events[:ideas].keys)
  end

  def comments
    @events[:comments].empty? ? nil : Commenting::Comment.where("id in (?)", @events[:comments].keys)
  end

private

  def events_ids(subject, subject_id, event_type)
    subject = subject.to_sym
    subject_id = subject_id.id if subject_id.is_a? ActiveRecord::Base
    event_type = event_type.to_sym
    (@events[subject] ||= {}) &&
      (@events[subject][subject_id] ||= {}) &&
      (@events[subject][subject_id][event_type] ||= [])
  end
end