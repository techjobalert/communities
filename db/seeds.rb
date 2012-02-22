# -*- coding: utf-8 -*-
puts "[START] DATABASE-SEED"

#Settings
{ :comments_pre_moderation              => [false, 	'comments pre moderation'],
  :items_pre_moderation                 => [false, 	'items premoderation'],
  :show_search_results_per_page			=> [12,		'show search results per page']
}.each do |key, value|
  s = Settings.find_by_key(key)
  puts "[NEW] add '#{key}' = #{value[0]}" if s.nil?
  if s
    puts "[exist]'#{key}' = #{value[0]}"
  end
  Settings.create!({:key => key, :value => value[0].to_s, :description => value[1]}) if s.nil?
end

puts "[FINISH] DATABASE-SEED"
