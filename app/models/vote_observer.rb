class VoteObserver < ActiveRecord::Observer
  observe ActsAsVotable::Vote

  def after_create(v)
    TimelineEvent.create!({
      :event_type             => "liked_comment",
      :subject_type           => v.votable_type,
      :actor_type             => v.voter_type,
      :secondary_subject_type => v.votable.commentable_type,
      :subject_id             => v.votable_id,
      :actor_id               => v.voter_id,
      :secondary_subject_id   => v.votable.commentable_id
      })
  end
end
